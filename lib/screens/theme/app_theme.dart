import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFC62828);
  static const Color primaryDisabled = Color(0xFFE57373);
  static const Color background = Color(0xFFF2F2F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textGray = Color(0xFF8E8E93);
  static const Color inputBg = Color(0xFFE5E5EA);
  static const Color pinDot = Color(0xFFD1D1D6);
  static const Color divider = Color(0xFFD1D1D6);
}

class AppTextStyles {
  static TextStyle title(BuildContext context) => GoogleFonts.inter(
    fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark,
  );
  static TextStyle subtitle(BuildContext context) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textGray, height: 1.5,
  );
  static TextStyle body(BuildContext context) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark,
  );
  static TextStyle label(BuildContext context) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark,
  );
  static TextStyle button(BuildContext context) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white,
  );
  static TextStyle link(BuildContext context) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
  );
  static TextStyle hint(BuildContext context) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textGray,
  );
  static TextStyle appBarTitle(BuildContext context) => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark,
  );
  static TextStyle onboardingHeadline(BuildContext context) => GoogleFonts.inter(
    fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.2,
  );
}
