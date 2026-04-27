import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/notification_bell.dart';
import 'emergency_numbers_screen.dart';
import 'home_screen.dart';

enum HelpComingMode { returnHome, returnEmergency }

class HelpComingScreen extends StatefulWidget {
  final HelpComingMode mode;
  const HelpComingScreen({super.key,
      this.mode = HelpComingMode.returnEmergency});
  @override State<HelpComingScreen> createState() => _HelpComingScreenState();
}

class _HelpComingScreenState extends State<HelpComingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onButton() {
    if (widget.mode == HelpComingMode.returnHome) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (r) => false);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => const EmergencyNumbersScreen(
              mode: EmergencyScreenMode.fromSubmit)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7), elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [NotificationBell(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(children: [
            const Spacer(),
            FadeTransition(opacity: _fade,
              child: ScaleTransition(scale: _scale,
                child: Column(children: [
                  RichText(textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 36,
                          fontWeight: FontWeight.w800, height: 1.15,
                          color: const Color(0xFF1C1C1E)),
                      children: const [
                        TextSpan(text: 'Help',
                            style: TextStyle(color: Color(0xFFE53935))),
                        TextSpan(text: ' is\nOn the Way'),
                      ],
                    )),
                  const SizedBox(height: 52),
                  CustomPaint(size: const Size(120, 120),
                      painter: _LifebuoyPainter()),
                  const SizedBox(height: 20),
                  Text('Rescue', style: GoogleFonts.inter(fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E))),
                ]))),
            const Spacer(),
            SizedBox(width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _onButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
                child: Text(
                  widget.mode == HelpComingMode.returnHome
                      ? 'Return to Home'
                      : 'View Emergency Numbers',
                  style: GoogleFonts.inter(fontSize: 16,
                      fontWeight: FontWeight.w600, color: Colors.white)))),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}

class _LifebuoyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width/2, cy = size.height/2, r = size.width/2-4;
    final inner = r*0.48;
    canvas.drawCircle(Offset(cx,cy), r,
        Paint()..color=Colors.white);
    final rp = Paint()..color=const Color(0xFFEF9A9A);
    for (int i=0; i<4; i++) {
      if (i%2==0) {
        final p=Path()..moveTo(cx,cy)
          ..arcTo(Rect.fromCircle(center:Offset(cx,cy),radius:r),
              i*(3.14159/2),3.14159/2,false)..close();
        canvas.drawPath(p,rp);
      }
    }
    canvas.drawCircle(Offset(cx,cy),inner,
        Paint()..color=Colors.white);
    canvas.drawCircle(Offset(cx,cy),inner*0.62,
        Paint()..color=const Color(0xFFE53935)
          ..style=PaintingStyle.stroke..strokeWidth=inner*0.5);
    canvas.drawCircle(Offset(cx,cy),r,
        Paint()..color=const Color(0xFF2D2D2D)
          ..style=PaintingStyle.stroke..strokeWidth=3);
    canvas.drawCircle(Offset(cx,cy),inner,
        Paint()..color=const Color(0xFF2D2D2D)
          ..style=PaintingStyle.stroke..strokeWidth=2.5);
  }
  @override bool shouldRepaint(_) => false;
}
