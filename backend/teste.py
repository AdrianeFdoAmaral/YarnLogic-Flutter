from ultralytics import YOLO

model = YOLO('best.pt')
resultados = model('imagens/imagen_teste.jpg', show=True, conf=0.01, save=True)
print("Deteção finalizada!")