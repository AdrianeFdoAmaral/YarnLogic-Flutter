import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_colors.dart';
import 'models/receita_models.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/minhas_receitas_screen.dart';
import 'screens/guia_nomenclaturas_screen.dart';
import 'screens/nova_receita_screen.dart';
import 'screens/detalhe_receita_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD9bwV7Rq28u5ZyMK9Y-NgTNXBNR8DDbpw",
        authDomain: "yarnlogic-35d5d.firebaseapp.com",
        projectId: "yarnlogic-35d5d",
        storageBucket: "yarnlogic-35d5d.firebasestorage.app",
        messagingSenderId: "786761328337",
        appId: "1:786761328337:web:b791c43fb21fd57490c7f0",
        measurementId: "G-M75QX17GFJ",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const YarnLogicApp());
}

class YarnLogicApp extends StatelessWidget {
  const YarnLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YarnLogic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroUsuarioScreen(),
        '/receitas': (context) => const MinhasReceitasScreen(),
        '/guia': (context) => const GuiaNomenclaturasScreen(),
        '/nova-receita': (context) => const NovaReceitaFormScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detalhe-receita') {
          final receita = settings.arguments as ReceitaItem;
          return MaterialPageRoute(
            builder: (context) => DetalheReceitaChecklistScreen(receita: receita),
          );
        }
        return null;
      },
    );
  }
}