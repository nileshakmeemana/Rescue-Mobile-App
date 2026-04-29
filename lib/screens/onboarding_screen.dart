import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING — Image 4 (slide 1) + Image 5 (slide 3 / last slide)
// Light bg with warm gradient blob behind character, headline, dots, button
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPage {
  final String character;  // asset path
  final String headline;
  final String headlineHighlight; // red part
  final bool highlightAtEnd;

  const _OnboardingPage({
    required this.character,
    required this.headline,
    required this.headlineHighlight,
    this.highlightAtEnd = true,
  });
}

const List<_OnboardingPage> _pages = [
  _OnboardingPage(
    character: 'assets/images/character_man.png',
    headline: 'One App for\nEvery ',
    headlineHighlight: 'Emergency',
    highlightAtEnd: true,
  ),
  _OnboardingPage(
    character: 'assets/images/character_man.png',
    headline: 'Fast ',
    headlineHighlight: 'Response,',
    highlightAtEnd: true,
  ),
  _OnboardingPage(
    character: 'assets/images/character_woman.png',
    headline: 'Your Safety\nOne Tap Away',
    headlineHighlight: '',
    highlightAtEnd: false,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isLast => _current == _pages.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    } else {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: "Rescue" label
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Rescue',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ),

            // ── PageView (character + gradient blob)
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _CharacterPage(
                  page: _pages[i],
                  screenWidth: size.width,
                ),
              ),
            ),

            // ── Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFE53935)
                        : const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // ── Headline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _HeadlineText(page: _pages[_current]),
            ),
            const SizedBox(height: 32),

            // ── Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Primary button — always shown
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // "Don't Have an Account? Sign Up" — only on last page
                  if (_isLast) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF8E8E93),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Log in',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE53935),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Character page with warm radial gradient blob
// ─────────────────────────────────────────────────────────────────────────────
class _CharacterPage extends StatelessWidget {
  final _OnboardingPage page;
  final double screenWidth;

  const _CharacterPage({required this.page, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Warm gradient blob background
        Positioned(
          top: 0, left: 0, right: 0, bottom: 0,
          child: CustomPaint(painter: _BlobPainter()),
        ),
        // Character image
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Image.asset(
            page.character,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person,
              size: screenWidth * 0.55,
              color: const Color(0xFFD1D1D6),
            ),
          ),
        ),
      ],
    );
  }
}

/// Soft warm radial gradient (pinkish-red on left, light coral on right)
class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Left blob
    final leftPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFCDD2).withOpacity(0.8),
          const Color(0xFFFAF9F7).withOpacity(0.0),
        ],
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.7, size.height));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, size.height * 0.45),
        width: size.width * 0.85,
        height: size.height * 0.9,
      ),
      leftPaint,
    );

    // Right blob
    final rightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFCDD2).withOpacity(0.6),
          const Color(0xFFFAF9F7).withOpacity(0.0),
        ],
        radius: 0.7,
      ).createShader(Rect.fromLTWH(
          size.width * 0.4, 0, size.width * 0.6, size.height));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82, size.height * 0.38),
        width: size.width * 0.65,
        height: size.height * 0.7,
      ),
      rightPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Headline with optional red highlight word
// ─────────────────────────────────────────────────────────────────────────────
class _HeadlineText extends StatelessWidget {
  final _OnboardingPage page;
  const _HeadlineText({required this.page});

  @override
  Widget build(BuildContext context) {
    if (page.headlineHighlight.isEmpty) {
      return Text(
        page.headline,
        style: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1C1C1E),
          height: 1.2,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1C1C1E),
          height: 1.2,
        ),
        children: [
          TextSpan(text: page.headline),
          TextSpan(
            text: page.headlineHighlight,
            style: const TextStyle(color: Color(0xFFE53935)),
          ),
        ],
      ),
    );
  }
}