import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/yarn_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _obscure = true;
  bool _carregando = false;

  Future<void> _entrar() async {
    if (_emailCtrl.text.trim().isEmpty || _senhaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha.')),
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      await ApiService.login(_emailCtrl.text, _senhaCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/receitas');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'E-mail ou senha incorretos.',
        'invalid-email' => 'Formato de e-mail inválido.',
        'operation-not-allowed' =>
          'Ative o login por E-mail/Senha no Firebase Authentication.',
        _ => 'Erro ao entrar (${e.code}): ${e.message}',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const YarnLogoMark(),
              const SizedBox(height: 18),
              const Text(
                'YarnLogic',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Seu assistente inteligente de crochê',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 40),
              YarnRoundedField(
                label: 'E-mail',
                hint: 'exemplo@email.com',
                prefixIcon: Icons.mail_outline,
                controller: _emailCtrl,
              ),
              const SizedBox(height: 18),
              YarnRoundedField(
                label: 'Senha',
                hint: 'Sua senha secreta',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                controller: _senhaCtrl,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: AppColors.terracotta, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TerracottaPillButton(
                label: _carregando ? 'Entrando...' : 'Entrar',
                onPressed: _carregando ? null : _entrar,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.dividerSoft),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text(
                    'Criar Conta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18, child: Divider(color: AppColors.dividerSoft)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.favorite_border, size: 16, color: AppColors.badgeGreenText),
                  ),
                  SizedBox(width: 18, child: Divider(color: AppColors.dividerSoft)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
