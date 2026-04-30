import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/app_state.dart';
import '../services/user_state.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    
    Future.delayed(const Duration(milliseconds: 2200), _route);
  }

  Future<void> _route() async {
    if (!mounted) return;
    final user = FirebaseService().currentUser;
    if (user != null) {
      // Already logged in — load profile into AppState then go home
      await _loadUserData(user);
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => const OnboardingScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child)));
      }
    }
  }

  Future<void> _loadUserData(User user) async {
    try {
      final profile = await FirebaseService().getUserProfile();
      if (profile != null) {
        final name = profile['name'] as String? ?? '';
        final photoUrl = profile['photoURL'] as String? ?? '';
        final region = profile['region'] as String? ?? '';
        final address = profile['address'] as String? ?? '';
        if (name.isNotEmpty) {
          UserState().setName(name);
        }
        if (photoUrl.isNotEmpty) {
          UserState().setProfileImage(NetworkImage(photoUrl));
        }
        final location = address.isNotEmpty ? address : region;
        if (location.isNotEmpty) {
          AppState().setLocation(location);
        }
      }
      await FirebaseService().initializePushNotifications();
    } catch (_) {}
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
              opacity: _fade,
              child: ScaleTransition(
                  scale: _scale,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset('assets/images/rescue_logo.png',
                        width: 96,
                        height: 96,
                        errorBuilder: (_, __, ___) => const _LifebuoyIcon()),
                    const SizedBox(height: 16),
                    const Text('Rescue',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ])))),
    );
  }
}

class _LifebuoyIcon extends StatelessWidget {
  const _LifebuoyIcon();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(96, 96), painter: _P());
}

class _P extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2, cy = s.height / 2, r = s.width / 2 - 2;
    final i = r * 0.45;
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    final rp = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.fill;
    for (int q = 0; q < 4; q++) {
      if (q % 2 == 0) {
        final p = Path()
          ..moveTo(cx, cy)
          ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r),
              q * (3.14159 / 2), 3.14159 / 2, false)
          ..close();
        canvas.drawPath(p, rp);
      }
    }
    canvas.drawCircle(Offset(cx, cy), i, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(cx, cy),
        i * 0.6,
        Paint()
          ..color = const Color(0xFFEF5350)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i * 0.55);
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    canvas.drawCircle(
        Offset(cx, cy),
        i,
        Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_) => false;
}
