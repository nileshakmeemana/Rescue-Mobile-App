import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';
import '../widgets/notification_bell.dart';
import 'home_screen.dart';
import 'help_coming_screen.dart';

enum EmergencyScreenMode { fromSOS, fromSubmit }

class EmergencyNumbersScreen extends StatelessWidget {
  final EmergencyScreenMode mode;
  const EmergencyNumbersScreen({super.key,
      this.mode = EmergencyScreenMode.fromSubmit});

  Future<void> _callNumber(BuildContext ctx, String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text('Calling $number...',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2)));
    }
    if (mode == EmergencyScreenMode.fromSOS && ctx.mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (ctx.mounted) {
          Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => const HelpComingScreen(
                  mode: HelpComingMode.returnHome)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (_, __) {
        final numbers = AppState().emergencyNumbers;
        final region = AppState().region;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF2F2F7),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: mode == EmergencyScreenMode.fromSOS
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18,
                        color: Color(0xFF1C1C1E)),
                    onPressed: () => Navigator.pop(context))
                : null,
            automaticallyImplyLeading: false,
            actions: const [NotificationBell(), SizedBox(width: 4)],
          ),

          // Fix 1: button pinned to bottom via bottomNavigationBar
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (mode == EmergencyScreenMode.fromSOS) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                          (r) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // Fix 1: red background matching other buttons
                    backgroundColor: const Color(0xFFE53935),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  child: Text(
                    mode == EmergencyScreenMode.fromSOS
                        ? 'Go Back' : 'Go to Home',
                    style: GoogleFonts.inter(fontSize: 16,
                        fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ),

          body: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Emergency Phone Numbers',
                    style: GoogleFonts.inter(fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1C1E))),
                if (region.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 14,
                        color: Color(0xFFE53935)),
                    const SizedBox(width: 4),
                    Text('Showing numbers for $region',
                        style: GoogleFonts.inter(fontSize: 12,
                            color: const Color(0xFFE53935),
                            fontWeight: FontWeight.w500)),
                  ]),
                ],
              ]),
            ),

            Expanded(child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: numbers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final n = numbers[i];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(n['number']!, style: GoogleFonts.inter(
                        fontSize: 26, fontWeight: FontWeight.w800,
                        color: const Color(0xFFE53935))),
                    const SizedBox(height: 4),
                    Text(n['label']!, style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF1C1C1E))),
                    const SizedBox(height: 12),
                    SizedBox(height: 36, width: 110,
                      child: ElevatedButton(
                        onPressed: () => _callNumber(context, n['number']!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                        child: Text('Call Now', style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: Colors.white)))),
                  ]),
                );
              },
            )),
          ]),
        );
      },
    );
  }
}
