// Updated by hgmKarunarathna-32611
// UI Implementation by hgmKarunarathna-32611
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_pin_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  final Color _bgColor = const Color(0xFFF2F2F7);
  final Color _inputBgColor = const Color(0xFFE5E5EA);
  final Color _primaryRed = const Color(0xFFE53935);
  final Color _mutedRed = const Color(0xFFE57373);
  final Color _darkTextColor = const Color(0xFF1C1C1E);
  final Color _greyTextColor = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
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

  void _continue() {
    if (_hasText) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPinScreen(phone: '+94 ${_phoneCtrl.text}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: _bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildBackButton(),
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildPhoneInputRow(),
                    const SizedBox(height: 20),
                    _buildSignUpLink(),
                  ],
                ),
              ),
            ),
            _buildBottomButton(bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Login', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text('Please login using your phone number.', style: GoogleFonts.inter(fontSize: 14, color: _greyTextColor)),
      ],
    );
  }

  Widget _buildPhoneInputRow() {
    return Row(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: _inputBgColor, borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('🇱🇰 +94', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(color: _inputBgColor, borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
      child: Text("Don't have an account? Sign Up", style: GoogleFonts.inter(color: _greyTextColor)),
    );
  }

  Widget _buildBottomButton(double bottomInset) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset > 0 ? 10 : 30),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _hasText ? _continue : null,
          style: ElevatedButton.styleFrom(backgroundColor: _hasText ? _primaryRed : _mutedRed),
          child: const Text('Continue', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
