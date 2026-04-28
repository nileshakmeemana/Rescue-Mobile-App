// Updated by hgmKarunarathna-32611
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';

class LoginPinScreen extends StatefulWidget {
  final String phone;
  const LoginPinScreen({super.key, required this.phone});
  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter PIN for ${widget.phone}', style: GoogleFonts.inter(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen())),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
