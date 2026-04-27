import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GENERATE PIN  —  Image 3
// 4 rounded square dots + numeric keypad + Continue button
// ─────────────────────────────────────────────────────────────────────────────
class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';

  void _onKey(String val) {
    if (_pin.length < 4) {
      setState(() => _pin += val);
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _onContinue() {
    if (_pin.length == 4) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        size: 20, color: Color(0xFF1C1C1E)),
                  ),
                  const SizedBox(height: 24),
                  Text('Generate PIN',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E),
                      )),
                  const SizedBox(height: 8),
                  Text(
                    'Please create your PIN.\nThis PIN will be used to log in.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF8E8E93),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final filled = i < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: filled
                              ? const Color(0xFFE53935).withOpacity(0.15)
                              : const Color(0xFFDEDEE3),
                          borderRadius: BorderRadius.circular(14),
                          border: filled
                              ? Border.all(
                                  color: const Color(0xFFE53935), width: 2)
                              : null,
                        ),
                        child: filled
                            ? const Center(
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Color(0xFFE53935),
                                ),
                              )
                            : null,
                      );
                    }),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _pin.length == 4 ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    disabledBackgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Numeric keypad
            Container(
              color: const Color(0xFFD1D1D6).withOpacity(0.35),
              child: Column(
                children: [
                  _KeyRow(
                      keys: const ['1', '2', '3'],
                      labels: const ['', 'ABC', 'DEF'],
                      onTap: _onKey),
                  _KeyRow(
                      keys: const ['4', '5', '6'],
                      labels: const ['GHI', 'JKL', 'MNO'],
                      onTap: _onKey),
                  _KeyRow(
                      keys: const ['7', '8', '9'],
                      labels: const ['PQRS', 'TUV', 'WXYZ'],
                      onTap: _onKey),
                  // Bottom row: special, 0, delete
                  Row(
                    children: [
                      // Empty / symbols key
                      Expanded(
                        child: _KeyCell(
                          child: Text('+ * #',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF1C1C1E))),
                          onTap: () {},
                        ),
                      ),
                      Expanded(
                        child: _KeyCell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('0',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF1C1C1E),
                                  )),
                            ],
                          ),
                          onTap: () => _onKey('0'),
                        ),
                      ),
                      // Backspace
                      Expanded(
                        child: _KeyCell(
                          child: const Icon(Icons.backspace_outlined,
                              size: 22, color: Color(0xFF1C1C1E)),
                          onTap: _onDelete,
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
                      Text(keys[i],
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1C1C1E),
                          )),
                      if (labels[i].isNotEmpty)
                        Text(labels[i],
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8E8E93),
                              letterSpacing: 1.2,
                            )),
                    ],
                  ),
                ),
              )),
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
          border: Border.all(color: const Color(0xFFD1D1D6), width: 0.5),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
