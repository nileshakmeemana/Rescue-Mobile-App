import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'donation_bank_transfer_screen.dart';
import 'donation_source.dart';
import 'donation_card_details_screen.dart';
import '../services/user_state.dart';

class DonationAmountScreen extends StatefulWidget {
  final Map<String, String> userData;
  const DonationAmountScreen({super.key, required this.userData});

  @override
  State<DonationAmountScreen> createState() => _DonationAmountScreenState();
}

class _DonationAmountScreenState extends State<DonationAmountScreen> {
  final _amountCtrl = TextEditingController(text: '1000');
  final _noteCtrl = TextEditingController();
  int _selectedSource = 0;

  final List<DonationSource> _sources = const [
    DonationSource(
      type: DonationSourceType.cardPayments,
      title: 'Card payments',
      subtitle: 'Pay using a debit or credit card',
    ),
    DonationSource(
      type: DonationSourceType.directBankTransfer,
      title: 'Direct bank transfer',
      subtitle: 'Transfer directly to Rescue bank account',
    ),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final amount = _amountCtrl.text.replaceAll(',', '').trim();
    if (amount.isEmpty ||
        int.tryParse(amount) == null ||
        int.parse(amount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter a valid donation amount.'),
        backgroundColor: Color(0xFFE53935),
      ));
      return;
    }

    final source = _sources[_selectedSource];
    if (source.type == DonationSourceType.cardPayments) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationCardDetailsScreen(
            amount: amount,
            userData: widget.userData,
            source: source,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationBankTransferScreen(
          amount: amount,
          userData: widget.userData,
          source: source,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userData['name'] ?? 'Nilesh Akmeemana';
    final phone = widget.userData['phone'] ?? '+94 123 414 212';

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
                      'Send Donations',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: UserState(),
                      builder: (_, __) {
                        final profileImage = UserState().profileImage;
                        return Row(
                          children: [
                            Container(
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
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C2C2E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  phone,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E),
                      ),
                      decoration: InputDecoration(
                        prefixText: 'LKR ',
                        prefixStyle: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1E),
                        ),
                        hintText: 'Enter the amount',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFAEAEB2),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Transaction source',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_sources.length, (index) {
                      final source = _sources[index];
                      final selected = _selectedSource == index;
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: index == _sources.length - 1 ? 0 : 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => _selectedSource = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                _SourceIcon(type: source.type),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        source.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1C1C1E),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        source.subtitle,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF8E8E93),
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFFE53935)
                                          : const Color(0xFFAEAEB2),
                                      width: 2,
                                    ),
                                  ),
                                  child: selected
                                      ? Center(
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 28),
                    Container(
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _noteCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Note',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFAEAEB2),
                                ),
                              ),
                            ),
                          ),
                          const Icon(Icons.edit_outlined,
                              color: Color(0xFFAEAEB2)),
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

class _SourceIcon extends StatelessWidget {
  final DonationSourceType type;

  const _SourceIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == DonationSourceType.cardPayments) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFEFEFF4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.credit_card_outlined,
          size: 22,
          color: Color(0xFF1C1C1E),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFF4),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.account_balance_outlined,
          size: 22, color: Color(0xFF1C1C1E)),
    );
  }
}
