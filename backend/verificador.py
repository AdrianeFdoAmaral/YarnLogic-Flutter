import re


def calcular_saldo_carreira(instrucao: str) -> int:
  """Calcula o saldo de pontos com base na sintaxe da receita."""
  texto = instrucao.lower().strip()

  # Se for anel mágico inicial direto (ex: '6pb no am' ou '6sc')
  if 'am' in texto or 'anel' in texto:
    numeros = re.findall(r'\d+', texto)
    return int(numeros[0]) if numeros else 6

  # Se tiver repetições (ex: '[2pb, 1aum] x 6' ou '(1sc, inc) * 6')
  padrao_repeticao = r'[\\[\\(](.*?)[\\]\\)]\s*[*xX]\s*(\d+)'
  match = re.search(padrao_repeticao, texto)
  if match:
    bloco = match.group(1)
    multiplicador = int(match.group(2))

    # Calcula os pontos dentro do bloco
    pontos_bloco = 0
    # pb/sc = 1 ponto | aum/inc = 2 pontos | dim/dec = 1 ponto
    termos = re.findall(r'(\d+)\s*([a-zA-Z]+)', bloco)
    for qtd, sigla in termos:
      qtd = int(qtd)
      if sigla in ['aum', 'inc']:
        pontos_bloco += qtd * 2
      else:
        pontos_bloco += qtd * 1

    return pontos_bloco * multiplicador

  # Se for sequencia simples de aumentos (ex: '6aum')
  if 'aum' in texto or 'inc' in texto:
    numeros = re.findall(r'\d+', texto)
    return int(numeros[0]) * 2 if numeros else 12

  # Se for carreira reta (ex: '18pb')
  numeros = re.findall(r'\d+', texto)
  return int(numeros[0]) if numeros else 6