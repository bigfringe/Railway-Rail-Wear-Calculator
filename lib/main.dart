import 'package:flutter/material.dart';

void main() => runApp(const RailWearApp());

class RailWearApp extends StatelessWidget {
  const RailWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFC928);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rail Wear Calculator',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF050A0E),
        colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
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
  static const gold = Color(0xFFFFC928);
  static const panel = Color(0xFF0A1720);
  static const border = Color(0xFF29485C);

  final headWear = TextEditingController();
  final sideWear = TextEditingController();
  final measuredDepth = TextEditingController();
  String? railType;
  double? headResult;
  double? sideResult;
  double? depthResult;

  static const railTypes = <String>[
    '60E1 / 60E2 plain line',
    '60E1 / 60E2 S&C',
    '56E1 / 113A',
    '109 / 110A',
    '98 FB',
    '95 / 97.5 BH',
    '85 BH',
  ];

  static const minimumDepth = <String, double>{
    '60E1 / 60E2 plain line': 158,
    '60E1 / 60E2 S&C': 162,
    '56E1 / 113A': 145,
    '109 / 110A': 145,
    '98 FB': 131,
    '95 / 97.5 BH': 131,
    '85 BH': 127,
  };

  @override
  void dispose() {
    headWear.dispose();
    sideWear.dispose();
    measuredDepth.dispose();
    super.dispose();
  }

  void calculate() {
    final head = double.tryParse(headWear.text);
    final side = double.tryParse(sideWear.text);
    final depth = double.tryParse(measuredDepth.text);
    if (railType == null || head == null || side == null || depth == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select the rail type and enter all three measurements.'),
      ));
      return;
    }
    setState(() {
      headResult = head;
      sideResult = side;
      depthResult = depth;
    });
  }

  InputDecoration fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    suffixText: 'mm',
    filled: true,
    fillColor: const Color(0xFF07121A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF52738A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: gold, width: 2),
    ),
  );

  Widget measurementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF111F29), borderRadius: BorderRadius.circular(14), border: Border.all(color: border)), child: Icon(icon, size: 27, color: gold)),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Color(0xFFAAC4D8))),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            decoration: fieldDecoration('0.0'),
          ),
        ),
      ]),
    );
  }

  Widget infoTile(IconData icon, String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1720),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(height: 7),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB9CBD8), fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final hasResult = headResult != null && sideResult != null && depthResult != null && railType != null;
    final lateralLoss = hasResult ? 9.0 - (0.5 * sideResult!) : 0.0;
    final sidewornMinDepth = hasResult ? minimumDepth[railType]! + lateralLoss : 0.0;
    final rawGrindAvailable = hasResult ? depthResult! - sidewornMinDepth : 0.0;
    final grindAvailable = rawGrindAvailable > 0 ? rawGrindAvailable.floor() : 0;
    final lowAllowance = hasResult && grindAvailable > 0 && grindAvailable < 5;
    final limitReached = hasResult && grindAvailable <= 0;
    final sideOk = !limitReached;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Rail Wear ', style: TextStyle(color: gold)),
                    TextSpan(text: 'Calculator'),
                  ]), style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('UK RAIL STANDARDS • RULE OF 9',
                    style: TextStyle(letterSpacing: 2.2, color: Color(0xFFB8C9D7), fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(width: 12),
              const Text.rich(TextSpan(children: [
                TextSpan(text: 'Think ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Atlas', style: TextStyle(color: gold)),
              ]), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF111F29), borderRadius: BorderRadius.circular(14), border: Border.all(color: border)), child: const Icon(Icons.train, size: 27, color: gold)),
                const SizedBox(width: 10),
                const Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Rail type', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  Text('Select the rail type', style: TextStyle(color: Color(0xFFAAC4D8))),
                ])),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: DropdownButtonFormField<String>(
                    value: railType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Select rail type',
                      filled: true,
                      fillColor: const Color(0xFF07121A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF52738A))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: gold, width: 2)),
                    ),
                    items: railTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (value) => setState(() { railType = value; headResult = null; sideResult = null; depthResult = null; }),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            measurementCard(icon: Icons.height, title: 'Head wear (mm)', subtitle: 'Vertical wear depth', controller: headWear),
            measurementCard(icon: Icons.compare_arrows, title: 'Sidewear reading', subtitle: 'NR4 step gauge reading (S)', controller: sideWear),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.straighten, color: gold, size: 24),
                  SizedBox(width: 10),
                  Text('NR4 STEPPED SIDEWEAR GAUGE',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: Color(0xFF101820),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/nr4_gauge.jpg',
                      height: 120,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ]),
            ),
            measurementCard(icon: Icons.height, title: 'Rail depth', subtitle: 'Actual remaining rail depth', controller: measuredDepth),
            const SizedBox(height: 8),
            SizedBox(
              height: 66,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: calculate,
                icon: const Icon(Icons.calculate, size: 29),
                label: const Text('CALCULATE', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              ),
            ),
            if (hasResult) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF071A12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: sideOk ? const Color(0xFF00D84A) : Colors.redAccent, width: 2),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(sideOk ? Icons.check_circle : Icons.warning_rounded,
                      color: sideOk ? const Color(0xFF00E653) : Colors.redAccent, size: 42),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(sideOk ? 'RESULT' : 'DO NOT GRIND',
                        style: TextStyle(color: sideOk ? const Color(0xFF00E653) : Colors.redAccent,
                          fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 3),
                      Text(sideOk ? 'SIDEWEAR ASSESSMENT' : 'SIDE WEAR LIMIT REACHED',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                    ])),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: (lowAllowance || limitReached) ? const Color(0xFF3A0909) : const Color(0xFF0A2A17),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: (lowAllowance || limitReached) ? Colors.redAccent : const Color(0xFF00D84A), width: 2),
                    ),
                    child: (lowAllowance || limitReached)
                      ? FlashingWarning(text: limitReached ? 'DO NOT GRIND — LIMIT REACHED' : 'DO NOT GRIND MORE THAN: $grindAvailable mm')
                      : Text('DO NOT GRIND MORE THAN: $grindAvailable mm', textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF00E653))),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    infoTile(Icons.railway_alert, 'Rail type', railType!),
                    const SizedBox(width: 8),
                    infoTile(Icons.straighten, 'Minimum depth', '${sidewornMinDepth.toStringAsFixed(1)} mm'),
                    const SizedBox(width: 8),
                    infoTile(Icons.settings, 'Lateral head loss (L)', '${lateralLoss.toStringAsFixed(1)} mm'),
                  ]),
                ]),
              ),
            ],
            const SizedBox(height: 18),
            const Text('RAIL DEPTH & SIDEWEAR', style: TextStyle(color: gold, fontSize: 13, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('⚠  DEFECT GUIDANCE', style: TextStyle(fontWeight: FontWeight.w800)),
                  Divider(),
                  Text('Wheel burns                         Max 3 mm'),
                  Divider(),
                  Text('Squats                                  Max 3 mm'),

                ]),
              )),
              const SizedBox(width: 10),
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('📖  QUICK REFERENCE', style: TextStyle(fontWeight: FontWeight.w800)),
                  Divider(),
                  Text('NR4 relationship\nL = 9 − 0.5S'),
                  Divider(),
                  Text('Pre-1979 rail\nUltrasonic test required before grinding'),
                  Divider(),
                  Text('Sideworn minimum depth\nBase minimum + L'),
                ]),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}


class FlashingWarning extends StatefulWidget {
  final String text;
  const FlashingWarning({super.key, required this.text});
  @override
  State<FlashingWarning> createState() => _FlashingWarningState();
}

class _FlashingWarningState extends State<FlashingWarning> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.35, end: 1.0).animate(_controller),
    child: Text(widget.text, textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.redAccent)),
  );
}
