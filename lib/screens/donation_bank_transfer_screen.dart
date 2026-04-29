import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'donation_source.dart';
import 'donation_success_screen.dart';
import '../services/user_state.dart';

class DonationBankTransferScreen extends StatefulWidget {
  final String amount;
  final Map<String, String> userData;
  final DonationSource source;

  const DonationBankTransferScreen({
    super.key,
    required this.amount,
    required this.userData,
    required this.source,
  });

  @override
  State<DonationBankTransferScreen> createState() =>
      _DonationBankTransferScreenState();
}

class _DonationBankTransferScreenState
    extends State<DonationBankTransferScreen> {
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.amount;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final amount = _amountCtrl.text.replaceAll(',', '').trim();
    if (amount.isEmpty ||
        int.tryParse(amount) == null ||
        int.parse(amount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter a valid transfer amount.'),
        backgroundColor: Color(0xFFE53935),
      ));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationSuccessScreen(
          amount: amount,
          transactionLabel: widget.source.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userData['name'] ?? 'Nilesh Akmeemana';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 20, color: Color(0xFF1C1C1E)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Direct Bank Transfer',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transfer directly using the bank details below.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: UserState(),
                          builder: (_, __) {
                            final profileImage = UserState().profileImage;
                            return Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC7C7CC),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: profileImage == null
                                    ? const SizedBox.shrink()
                                    : Image(
                                        image: profileImage,
                                        fit: BoxFit.cover,
                                        width: 54,
                                        height: 54,
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C2C2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.source.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank details',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                              label: 'Bank', value: 'INTERNATIONAL BANK'),
                          const SizedBox(height: 10),
                          _DetailRow(label: 'Account name', value: 'Rescue'),
                          const SizedBox(height: 10),
                          _DetailRow(
                              label: 'Account number', value: '1234 5678 9012'),
                          const SizedBox(height: 10),
                          _DetailRow(label: 'Branch', value: 'Colombo Main'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transfer details',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              prefixText: 'LKR ',
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _referenceCtrl,
                            decoration: InputDecoration(
                              labelText: 'Reference / note',
                              filled: true,
                              fillColor: const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE10600),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1E),
            ),
          ),
        ),
      ],
    );
  }
}
