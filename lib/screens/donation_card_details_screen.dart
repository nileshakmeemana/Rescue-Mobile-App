import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'donation_source.dart';
import 'donation_success_screen.dart';

class DonationCardDetailsScreen extends StatefulWidget {
  final String amount;
  final Map<String, String> userData;
  final DonationSource source;

  const DonationCardDetailsScreen({
    super.key,
    required this.amount,
    required this.userData,
    required this.source,
  });

  @override
  State<DonationCardDetailsScreen> createState() =>
      _DonationCardDetailsScreenState();
}

class _DonationCardDetailsScreenState extends State<DonationCardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _cardHolderCtrl.dispose();
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationSuccessScreen(
          amount: widget.amount,
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
                child: Form(
                  key: _formKey,
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
                        'Card Details',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the card details to donate ${widget.amount} LKR.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SummaryCard(
                          name: name,
                          source: widget.source,
                          amount: widget.amount),
                      const SizedBox(height: 20),
                      _DonationTextField(
                        controller: _cardHolderCtrl,
                        label: 'Card holder name',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter card holder name'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _DonationTextField(
                        controller: _cardNumberCtrl,
                        label: 'Card number',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16)
                        ],
                        validator: (value) {
                          final digits = value?.replaceAll(' ', '') ?? '';
                          return digits.length < 12
                              ? 'Enter a valid card number'
                              : null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _DonationTextField(
                              controller: _expiryCtrl,
                              label: 'Expiry date',
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.datetime,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter expiry'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _DonationTextField(
                              controller: _cvvCtrl,
                              label: 'CVV',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3)
                              ],
                              obscureText: true,
                              validator: (value) =>
                                  value == null || value.trim().length < 3
                                      ? 'Enter CVV'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

class _SummaryCard extends StatelessWidget {
  final String name;
  final DonationSource source;
  final String amount;

  const _SummaryCard(
      {required this.name, required this.source, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            source.title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Donation amount',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              Text(
                'LKR $amount',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const _DonationTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1C1C1E),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF8E8E93)),
        hintStyle: GoogleFonts.inter(color: const Color(0xFFAEAEB2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
      ),
    );
  }
}
