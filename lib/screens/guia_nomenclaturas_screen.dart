import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/yarn_widgets.dart';

class GuiaNomenclaturasScreen extends StatelessWidget {
  const GuiaNomenclaturasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itens = [
      ('R1,R2', 'Carreiras (Round)'),
      ('sc / pb', 'Ponto baixo (Single Crochet)'),
      ('inc / aum', 'Aumento (Increase)'),
      ('dec / dim', 'Diminuição (Decrease)'),
    ];

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
                'Cadastrar minhas\nreceitas',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gerencie e acompanhe suas receitas',
                style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.peachCard,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.terracottaBorder, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.error_outline, color: Color(0xFFB36A1E), size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Guia de Nomenclaturas',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.only(left: 34),
                            child: Text(
                              'Use os termos abaixo para o app\nidentificar sua receita:',
                              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(itens.length, (i) {
                            final (sigla, desc) = itens[i];
                            return Container(
                              decoration: BoxDecoration(
                                border: i < itens.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                          color: AppColors.terracottaBorder,
                                          width: 0.9,
                                        ),
                                      )
                                    : null,
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 78,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                                        child: Text(
                                          sigla,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(width: 0.9, color: AppColors.terracottaBorder),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        child: Text(
                                          desc,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12.5,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const Positioned(right: -8, bottom: 18, child: FlowerOrnament()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TerracottaPillButton(
                label: 'Entendi, vamos começar',
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/nova-receita');
                  if (context.mounted) Navigator.pop(context, result);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}