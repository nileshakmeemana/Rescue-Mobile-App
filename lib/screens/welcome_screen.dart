import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME SCREEN — after PIN generation
// Image 1: "Rescue" top · pink blob · man character · 
//          "One App for Every Emergency" · dot indicators · Get Started button
// ─────────────────────────────────────────────────────────────────────────────
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                // ── "Rescue" top label
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Rescue',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                ),

                // ── Character + blob
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _BlobPainter()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Image.asset(
                          'assets/images/character_man.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: size.width * 0.55,
                            color: const Color(0xFFD1D1D6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 0 ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? const Color(0xFFE53935)
                          : const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 24),

                // ── Headline: "One App for Every Emergency"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1C1E),
                        height: 1.18,
                      ),
                      children: const [
                        TextSpan(text: 'One App for\nEvery '),
                        TextSpan(
                          text: 'Emergency',
                          style: TextStyle(color: Color(0xFFE53935)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.22, size.height * 0.46),
        width: size.width * 0.88,
        height: size.height * 0.92,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFCDD2).withOpacity(0.9),
            const Color(0xFFFAF9F7).withOpacity(0.0),
          ],
          radius: 0.75,
        ).createShader(Rect.fromLTWH(0, 0, size.width * 0.7, size.height)),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.84, size.height * 0.36),
        width: size.width * 0.65,
        height: size.height * 0.70,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFCDD2).withOpacity(0.65),
            const Color(0xFFFAF9F7).withOpacity(0.0),
          ],
          radius: 0.7,
        ).createShader(
            Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.6, size.height)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
