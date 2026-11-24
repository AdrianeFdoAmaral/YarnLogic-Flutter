// models/receita_models.dart
class CarreiraItem {
  int numero;
  String codigo;
  String instrucao;
  int saldoPontos;
  bool concluida;

  CarreiraItem({
    required this.numero,
    required this.codigo,
    required this.instrucao,
    this.saldoPontos = 0,
    this.concluida = false,
  });

  factory CarreiraItem.fromJson(Map<String, dynamic> json) => CarreiraItem(
        numero: json['numero'] ?? 1,
        codigo: json['codigo'] ?? 'R${json['numero'] ?? 1}',
        instrucao: json['instrucao'] ?? '',
        saldoPontos: json['saldo_pontos'] ?? 0,
        concluida: json['concluida'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'codigo': codigo,
        'instrucao': instrucao,
        'saldo_pontos': saldoPontos,
        'concluida': concluida,
      };
}

class ReceitaItem {
  final String id;
  final String titulo;
  final String nivel;
  final String descricao;
  final String imagemUrl;
  final List<CarreiraItem> carreiras;

  ReceitaItem({
    required this.id,
    required this.titulo,
    required this.nivel,
    required this.descricao,
    required this.imagemUrl,
    required this.carreiras,
  });

  int get concluidasCount => carreiras.where((c) => c.concluida).length;
  bool get isConcluida => carreiras.isNotEmpty && concluidasCount == carreiras.length;

  factory ReceitaItem.fromJson(Map<String, dynamic> json) => ReceitaItem(
        id: (json['id'] ?? '').toString(),
        titulo: json['titulo'] ?? '',
        nivel: json['nivel'] ?? 'Fácil',
        descricao: json['descricao'] ?? '',
        imagemUrl: json['imagem_url'] ?? '',
        carreiras: (json['carreiras'] as List? ?? [])
            .map((e) => CarreiraItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}