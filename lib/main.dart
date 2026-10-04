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
        scaffoldBackgroundColor: const Color(0xFF0B0D0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const RailWearHome(),
    );
  }
}

class RailWearHome extends StatefulWidget {
  const RailWearHome({super.key});

  @override
  State<RailWearHome> createState() => _RailWearHomeState();
}

class _RailWearHomeState extends State<RailWearHome> {
  final verticalWear = TextEditingController();
  final sideWear = TextEditingController();
  String? railType;

  static const railTypes = <String>[
    '60E1 / 60E2',
    '56E1 / 113A',
    '109 / 110A',
    '98 FB',
    '95 / 97.5 BH',
    '85 BH',
  ];

  @override
  void dispose() {
    verticalWear.dispose();
    sideWear.dispose();
    super.dispose();
  }

  void calculate() {
    final vertical = double.tryParse(verticalWear.text);
    final side = double.tryParse(sideWear.text);

    if (railType == null || vertical == null || side == null) {
      _show('Please select the rail type and enter both wear readings.');
      return;
    }

    _show(
      'Rail type: $railType\n'
      'Vertical wear: ${vertical.toStringAsFixed(1)} mm\n'
      'Side wear: ${side.toStringAsFixed(1)} mm\n\n'
      'Measurements recorded. The final permissible-wear result will be enabled '
      'only after the applicable controlled limits for this rail type are verified.',
    );
  }

  void _show(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rail Wear Result'),
        content: Text(message, style: const TextStyle(fontSize: 18)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rail Wear Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                'Think Atlas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'RAIL WEAR',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the rail type and enter the two measured wear readings.',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: railType,
              decoration: const InputDecoration(labelText: 'Rail type'),
              items: railTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => railType = value),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: verticalWear,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Vertical wear (mm)'),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: sideWear,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Side wear (mm)'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 64,
              child: FilledButton.icon(
                onPressed: calculate,
                icon: const Icon(Icons.calculate, size: 28),
                label: const Text(
                  'CALCULATE',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Prototype: measurement entry is active. Safety-critical '
                  'permissible wear and grinding limits will only be activated '
                  'from verified controlled railway data.',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
