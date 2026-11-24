import re
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="YarnLogic API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Regras de pontos: sigla -> (pontos_consumidos, pontos_gerados)
STITCH_RULES = {
    "sc": (1, 1),   "pb": (1, 1),
    "hdc": (1, 1),  "mpa": (1, 1),
    "dc": (1, 1),   "pa": (1, 1),
    "tr": (1, 1),   "pad": (1, 1),
    "inc": (1, 2),  "aum": (1, 2),
    "dec": (2, 1),  "dim": (2, 1),
    "ch": (0, 1),   "corr": (0, 1),
    "slst": (1, 1), "pbx": (1, 1),
}

# --- MODELOS ---

class UsuarioCadastro(BaseModel):
    nome: str
    email: str
    senha: str

class UsuarioLogin(BaseModel):
    email: str
    senha: str

class CarreiraInput(BaseModel):
    numero: int
    instrucao: str
    concluida: bool = False

class CarreiraOut(CarreiraInput):
    codigo: str
    saldo_pontos: int

class ReceitaInput(BaseModel):
    titulo: str
    nivel: str = "Iniciante"  # Iniciante | Fácil | Avançado
    descricao: Optional[str] = ""
    imagem_url: Optional[str] = ""
    carreiras: List[CarreiraInput]

class ReceitaOut(BaseModel):
    id: int
    titulo: str
    nivel: str
    descricao: str
    imagem_url: str
    carreiras: List[CarreiraOut]

class ProgressoUpdate(BaseModel):
    carreiras_concluidas: List[bool]

# --- MOTOR DE CÁLCULO DE PONTOS (RF03) ---

def _calcular_bloco(texto: str) -> tuple[int, int]:
    consumidos = 0
    gerados = 0
    padrao = re.compile(
        r"(\d+)?\s*(inc|aum|dec|dim|sc|pb|hdc|mpa|dc|pa|tr|pad|ch|corr|slst|pbx)\b",
        re.IGNORECASE,
    )
    for qtd_str, sigla in padrao.findall(texto):
        qtd = int(qtd_str) if qtd_str else 1
        c, g = STITCH_RULES[sigla.lower()]
        consumidos += qtd * c
        gerados += qtd * g
    return consumidos, gerados

def calcular_saldo_carreira(instrucao: str, saldo_anterior: int) -> int:
    texto = instrucao.strip().lower()
    if not texto:
        return 0

    eh_anel_magico = any(k in texto for k in ["am", "mr", "anel mágico", "anel magico"])
    total_consumido = 0
    total_gerado = 0

    # 1. Grupos explícitos: (1pb, 1aum) x 6
    padrao_grupo = re.compile(r"[\(\[]([^\)\]]+)[\)\]]\s*[xX\*]\s*(\d+)")
    tem_grupo = False
    for conteudo, mult_str in padrao_grupo.findall(texto):
        tem_grupo = True
        mult = int(mult_str)
        c, g = _calcular_bloco(conteudo)
        total_consumido += c * mult
        total_gerado += g * mult

    restante = padrao_grupo.sub("", texto)
    c_rest, g_rest = _calcular_bloco(restante)
    total_consumido += c_rest
    total_gerado += g_rest

    # 2. Notação abreviada de amigurumi sem 'x 6' (ex: "1pb, 1aum" após carreira de 12 pts)
    if (
        not eh_anel_magico
        and not tem_grupo
        and saldo_anterior > 0
        and 0 < total_consumido < saldo_anterior
        and saldo_anterior % total_consumido == 0
    ):
        repeticoes = saldo_anterior // total_consumido
        return total_gerado * repeticoes

    return total_gerado

def processar_carreiras(carreiras: List[CarreiraInput]) -> List[CarreiraOut]:
    resultado: List[CarreiraOut] = []
    saldo_atual = 0
    for c in sorted(carreiras, key=lambda item: item.numero):
        saldo_atual = calcular_saldo_carreira(c.instrucao, saldo_atual)
        resultado.append(
            CarreiraOut(
                numero=c.numero,
                codigo=f"R{c.numero}",
                instrucao=c.instrucao,
                concluida=c.concluida,
                saldo_pontos=saldo_atual,
            )
        )
    return resultado

# --- ARMAZENAMENTO EM MEMÓRIA ---

db_usuarios = {"ana@yarnlogic.com": {"nome": "Ana", "senha": "123"}}
db_receitas: List[ReceitaOut] = []
next_receita_id = 1

# --- ENDPOINTS ---

@app.post("/register")
def registrar_usuario(dados: UsuarioCadastro):
    if dados.email in db_usuarios:
        raise HTTPException(status_code=400, detail="E-mail já cadastrado.")
    db_usuarios[dados.email] = {"nome": dados.nome, "senha": dados.senha}
    return {"nome": dados.nome, "email": dados.email, "inicial": dados.nome[0].upper()}

@app.post("/login")
def login(dados: UsuarioLogin):
    user = db_usuarios.get(dados.email)
    if not user or user["senha"] != dados.senha:
        # Permite acesso rápido em ambiente de demonstração se e-mail não existir
        nome_fallback = dados.email.split("@")[0].capitalize() or "Artesã"
        return {"nome": nome_fallback, "email": dados.email, "inicial": nome_fallback[0].upper()}
    return {"nome": user["nome"], "email": dados.email, "inicial": user["nome"][0].upper()}

@app.post("/calcular-preview")
def calcular_preview(carreiras: List[CarreiraInput]):
    """Calcula em tempo real os pontos de cada carreira durante o cadastro."""
    return processar_carreiras(carreiras)

@app.get("/receitas", response_model=List[ReceitaOut])
def listar_receitas():
    return db_receitas

@app.post("/receitas", response_model=ReceitaOut)
def criar_receita(dados: ReceitaInput):
    global next_receita_id
    carreiras_calc = processar_carreiras(dados.carreiras)
    nova = ReceitaOut(
        id=next_receita_id,
        titulo=dados.titulo,
        nivel=dados.nivel,
        descricao=dados.descricao or "",
        imagem_url=dados.imagem_url or "",
        carreiras=carreiras_calc,
    )
    db_receitas.append(nova)
    next_receita_id += 1
    return nova

@app.patch("/receitas/{receita_id}/progresso", response_model=ReceitaOut)
def atualizar_progresso(receita_id: int, dados: ProgressoUpdate):
    for receita in db_receitas:
        if receita.id == receita_id:
            for idx, status in enumerate(dados.carreiras_concluidas):
                if idx < len(receita.carreiras):
                    receita.carreiras[idx].concluida = status
            return receita
    raise HTTPException(status_code=404, detail="Receita não encontrada.")