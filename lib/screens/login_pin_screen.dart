import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN PIN SCREEN
// Same keypad UI as Generate PIN but labelled "Enter PIN"
// Shows the phone number the user entered for context
// On correct PIN → navigates to WelcomeScreen
// ─────────────────────────────────────────────────────────────────────────────
class LoginPinScreen extends StatefulWidget {
  final String phone;
  const LoginPinScreen({super.key, required this.phone});

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _hasError = false;

  // shake animation for wrong PIN
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String val) {
    if (_pin.length < 4) {
      setState(() {
        _pin += val;
        _hasError = false;
      });
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _hasError = false;
      });
    }
  }

  void _onLogin() {
    if (_pin.length == 4) {
      // For demo: any 4-digit PIN is accepted
      // In production, validate against stored/server PIN
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (route) => false, // clear the whole stack
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        size: 20, color: Color(0xFF1C1C1E)),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Enter PIN',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle with phone number
                  RichText(
                    text: TextSpan(
                      text: 'Enter your PIN for\n',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF8E8E93),
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: widget.phone,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── PIN dots with shake on error
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0),
                      child: child,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final filled = i < _pin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _hasError
                                ? const Color(0xFFFFEBEE)
                                : filled
                                    ? const Color(0xFFE53935).withOpacity(0.12)
                                    : const Color(0xFFDEDEE3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _hasError
                                  ? const Color(0xFFE53935)
                                  : filled
                                      ? const Color(0xFFE53935)
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: filled
                              ? Center(
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: _hasError
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFFE53935),
                                  ),
                                )
                              : null,
                        );
                      }),
                    ),
                  ),

                  // Error message
                  if (_hasError) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Incorrect PIN. Please try again.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFE53935),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // ── Login button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _pin.length == 4 ? _onLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pin.length == 4
                        ? const Color(0xFFE53935)
                        : const Color(0xFFE57373),
                    disabledBackgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Numeric keypad (identical style to PIN create screen)
            Container(
              color: const Color(0xFFD1D1D6).withOpacity(0.35),
              child: Column(
                children: [
                  _KeyRow(
                    keys: const ['1', '2', '3'],
                    labels: const ['', 'ABC', 'DEF'],
                    onTap: _onKey,
                  ),
                  _KeyRow(
                    keys: const ['4', '5', '6'],
                    labels: const ['GHI', 'JKL', 'MNO'],
                    onTap: _onKey,
                  ),
                  _KeyRow(
                    keys: const ['7', '8', '9'],
                    labels: const ['PQRS', 'TUV', 'WXYZ'],
                    onTap: _onKey,
                  ),
                  Row(
                    children: [
                      // Symbols key (empty / decorative)
                      Expanded(
                        child: _KeyCell(
                          onTap: () {},
                          child: Text(
                            '+ * #',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                      ),
                      // 0
                      Expanded(
                        child: _KeyCell(
                          onTap: () => _onKey('0'),
                          child: Text(
                            '0',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                      ),
                      // Backspace
                      Expanded(
                        child: _KeyCell(
                          onTap: _onDelete,
                          child: const Icon(
                            Icons.backspace_outlined,
                            size: 22,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared keypad widgets ─────────────────────────────────────────────────────

class _KeyRow extends StatelessWidget {
  final List<String> keys;
  final List<String> labels;
  final void Function(String) onTap;

  const _KeyRow(
      {required this.keys, required this.labels, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: _KeyCell(
            onTap: () => onTap(keys[i]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  keys[i],
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                if (labels[i].isNotEmpty)
                  Text(
                    labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8E8E93),
                      letterSpacing: 1.2,
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

class _KeyCell extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _KeyCell({required this.child, required this.onTap});

  @override
  State<_KeyCell> createState() => _KeyCellState();
}

class _KeyCellState extends State<_KeyCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 54,
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFFAEAEB2).withOpacity(0.4)
              : Colors.white,
          border:
              Border.all(color: const Color(0xFFD1D1D6), width: 0.5),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
