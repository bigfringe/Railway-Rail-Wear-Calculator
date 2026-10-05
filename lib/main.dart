import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
        scaffoldBackgroundColor: const Color(0xFF03070A),
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
  static const panel = Color(0xFF09141B);
  static const border = Color(0xFF203A49);

  final sideWear = TextEditingController();
  final measuredDepth = TextEditingController();
  final AudioPlayer _hornPlayer = AudioPlayer();
  String? railType;
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

  static const railTypeDisplay = <String, String>{
    '60E1 / 60E2 plain line': '60E1 / 60E2 PLAIN LINE RAIL\nFull rail depth: 172.00 mm\nMinimum rail depth: 158.00 mm\nDifference: 14.00 mm',
    '60E1 / 60E2 S&C': '60E1 / 60E2 S&C RAIL\nFull rail depth: 172.00 mm\nMinimum rail depth: 162.00 mm\nDifference: 10.00 mm',
    '56E1 / 113A': '56E1 / 113A RAIL\nFull rail depth: 158.75 mm\nMinimum rail depth: 145.00 mm\nDifference: 13.75 mm',
    '109 / 110A': '109 / 110A RAIL\nFull rail depth: 158.75 mm\nMinimum rail depth: 145.00 mm\nDifference: 13.75 mm',
    '98 FB': '98 FB RAIL\nFull rail depth: 142.88 mm\nMinimum rail depth: 131.00 mm\nDifference: 11.88 mm',
    '95 / 97.5 BH': '95 / 97.5 BH RAIL\nFull rail depth: ≈145.26 mm\nMinimum rail depth: 131.00 mm\nDifference: ≈14.26 mm',
    '85 BH': '85 BH RAIL\nFull rail depth: 138.91 mm\nMinimum rail depth: 127.00 mm\nDifference: 11.91 mm',
  };

  static const fullDepth = <String, double>{
    '60E1 / 60E2 plain line': 172.00,
    '60E1 / 60E2 S&C': 172.00,
    '56E1 / 113A': 158.75,
    '109 / 110A': 158.75,
    '98 FB': 142.88,
    '95 / 97.5 BH': 145.26,
    '85 BH': 138.91,
  };

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
    sideWear.dispose();
    measuredDepth.dispose();
    _hornPlayer.dispose();
    super.dispose();
  }

  void calculate() {
    final side = double.tryParse(sideWear.text);
    final depth = double.tryParse(measuredDepth.text);
    if (railType == null || side == null || depth == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select the rail type, enter the sidewear reading and actual rail depth.'),
      ));
      return;
    }
    if (side < 0 || side > 18 || depth <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check the measurements entered.'),
      ));
      return;
    }
    final selectedFullDepth = fullDepth[railType]!;
    final selectedMinimumDepth = minimumDepth[railType]!;
    if (depth > selectedFullDepth) {
      setState(() { sideResult = null; depthResult = null; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade800,
        content: Text('INVALID RAIL DEPTH — $railType cannot exceed ${selectedFullDepth.toStringAsFixed(2)} mm. Check rail type and measurement.'),
      ));
      return;
    }
    setState(() {
      sideResult = side;
      depthResult = depth;
    });
    final lateralLoss = 9.0 - (0.5 * side);
    final adjustedMinimum = selectedMinimumDepth + lateralLoss;
    final rawGrindAvailable = depth - adjustedMinimum;
    final grindAvailable = rawGrindAvailable > 0 ? rawGrindAvailable.floor() : 0;
    if (grindAvailable <= 0) {
      _playFailHorn();
    } else {
      _playTrainHorn();
    }
  }

  Future<void> _playTrainHorn() async {
    try {
      await _hornPlayer.stop();
      await _hornPlayer.play(AssetSource('train-horn-2 (1).mp3'));
    } catch (_) {
      // Keep the calculation usable even if audio playback fails.
    }
  }

  Future<void> _playFailHorn() async {
    try {
      await _hornPlayer.stop();
      await _hornPlayer.play(AssetSource('TRNHorn_Train horn 3 (ID 2847)_BigSoundBank.com (1).wav'));
    } catch (_) {
      // Keep the calculation usable even if audio playback fails.
    }
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
    final hasResult = sideResult != null && depthResult != null && railType != null;
    final lateralLoss = hasResult ? 9.0 - (0.5 * sideResult!) : 0.0;
    final sidewornMinDepth = hasResult ? minimumDepth[railType]! + lateralLoss : 0.0;
    final rawGrindAvailable = hasResult ? depthResult! - sidewornMinDepth : 0.0;
    final grindAvailable = rawGrindAvailable > 0 ? rawGrindAvailable.floor() : 0;
    // Exactly 1 mm or more remaining is GREEN / grind permitted.
    // Anything below 1 mm floors to 0 and is RED / do not grind.
    final limitReached = hasResult && grindAvailable < 1;
    final sideOk = !limitReached;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 34),
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Rail Wear ', style: TextStyle(color: gold)),
                    TextSpan(text: 'Calculator'),
                  ]), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
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
                    menuMaxHeight: 520,
                    items: railTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF203A49))),
                        ),
                        child: Text(railTypeDisplay[type]!, style: const TextStyle(fontSize: 12, height: 1.25), maxLines: 4),
                      ),
                    )).toList(),
                    selectedItemBuilder: (context) => railTypes.map((type) => Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          railTypeDisplay[type]!,
                          style: const TextStyle(fontSize: 11, height: 1.15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )).toList(),
                    onChanged: (value) => setState(() { railType = value; sideResult = null; depthResult = null; }),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            measurementCard(icon: Icons.compare_arrows, title: 'Sidewear Reading', subtitle: 'Enter the number shown by the NR4 stepped gauge', controller: sideWear),
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
                Container(
                  height: 150,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: const Color(0xFFE9EDF0), borderRadius: BorderRadius.circular(12)),
                  child: Image.asset('assets/nr4_reference-1.jpg', fit: BoxFit.contain),
                ),
              ]),
            ),
            measurementCard(icon: Icons.height, title: 'Actual Rail Depth', subtitle: 'Enter the total measured rail height', controller: measuredDepth),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: calculate,
                icon: const Icon(Icons.calculate, size: 29),
                label: const Text('CALCULATE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: .4)),
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
                      Text(sideOk ? 'GRINDING RESULT' : 'DO NOT GRIND',
                        style: TextStyle(color: sideOk ? const Color(0xFF00E653) : Colors.redAccent,
                          fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 3),
                      Text(sideOk ? 'GRIND PERMITTED' : 'RAIL LIMIT REACHED',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                    ])),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: limitReached ? const Color(0xFF3A0909) : const Color(0xFF0A2A17),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: limitReached ? Colors.redAccent : const Color(0xFF00D84A), width: 2),
                    ),
                    child: limitReached
                      ? FlashingWarning(text: limitReached ? 'DO NOT GRIND — LIMIT REACHED' : 'DO NOT GRIND MORE THAN: $grindAvailable mm')
                      : Text('DO NOT GRIND MORE THAN: $grindAvailable mm', textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF00E653))),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('REAL RAIL REFERENCE', style: TextStyle(color: gold, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.white,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(72, 18, 34, 18),
                          child: Image.asset('assets/rail_reference.jpg', fit: BoxFit.contain),
                        ),
                        const Positioned(
                          left: 16, top: 38, bottom: 28,
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.arrow_upward, color: Colors.red, size: 27),
                            Expanded(child: SizedBox(width: 3, child: ColoredBox(color: Colors.red))),
                            Icon(Icons.arrow_downward, color: Colors.red, size: 27),
                          ]),
                        ),
                        const Positioned(
                          left: 48, top: 103,
                          child: Text('Rail depth\n(mm)', textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900)),
                        ),
                        const Positioned(
                          right: 52, top: 28,
                          child: Column(children: [
                            Text('Sidewear (mm)', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900)),
                            SizedBox(height: 2),
                            Row(children: [
                              Icon(Icons.arrow_back, color: Colors.red, size: 27),
                              SizedBox(width: 74, height: 3, child: ColoredBox(color: Colors.red)),
                              Icon(Icons.arrow_forward, color: Colors.red, size: 27),
                            ]),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Row(children:[Icon(Icons.height, color: gold, size: 18), SizedBox(width:6), Text('Rail depth', style: TextStyle(fontWeight: FontWeight.w700))]),
                  Row(children:[Icon(Icons.compare_arrows, color: gold, size: 18), SizedBox(width:6), Text('Sidewear', style: TextStyle(fontWeight: FontWeight.w700))]),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            const Text('RAIL DEPTH & SIDEWEAR', style: TextStyle(color: gold, fontSize: 13, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('⚠  DEFECT GUIDANCE', style: TextStyle(fontWeight: FontWeight.w800)),
                  Divider(),
                  Text('Wheel burns                         Max 3 mm'),
                  Divider(),
                  Text('Squats                                  Max 3 mm'),

                ]),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
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
              ),
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


class Nr4GaugePainter extends CustomPainter {
  const Nr4GaugePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final metal = Paint()..shader = const LinearGradient(colors: [Color(0xFFE1E5E7), Color(0xFF92999E), Color(0xFFCDD2D5)]).createShader(Offset.zero & size)..style = PaintingStyle.fill;
    final edge = Paint()..color = const Color(0xFF42484D)..style = PaintingStyle.stroke..strokeWidth = 3;
    final ink = Paint()..color = const Color(0xFF202428)..strokeWidth = 2;
    final body = Path()
      ..moveTo(size.width*.10,size.height*.25)..lineTo(size.width*.42,size.height*.25)
      ..quadraticBezierTo(size.width*.47,size.height*.25,size.width*.49,size.height*.38)
      ..lineTo(size.width*.53,size.height*.70)..lineTo(size.width*.32,size.height*.78)
      ..lineTo(size.width*.27,size.height*.50)..lineTo(size.width*.10,size.height*.50)..close();
    canvas.drawShadow(body, Colors.black, 5, false); canvas.drawPath(body, metal); canvas.drawPath(body, edge); canvas.drawCircle(Offset(size.width*.19,size.height*.38), size.height*.055, Paint()..color=const Color(0xFF6C7479)); canvas.drawCircle(Offset(size.width*.19,size.height*.38), size.height*.055, edge);
    final bar=RRect.fromRectAndRadius(Rect.fromLTWH(size.width*.48,size.height*.36,size.width*.43,size.height*.20),const Radius.circular(4));
    canvas.drawShadow(Path()..addRRect(bar), Colors.black, 3, false); canvas.drawRRect(bar,metal); canvas.drawRRect(bar,edge);
    for(int i=0;i<10;i++){final x=size.width*(.51+i*.041); canvas.drawLine(Offset(x,size.height*.37),Offset(x,size.height*(i.isEven ? .47 : .44)),ink);}
    final tp=TextPainter(textDirection:TextDirection.ltr,textAlign:TextAlign.center);
    tp.text=const TextSpan(text:'NR4-ABT-1004-0001',style:TextStyle(color:Color(0xFF202428),fontSize:12,fontWeight:FontWeight.bold));tp.layout();tp.paint(canvas,Offset(size.width*.18,size.height*.32));
    tp.text=const TextSpan(text:'SIDE WEAR  •  STEPPED GAUGE',style:TextStyle(color:Color(0xFF202428),fontSize:11,fontWeight:FontWeight.bold));tp.layout();tp.paint(canvas,Offset(size.width*.56,size.height*.62));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}

class RailProfilePainter extends CustomPainter {
  const RailProfilePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rail=Paint()..color=const Color(0xFFB8BDC1);
    final line=Paint()..color=const Color(0xFFFFC928)..strokeWidth=4..strokeCap=StrokeCap.round;
    final cx=size.width*.5;
    canvas.drawShadow(Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx-62,22,124,34),const Radius.circular(14))), Colors.black, 7, false);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx-62,22,124,34),const Radius.circular(14)),rail);
    canvas.drawRect(Rect.fromLTWH(cx-17,52,34,82),rail);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx-72,130,144,30),const Radius.circular(8)),rail);
    canvas.drawLine(Offset(cx-100,24),Offset(cx-100,158),line);
    canvas.drawLine(Offset(cx-108,34),Offset(cx-100,24),line);canvas.drawLine(Offset(cx-92,34),Offset(cx-100,24),line);
    canvas.drawLine(Offset(cx-108,148),Offset(cx-100,158),line);canvas.drawLine(Offset(cx-92,148),Offset(cx-100,158),line);
    canvas.drawLine(Offset(cx+65,39),Offset(cx+145,39),line);
    canvas.drawLine(Offset(cx+135,31),Offset(cx+145,39),line);canvas.drawLine(Offset(cx+135,47),Offset(cx+145,39),line);
    final tp=TextPainter(textDirection:TextDirection.ltr);
    tp.text=const TextSpan(text:'Rail depth',style:TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.bold));tp.layout();tp.paint(canvas,Offset(8,82));
    tp.text=const TextSpan(text:'Sidewear',style:TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.bold));tp.layout();tp.paint(canvas,Offset(cx+82,55));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
