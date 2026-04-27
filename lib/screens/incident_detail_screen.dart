import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/notification_bell.dart';

// Fix 2: Incident detail screen — opens when tapping any incident card
class IncidentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> incident;
  final bool canDelete;
  final VoidCallback? onDelete;

  const IncidentDetailScreen({
    super.key,
    required this.incident,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18,
              color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Emergencies', style: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1E))),
        centerTitle: true,
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFFE53935), size: 22),
              onPressed: () {
                showDialog(context: context, builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text('Delete Incident', style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700)),
                  content: Text('Remove this incident report?',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E93))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E93)))),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete?.call();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                      child: Text('Delete', style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600))),
                  ],
                ));
              }),
          const NotificationBell(),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Location + type header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(children: [
                const Icon(Icons.location_on, size: 15,
                    color: Color(0xFFE53935)),
                const SizedBox(width: 5),
                Expanded(child: Text(incident['location'] as String,
                  style: GoogleFonts.inter(fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1C1E)))),
              ]),
              const SizedBox(height: 10),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(incident['type'] as String,
                  style: GoogleFonts.inter(fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE53935)))),
              const SizedBox(height: 12),
              Text(incident['type'] as String, style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1E))),
              const SizedBox(height: 10),
              Text(incident['description'] as String,
                style: GoogleFonts.inter(fontSize: 13,
                    color: const Color(0xFF8E8E93), height: 1.6)),
            ]),
          ),
          const SizedBox(height: 16),

          // Media section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('Images/ Videos', style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E))),
              const SizedBox(height: 12),
              Row(children: List.generate(3, (i) => Padding(
                padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                child: Container(width: 80, height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(10)))))),

            ]),
          ),
          const SizedBox(height: 16),

          // Safety tips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('Safety Tips', style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E))),
              const SizedBox(height: 12),
              ...[
                'Stay Calm & Check for Injuries – Assess yourself and '
                    'others for injuries.',
                'Move to Safety (If Possible) – If the area is drivable, '
                    'move to a safe location. Turn on hazard lights if applicable.',
                'Call Emergency Services – Use the emergency numbers '
                    'provided in the app to get immediate help.',
              ].asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('${e.key + 1}. ', style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E))),
                  Expanded(child: Text(e.value, style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF1C1C1E),
                      height: 1.5))),
                ]))),
            ]),
          ),
        ]),
      ),
    );
  }
}
