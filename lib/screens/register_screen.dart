// screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/yarn_widgets.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _carregando = false;

  void _voltarParaLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _cadastrar() async {
    if (_emailCtrl.text.trim().isEmpty || _senhaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }
    if (_senhaCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter pelo menos 6 caracteres.')),
      );
      return;
    }
    if (_senhaCtrl.text != _confirmaCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      await ApiService.registrar(
        _nomeCtrl.text.isEmpty ? 'Artesã' : _nomeCtrl.text,
        _emailCtrl.text,
        _senhaCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/receitas', (_) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Este e-mail já está cadastrado.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Fazer Login',
              textColor: AppColors.peachCard,
              onPressed: _voltarParaLogin,
            ),
          ),
        );
        return;
      }

      final msg = switch (e.code) {
        'invalid-email' => 'Digite um e-mail válido.',
        'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
        _ => 'Erro ao cadastrar: ${e.message}',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: _voltarParaLogin,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.peachCard,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.terracotta,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const YarnLogoMark(),
              const SizedBox(height: 14),
              const Text(
                'YarnLogic',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Seu assistente inteligente de crochê',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              YarnRoundedField(label: 'Nome', hint: 'Seu Nome', controller: _nomeCtrl),
              const SizedBox(height: 14),
              YarnRoundedField(
                label: 'E-mail',
                hint: 'exemplo@email.com',
                prefixIcon: Icons.mail_outline,
                controller: _emailCtrl,
              ),
              const SizedBox(height: 14),
              YarnRoundedField(
                label: 'Senha',
                hint: 'Mínimo 6 caracteres',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure1,
                controller: _senhaCtrl,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
              const SizedBox(height: 14),
              YarnRoundedField(
                label: 'Confirmar senha',
                hint: 'Digite sua senha novamente',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure2,
                controller: _confirmaCtrl,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
              const SizedBox(height: 28),
              TerracottaPillButton(
                label: _carregando ? 'Cadastrando...' : 'Cadastrar',
                onPressed: _carregando ? null : _cadastrar,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já possui uma conta?',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: _voltarParaLogin,
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}