import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class DonationSuccessScreen extends StatefulWidget {
  final String amount;
  final String transactionLabel;

  const DonationSuccessScreen({
    super.key,
    required this.amount,
    required this.transactionLabel,
  });

  @override
  State<DonationSuccessScreen> createState() => _DonationSuccessScreenState();
}

class _DonationSuccessScreenState extends State<DonationSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen(initialTab: 0)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 110,
                height: 110,
                child:
                    Image.asset('assets/images/Tick.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 28),
              Text(
                'You have transferred\nRs. ${widget.amount} to Rescue',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16213E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.transactionLabel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const Spacer(flex: 3),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Donation Details',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      content: Text(
                        'Amount: Rs. ${widget.amount}\nStatus: Successful\nType: ${widget.transactionLabel}',
                        style: GoogleFonts.inter(height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'More Details',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE10600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _goHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE10600),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Finished',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
