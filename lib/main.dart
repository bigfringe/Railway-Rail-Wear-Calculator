import 'package:flutter/material.dart';

void main() => runApp(const RailWearApp());

class RailLimit {
  final String section;
  final double minimumDepth;
  const RailLimit(this.section, this.minimumDepth);
}

// Baseline GB compatibility depths from RSSB GCRT5021 Issue 6, Table 19.
// Network Rail-specific operational rules must still be verified before field use.
const railLimits = <RailLimit>[
  RailLimit('60E1 / 60E2', 158),
  RailLimit('109 / 110A / 56E1 (113A)', 145),
  RailLimit('98 FB / 95 & 97.5 BH', 131),
  RailLimit('85 BH', 127),
];

class RailWearApp extends StatelessWidget {
  const RailWearApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Railway Rail Wear Calculator',
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF111417),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber, brightness: Brightness.dark),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    ),
    home: const CalculatorPage(),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  RailLimit? rail;
  final depth = TextEditingController();
  final sidewear = TextEditingController();
  final nr4Step = TextEditingController();
  bool nearFishplate = false;
  bool pre1976 = false;
  String speedBand = 'Up to 80 mph';

  @override
  void dispose() { depth.dispose(); sidewear.dispose(); nr4Step.dispose(); super.dispose(); }

  void calculate() {
    final measured = double.tryParse(depth.text);
    final lateralLoss = double.tryParse(sidewear.text);
    final step = double.tryParse(nr4Step.text);
    if (rail == null || measured == null || lateralLoss == null || step == null) {
      return showResult('Enter rail section, measured rail depth, lateral head loss and NR4 step reading.');
    }
    final ruleOf9Loss = 9 - (0.5 * step);
    if ((lateralLoss - ruleOf9Loss).abs() > 0.25) {
      return showResult('CHECK READINGS: NR4 step reading gives L = 9 - 0.5S = \${ruleOf9Loss.toStringAsFixed(1)} mm, but entered lateral head loss is \${lateralLoss.toStringAsFixed(1)} mm. Recheck the measurements before continuing.');
    }
    if (pre1976) {
      return showResult('STOP: pre-1976 rail selected. U8 or equivalent approved ultrasonic testing must confirm no actionable internal defects before specific surface grinding or milling for surface damage.');
    }
    final requiredDepth = rail!.minimumDepth + (nearFishplate ? lateralLoss : 0);
    final margin = measured - requiredDepth;
    String sidewearAction;
    if (speedBand == 'Over 80 to 125 mph' && lateralLoss >= 9) {
      sidewearAction = 'SIDEWEAR LIMIT REACHED: legacy mod09 specifies an 80 mph ESR and rail replacement/transpose action.';
    } else if (speedBand == 'Up to 80 mph' && lateralLoss >= 9) {
      sidewearAction = 'SIDEWEAR LIMIT REACHED: legacy mod09 specifies replacement or transposition.';
    } else {
      sidewearAction = 'Sidewear is below the 9 mm legacy limit for the selected speed band.';
    }
    final status = margin < 0 ? 'BELOW BASELINE DEPTH' : 'BASELINE DEPTH CHECK PASSED';
    showResult('$status\n\n$sidewearAction\n\nRequired depth: ${requiredDepth.toStringAsFixed(1)} mm\nMeasured depth: ${measured.toStringAsFixed(1)} mm\nMargin: ${margin.toStringAsFixed(1)} mm\n\nThis is a GB compatibility depth check only. Rule-of-9 measurement consistency is checked using L = 9 - 0.5S. Grinding allowance remains separate and locked until its operational limits are verified.');
  }

  void showResult(String text) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Rail Wear Result'),
      content: Text(text),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Rail Wear Calculator'),
      actions: const [Padding(padding: EdgeInsets.all(16), child: Center(child: Text('Think Atlas', style: TextStyle(fontWeight: FontWeight.bold))))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('RAIL WEAR', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('GB baseline depth check. Operational grinding limits remain locked pending verification.'),
        const SizedBox(height: 22),
        DropdownButtonFormField<RailLimit>(
          value: rail,
          decoration: const InputDecoration(labelText: 'Rail section'),
          items: railLimits.map((r) => DropdownMenuItem(value: r, child: Text(r.section))).toList(),
          onChanged: (v) => setState(() => rail = v),
        ),
        const SizedBox(height: 16),
        TextField(controller: depth, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Measured rail depth (mm)')),
        const SizedBox(height: 16),
        TextField(controller: sidewear, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Sidewear / lateral head loss (mm)')),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Within 9 m of fishplate'),
          subtitle: const Text('Adds lateral head loss to baseline minimum depth'),
          value: nearFishplate,
          onChanged: (v) => setState(() => nearFishplate = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Rail manufactured before 1979'),
          subtitle: const Text('U8 or equivalent approved ultrasonic test required before specific surface grinding/reprofiling'),
          value: pre1976,
          onChanged: (v) => setState(() => pre1976 = v),
        ),
        const SizedBox(height: 18),
        SizedBox(height: 58, child: FilledButton.icon(onPressed: calculate, icon: const Icon(Icons.calculate), label: const Text('CALCULATE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 24),
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Rule-of-9 measurement check is enabled. Permissible grinding/reprofiling remains disabled until the applicable controlled operational limits are verified.'))),
      ],
    ),
  );
}
