import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SETUP PROFILE  —  Image 7
// Name / Email / Address fields, red Continue button
// ─────────────────────────────────────────────────────────────────────────────
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController(text: 'Nilesh Akmeemana');
  final _emailCtrl = TextEditingController(text: 'nilesh@gmail.com');
  final _addressCtrl = TextEditingController(text: 'Colombo 03');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _continue() {
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
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios,
                            size: 20, color: Color(0xFF1C1C1E)),
                      ),
                      const SizedBox(height: 24),
                      Text('Setup Profile',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1C1E),
                          )),
                      const SizedBox(height: 28),
                      _FieldLabel('Name'),
                      const SizedBox(height: 8),
                      _InputField(controller: _nameCtrl),
                      const SizedBox(height: 20),
                      _FieldLabel('Email'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('Address'),
                      const SizedBox(height: 8),
                      _InputField(controller: _addressCtrl),
                    ],
                  ),
                ),
              ),
            ),

            // Red Continue button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottom > 0 ? 8 : 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1C1E),
        ),
      );
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(() {
      setState(() => _hasText = widget.controller.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF1C1C1E),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () => widget.controller.clear(),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFAEAEB2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
