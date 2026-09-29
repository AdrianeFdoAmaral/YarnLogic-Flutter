from flask import Flask, request, jsonify
from ultralytics import YOLO

app = Flask(__name__)

# Carrega o modelo
model = YOLO('best.pt')

# Rota inicial para testar no navegador
@app.route('/', methods=['GET'])
def home():
    return "API do YarnLogic está a rodar com sucesso!"

@app.route('/scan', methods=['POST'])
def scan_croche():
    if 'foto' not in request.files:
        return jsonify({'erro': 'Nenhuma foto enviada'}), 400
    
    foto = request.files['foto']
    caminho_temp = 'imagens/temp.jpg'
    foto.save(caminho_temp)
    
    # Executa a detecção com o modelo
    resultados = model(caminho_temp, conf=0.15)
    quantidade_pontos = len(resultados[0].boxes)
    
    return jsonify({
        'sucesso': True,
        'pontos_detectados': quantidade_pontos
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)