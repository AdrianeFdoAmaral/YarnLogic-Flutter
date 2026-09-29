// scanner_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _image;
  String _resultado = "Selecione uma foto da carreira para analisar.";
  bool _carregando = false;
  final int pontosEsperados = 6;

  Future<void> _selecionarEEnviarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _carregando = true;
        _resultado = "Enviando imagem para a API Flask...";
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:5000/scan'),
        );

        request.files.add(
          await http.MultipartFile.fromPath('foto', _image!.path),
        );

        var responseStream = await request.send();
        var response = await http.Response.fromStream(responseStream);

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          int detectados = data['pontos_detectados'] ?? 0;

          setState(() {
            if (detectados == pontosEsperados) {
              _resultado = "\u2705 CARREIRA VÁLIDA!\n\nPontos Detectados: $detectados\nPontos Esperados: $pontosEsperados";
            } else {
              int diff = (detectados - pontosEsperados).abs();
              _resultado = "\u26A0 DIVERGÊNCIA!\n\nPontos Detectados: $detectados\nPontos Esperados: $pontosEsperados\nDiferença: $diff ponto(s)";
            }
          });
        } else {
          setState(() {
            _resultado = "\u274C Erro ao processar no servidor Flask.";
          });
        }
      } catch (e) {
        setState(() {
          _resultado = "\u26A0 Erro de conexão com a API Flask.\nDetalhes: $e";
        });
      } finally {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YarnLogic - Scanner (Flutter)"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Image.file(_image!, height: 250, fit: BoxFit.contain)
            else
              const Icon(Icons.image, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            if (_carregando) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selecionarEEnviarImagem,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Selecionar / Tirar Foto"),
            ),
            const Divider(height: 40),
            Text(
              _resultado,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}