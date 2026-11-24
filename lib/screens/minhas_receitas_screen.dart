import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/receita_models.dart';
import '../services/api_service.dart';
import '../widgets/yarn_widgets.dart';

class MinhasReceitasScreen extends StatefulWidget {
  const MinhasReceitasScreen({super.key});

  @override
  State<MinhasReceitasScreen> createState() => _MinhasReceitasScreenState();
}

class _MinhasReceitasScreenState extends State<MinhasReceitasScreen> {
  String _filtro = 'Todas';
  List<ReceitaItem> _receitas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await ApiService.listarReceitas();
      setState(() => _receitas = lista);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<ReceitaItem> get _filtradas {
    if (_filtro == 'Ativas') return _receitas.where((r) => !r.isConcluida).toList();
    if (_filtro == 'Concluídas') return _receitas.where((r) => r.isConcluida).toList();
    return _receitas;
  }

  Future<void> _abrirFluxoCadastro() async {
    final criou = await Navigator.pushNamed(context, '/guia');
    if (criou == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtradas;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              YarnTopHeader(
                onBack: () => Navigator.pushReplacementNamed(context, '/'),
              ),
              const SizedBox(height: 18),
              const Text(
                'Minhas Receitas',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gerencie e acompanhe seus amigurumis ativos',
                style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              Row(
                children: ['Todas', 'Ativas', 'Concluídas'].map((tab) {
                  final ativo = _filtro == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: ativo,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _filtro = tab),
                      selectedColor: AppColors.terracotta,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: ativo ? Colors.white : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: ativo ? AppColors.terracotta : AppColors.dividerSoft,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Stack(
                  children: [
                    if (_carregando)
                      const Center(child: CircularProgressIndicator())
                    else if (lista.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Cadastre um projeto para salvar seu progresso e acesse o scanner da IA para validar pontos na hora.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        itemCount: lista.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final r = lista[index];
                          final total = r.carreiras.isEmpty ? 1 : r.carreiras.length;
                          final prog = r.concluidasCount / total;
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamed(context, '/detalhe-receita', arguments: r);
                              _carregar();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                    child: Container(
                                      height: 125,
                                      width: double.infinity,
                                      color: AppColors.peachCard,
                                      child: const Icon(
                                        Icons.cruelty_free,
                                        size: 48,
                                        color: AppColors.terracotta,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.badgeGreenBg,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            r.nivel == 'Iniciante' ? 'Fácil' : r.nivel,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.badgeGreenText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          r.titulo,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'serif',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Carreiras',
                                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                            ),
                                            Text(
                                              '${r.concluidasCount}/${r.carreiras.length}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: prog,
                                            minHeight: 5,
                                            backgroundColor: AppColors.inputFill,
                                            color: AppColors.terracotta,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const Positioned(right: 0, bottom: 16, child: FlowerOrnament()),
                  ],
                ),
              ),
              TerracottaPillButton(
                icon: Icons.add,
                label: _receitas.isEmpty ? 'Registrar receita' : 'Nova Receita',
                onPressed: _abrirFluxoCadastro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}