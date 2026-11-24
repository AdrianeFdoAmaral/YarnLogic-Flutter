import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/receita_models.dart';
import '../services/api_service.dart';
import '../widgets/yarn_widgets.dart';

class DetalheReceitaChecklistScreen extends StatefulWidget {
  final ReceitaItem receita;
  const DetalheReceitaChecklistScreen({super.key, required this.receita});

  @override
  State<DetalheReceitaChecklistScreen> createState() => _DetalheReceitaChecklistScreenState();
}

class _DetalheReceitaChecklistScreenState extends State<DetalheReceitaChecklistScreen> {
  String _filtro = 'Todas';

  Future<void> _alternarCarreira(int index, bool? valor) async {
    setState(() {
      widget.receita.carreiras[index].concluida = valor ?? false;
    });
    await ApiService.atualizarProgresso(
      widget.receita.id,
      widget.receita.carreiras.map((c) => c.concluida).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carreiras = widget.receita.carreiras;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const YarnTopHeader(),
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
              Text(
                widget.receita.titulo,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
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
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.peachCard,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.terracottaBorder, width: 1.2),
                      ),
                      child: ListView.builder(
                        itemCount: carreiras.length,
                        itemBuilder: (context, idx) {
                          final c = carreiras[idx];
                          if (_filtro == 'Ativas' && c.concluida) return const SizedBox.shrink();
                          if (_filtro == 'Concluídas' && !c.concluida) return const SizedBox.shrink();

                          return InkWell(
                            onTap: () => _alternarCarreira(idx, !c.concluida),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: c.concluida,
                                      activeColor: AppColors.terracotta,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.terracotta,
                                        width: 1.5,
                                      ),
                                      onChanged: (v) => _alternarCarreira(idx, v),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${c.numero}: ${c.codigo}: ${c.instrucao} (${c.saldoPontos}pts)',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Positioned(right: -8, bottom: 52, child: FlowerOrnament()),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TerracottaPillButton(
                icon: Icons.add,
                label: 'Nova Receita',
                onPressed: () => Navigator.pushReplacementNamed(context, '/guia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}