import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/receita_models.dart';

class ApiService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static String userInitial = 'A';

  static Future<void> login(String email, String senha) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );

    final uid = cred.user?.uid;
    if (uid != null) {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['inicial'] != null) {
        userInitial = doc.data()!['inicial'];
      } else if (email.trim().isNotEmpty) {
        userInitial = email.trim()[0].toUpperCase();
      }
    }
  }

  static Future<void> registrar(String nome, String email, String senha) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );

    final nomeLimpo = nome.trim().isEmpty ? 'Artesã' : nome.trim();
    userInitial = nomeLimpo[0].toUpperCase();

    final uid = cred.user?.uid;
    if (uid != null) {
      await cred.user?.updateDisplayName(nomeLimpo);
      await _db.collection('users').doc(uid).set({
        'nome': nomeLimpo,
        'email': email.trim(),
        'inicial': userInitial,
        'criadoEm': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<List<ReceitaItem>> listarReceitas() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('receitas')
        .orderBy('criadoEm', descending: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ReceitaItem.fromJson(data);
    }).toList();
  }

  static Future<List<CarreiraItem>> calcularPreview(List<CarreiraItem> carreiras) async {
    int saldoAnterior = 0;
    for (final c in carreiras) {
      final pontos = _calcularPontosCarreira(c.instrucao, saldoAnterior);
      c.saldoPontos = pontos;
      if (pontos > 0) saldoAnterior = pontos;
    }
    return carreiras;
  }

  static int _calcularPontosCarreira(String texto, int saldoAnterior) {
    final limpo = texto.trim().toLowerCase();
    if (limpo.isEmpty) return 0;
    if (limpo.contains('sobre')) return saldoAnterior;

    int total = 0;
    String restante = limpo;

    final grupoRegex = RegExp(r'\(([^)]+)\)\s*[xX*×]\s*(\d+)');
    for (final match in grupoRegex.allMatches(limpo)) {
      final interno = match.group(1) ?? '';
      final mult = int.tryParse(match.group(2) ?? '1') ?? 1;
      total += _contarSegmento(interno) * mult;
    }
    restante = restante.replaceAll(grupoRegex, ' ');

    total += _contarSegmento(restante);
    return total;
  }

  static int _contarSegmento(String segmento) {
    int soma = 0;
    final pontoRegex = RegExp(r'(\d*)\s*(aum|inc|dim|dec|pbx|slst|sl|mpa|hdc|pa|dc|pb|sc)\b');
    for (final match in pontoRegex.allMatches(segmento)) {
      final qtd = int.tryParse(match.group(1) ?? '') ?? 1;
      final tipo = match.group(2) ?? '';
      if (tipo == 'aum' || tipo == 'inc') {
        soma += qtd * 2;
      } else {
        soma += qtd;
      }
    }
    return soma;
  }

  static Future<ReceitaItem> criarReceita({
    required String titulo,
    required String nivel,
    required String descricao,
    required List<CarreiraItem> carreiras,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    final calculadas = await calcularPreview(carreiras);
    final payload = {
      'titulo': titulo,
      'nivel': nivel,
      'descricao': descricao,
      'imagem_url': '',
      'carreiras': calculadas.map((c) => c.toJson()).toList(),
      'criadoEm': FieldValue.serverTimestamp(),
    };

    final docRef = await _db
        .collection('users')
        .doc(uid)
        .collection('receitas')
        .add(payload);

    return ReceitaItem(
      id: docRef.id,
      titulo: titulo,
      nivel: nivel,
      descricao: descricao,
      imagemUrl: '',
      carreiras: calculadas,
    );
  }

  static Future<void> atualizarProgresso(String receitaId, List<bool> status) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _db.collection('users').doc(uid).collection('receitas').doc(receitaId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final lista = List.from(snap.data()?['carreiras'] ?? []);
    for (int i = 0; i < lista.length && i < status.length; i++) {
      lista[i]['concluida'] = status[i];
    }

    await docRef.update({'carreiras': lista});
  }
}
