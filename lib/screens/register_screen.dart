import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_setup_screen.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REGISTER SCREEN  —  Images 1 & 2
// Phone number input with country code picker (Sri Lanka +94)
// ─────────────────────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _phoneCtrl.addListener(() {
      setState(() => _hasText = _phoneCtrl.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    if (_hasText) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottom),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, size: 20,
                            color: Color(0xFF1C1C1E)),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text('Register',
                          style: GoogleFonts.inter(
                            fontSize: 26, fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1C1E),
                          )),
                      const SizedBox(height: 8),
                      Text(
                        'Please register using your phone number. We may\nuse this number to send you the code.',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF8E8E93), height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Phone input row
                      Row(
                        children: [
                          // Country code box
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E5EA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Flag emoji for Sri Lanka
                                const Text('🇱🇰', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 6),
                                Text('+94',
                                    style: GoogleFonts.inter(
                                      fontSize: 15, fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1C1C1E),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Phone number field
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5EA),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneCtrl,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      style: GoogleFonts.inter(
                                        fontSize: 15, color: const Color(0xFF1C1C1E),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '1234 56 7891',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 15, color: const Color(0xFF8E8E93),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                                      ),
                                      onTap: () => _focusNode.requestFocus(),
                                    ),
                                  ),
                                  if (_hasText)
                                    GestureDetector(
                                      onTap: () => _phoneCtrl.clear(),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: Container(
                                          width: 20, height: 20,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFAEAEB2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, size: 13, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Already have account
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFF8E8E93),
                            ),
                            children: [
                              TextSpan(
                                text: 'Log in',
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Send / Begin button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottom > 0 ? 8 : 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasText ? _send : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasText
                        ? const Color(0xFFE53935)
                        : const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFE57373),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _hasText ? 'Send' : 'Begin',
                    style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
