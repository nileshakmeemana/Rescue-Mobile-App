import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const _notifications = [
    {
      'title': 'Road Accident',
      'desc':
          'The incident involved the vehicle CAZ 6543, which was involved in a collision between a car and a motorcycle.'
    },
    {
      'title': 'Road Accident',
      'desc':
          'The incident involved the vehicle CAZ 6543, which was involved in a collision between a car and a motorcycle.'
    },
    {
      'title': 'Road Accident',
      'desc':
          'The incident involved the vehicle CAZ 6543, which was involved in a collision between a car and a motorcycle.'
    },
    {
      'title': 'Road Accident',
      'desc':
          'The incident involved the vehicle CAZ 6543, which was involved in a collision between a car and a motorcycle.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 18, color: Color(0xFF1C1C1E)),
            onPressed: () => Navigator.pop(context)),
        title: Text('Notification',
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E))),
        titleSpacing: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final n = _notifications[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 8)
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n['title']!,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE53935))),
              const SizedBox(height: 6),
              Text(n['desc']!,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF1C1C1E),
                      height: 1.5)),
            ]),
          );
        },
      ),
    );
  }
}
