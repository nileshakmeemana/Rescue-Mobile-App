enum DonationSourceType { cardPayments, directBankTransfer }

class DonationSource {
  final DonationSourceType type;
  final String title;
  final String subtitle;

  const DonationSource({
    required this.type,
    required this.title,
    required this.subtitle,
  });
}
