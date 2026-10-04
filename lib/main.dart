import 'package:flutter/material.dart';

void main() => runApp(const RailWearApp());

class RailWearApp extends StatelessWidget {
  const RailWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Railway Rail Wear Calculator',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF111417),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String? railType;
  final verticalWear = TextEditingController();
  final sideWear = TextEditingController();
  bool pre1979 = false;

  @override
  void dispose() {
    verticalWear.dispose();
    sideWear.dispose();
    super.dispose();
  }

  void calculate() {
    if (pre1979) {
      _message('Pre-1979 rail: ultrasonic testing is required before grinding/reprofiling.');
      return;
    }
    if (railType == null ||
        double.tryParse(verticalWear.text) == null ||
        double.tryParse(sideWear.text) == null) {
      _message('Enter the rail type, vertical wear and side wear.');
      return;
    }
    _message('Readings recorded. Verified Network Rail limits will be added before operational calculations are enabled.');
  }

  void _message(String text) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rail Wear Result'),
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Railway Rail Wear Calculator'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Think Atlas', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('RAIL WEAR', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter measured rail wear. Safety-critical limits remain locked until verified against the controlled UK railway standard.'),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: railType,
            decoration: const InputDecoration(labelText: 'Rail type'),
            items: const [
              DropdownMenuItem(value: '113A', child: Text('113A')),
              DropdownMenuItem(value: '60E1', child: Text('60E1')),
            ],
            onChanged: (v) => setState(() => railType = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: verticalWear,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Vertical wear (mm)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: sideWear,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Side wear (mm)'),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Rail manufactured before 1979'),
            subtitle: const Text('Ultrasonic test required before grinding/reprofiling'),
            value: pre1979,
            onChanged: (v) => setState(() => pre1979 = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 58,
            child: FilledButton.icon(
              onPressed: calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('CALCULATE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 28),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Defect guidance section and verified Rule-of-9 / minimum-depth tables will be added next. No unverified safety limits are used in this build.'),
            ),
          ),
        ],
      ),
    );
  }
}
