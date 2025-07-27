import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const AviatorApp());
}

class AviatorApp extends StatelessWidget {
  const AviatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aviator Simulador',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const AviatorHomePage(),
    );
  }
}

class AviatorHomePage extends StatefulWidget {
  const AviatorHomePage({super.key});

  @override
  State<AviatorHomePage> createState() => _AviatorHomePageState();
}

class _AviatorHomePageState extends State<AviatorHomePage> {
  final List<double> rounds = [];
  final TextEditingController urlController = TextEditingController();
  final TextEditingController manualInputController = TextEditingController();
  bool showWeb = false;
  String strategyAdvice = "";

  double generateRandomRound() {
    final random = Random();
    double roll = random.nextDouble();
    if (roll < 0.5) return double.parse((1 + random.nextDouble() * 2).toStringAsFixed(2));
    if (roll < 0.9) return double.parse((3 + random.nextDouble() * 5).toStringAsFixed(2));
    return double.parse((10 + random.nextDouble() * 90).toStringAsFixed(2));
  }

  void simulateRound() {
    double newRound = generateRandomRound();
    setState(() {
      rounds.insert(0, newRound);
      if (rounds.length > 20) rounds.removeLast();
      strategyAdvice = getStrategySuggestion();
    });
  }

  void addManualRound() {
    try {
      double value = double.parse(manualInputController.text);
      setState(() {
        rounds.insert(0, value);
        if (rounds.length > 20) rounds.removeLast();
        strategyAdvice = getStrategySuggestion();
        manualInputController.clear();
      });
    } catch (_) {}
  }

  String getStrategySuggestion() {
    if (rounds.length < 3) return "Insuficientes datos para análisis.";
    double avg = rounds.take(5).reduce((a, b) => a + b) / (rounds.length < 5 ? rounds.length : 5);
    if (avg < 2) return "Sugerencia: Esperar (rondas bajas recientes)";
    if (avg < 4) return "Sugerencia: Apuesta conservadora (media moderada)";
    return "Sugerencia: Apostar fuerte (media alta reciente)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aviator Simulador')),
      body: showWeb
          ? Column(
              children: [
                Expanded(child: WebViewWidget(controller: WebViewController()..loadRequest(Uri.parse(urlController.text)))),
                ElevatedButton(
                    onPressed: () => setState(() => showWeb = false),
                    child: const Text('Volver'))
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(strategyAdvice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: simulateRound, child: const Text("Simular Ronda")),
                  const SizedBox(height: 10),
                  TextField(
                    controller: manualInputController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Ingresar ronda manual"),
                  ),
                  ElevatedButton(onPressed: addManualRound, child: const Text("Agregar Ronda Manual")),
                  const SizedBox(height: 10),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(labelText: "URL del sitio real del juego"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (Uri.tryParse(urlController.text)?.hasAbsolutePath ?? false) {
                          setState(() => showWeb = true);
                        }
                      },
                      child: const Text("Abrir sitio en app")),
                  const SizedBox(height: 10),
                  const Text("Historial de Rondas:"),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rounds.length,
                      itemBuilder: (_, i) => ListTile(title: Text("${rounds[i]}x")),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
