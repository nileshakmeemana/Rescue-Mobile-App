import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN  —  Image 6: Full red bg + lifebuoy logo + "Rescue" text
// ─────────────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Make status bar icons white on red
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE53935),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lifebuoy icon
                Image.asset(
                  'assets/images/rescue_logo.png',
                  width: 96,
                  height: 96,
                  errorBuilder: (_, __, ___) => const _LifebuoyIcon(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rescue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback drawn lifebuoy if asset not found
class _LifebuoyIcon extends StatelessWidget {
  const _LifebuoyIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(96, 96), painter: _LifebuoyPainter());
  }
}

class _LifebuoyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final inner = r * 0.45;

    // White outer circle
    canvas.drawCircle(Offset(cx, cy), r - 2,
        Paint()..color = Colors.white..style = PaintingStyle.fill);

    // Red segments (4 quarters alternating)
    final redPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r - 2),
            i * (3.14159 / 2), 3.14159 / 2, false)
        ..close();
      if (i % 2 == 0) canvas.drawPath(path, redPaint);
    }

    // Inner white circle
    canvas.drawCircle(Offset(cx, cy), inner,
        Paint()..color = Colors.white..style = PaintingStyle.fill);

    // Inner red open circle
    canvas.drawCircle(
      Offset(cx, cy),
      inner * 0.6,
      Paint()
        ..color = const Color(0xFFEF5350)
        ..style = PaintingStyle.stroke
        ..strokeWidth = inner * 0.55,
    );

    // Outline
    canvas.drawCircle(
      Offset(cx, cy), r - 2,
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      Offset(cx, cy), inner,
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
