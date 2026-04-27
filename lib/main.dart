import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/app_state.dart';
import 'services/user_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  AppState(); // initialise singleton
  UserState(); // initialise user state
  runApp(const RescueApp());
}

class RescueApp extends StatelessWidget {
  const RescueApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rescue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935)),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7)),
      home: const SplashScreen(),
    );
  }
}
