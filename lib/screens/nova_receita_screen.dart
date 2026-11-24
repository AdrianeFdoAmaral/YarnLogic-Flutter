import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../theme/app_colors.dart';
import '../models/receita_models.dart';
import '../services/api_service.dart';
import '../widgets/yarn_widgets.dart';

class NovaReceitaFormScreen extends StatefulWidget {
  const NovaReceitaFormScreen({super.key});

  @override
  State<NovaReceitaFormScreen> createState() => _NovaReceitaFormScreenState();
}

class _NovaReceitaFormScreenState extends State<NovaReceitaFormScreen> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _nivel = 'Iniciante';
  bool _salvando = false;

  final List<TextEditingController> _carreiraCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<int> _saldos = [0, 0];
  Timer? _debounce;

  void _recalcularPontos() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final lista = List.generate(
        _carreiraCtrls.length,
        (i) => CarreiraItem(
          numero: i + 1,
          codigo: 'R${i + 1}',
          instrucao: _carreiraCtrls[i].text,
        ),
      );
      final calc = await ApiService.calcularPreview(lista);
      if (mounted) {
        setState(() {
          _saldos = calc.map((e) => e.saldoPontos).toList();
        });
      }
    });
  }

  void _adicionarCarreira() {
    setState(() {
      _carreiraCtrls.add(TextEditingController());
      _saldos.add(0);
    });
  }

  Future<void> _finalizarCadastro() async {
    if (_salvando) return;
    setState(() => _salvando = true);

    try {
      final carreiras = List.generate(
        _carreiraCtrls.length,
        (i) => CarreiraItem(
          numero: i + 1,
          codigo: 'R${i + 1}',
          instrucao: _carreiraCtrls[i].text.isEmpty
              ? (i == 0 ? '6pb no AM' : '6 aum')
              : _carreiraCtrls[i].text,
        ),
      );

      await ApiService.criarReceita(
        titulo: _tituloCtrl.text.isEmpty ? 'Gnomo Amigurumi' : _tituloCtrl.text,
        nivel: _nivel,
        descricao: _descCtrl.text,
        carreiras: carreiras,
      );

      if (mounted) Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'permission-denied'
          ? 'Permissão negada no Firestore. Verifique as regras no Firebase Console.'
          : 'Erro no Firestore (${e.code}): ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar receita: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const YarnTopHeader(),
              const SizedBox(height: 16),
              const Text(
                'Nova receita',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Crie suas novas receitas',
                style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.peachCard,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.terracottaBorder, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Cadastrar nova receita',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Nome da receita:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _tituloCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ex: Gnomo Amigurumi',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.dividerSoft),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.dividerSoft),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text('Nível:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            NivelPillSwitch(
                              label: 'Iniciante',
                              selected: _nivel == 'Iniciante',
                              onTap: () => setState(() => _nivel = 'Iniciante'),
                            ),
                            const SizedBox(width: 16),
                            NivelPillSwitch(
                              label: 'Avançado',
                              selected: _nivel == 'Avançado',
                              onTap: () => setState(() => _nivel = 'Avançado'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text('Descrição (Opcional):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _descCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Uma breve descrição sobre a peça...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.dividerSoft),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.dividerSoft),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Linhas/Carreiras', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        ...List.generate(_carreiraCtrls.length, (i) {
                          final saldo = i < _saldos.length ? _saldos[i] : 0;
                          final hint = i == 0 ? 'Ex: 6pb no AM' : (i == 1 ? 'Ex: 6 aum' : 'Ex: (1pb, 1aum) x 6');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.only(bottom: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.terracottaBorder, width: 0.9),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${i + 1}:   Carreira',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: const Color(0xFFD8D5D2),
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'R${i + 1}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 34,
                                        child: TextField(
                                          controller: _carreiraCtrls[i],
                                          onChanged: (_) => _recalcularPontos(),
                                          style: const TextStyle(fontSize: 12.5),
                                          decoration: InputDecoration(
                                            hintText: hint,
                                            hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                            filled: true,
                                            fillColor: AppColors.inputFill,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: const BorderSide(color: AppColors.dividerSoft),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: const BorderSide(color: AppColors.dividerSoft),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('pt:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCD8D5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$saldo',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 6),
                        Center(
                          child: ElevatedButton(
                            onPressed: _adicionarCarreira,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.terracotta,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              'Adicionar carreira',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(right: -8, bottom: 18, child: FlowerOrnament()),
                ],
              ),
              const SizedBox(height: 22),
              TerracottaPillButton(
                label: _salvando ? 'Salvando...' : 'Finalizar cadastro',
                onPressed: _salvando ? null : _finalizarCadastro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
