import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Fix 1: Proper back button, Fix 4: Community stays active in nav
class CommunityPostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Community Posts',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E))),
        centerTitle: true,
        actions: const [NotificationBell(), SizedBox(width: 4)],
      ),*/
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          /*decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2))
            ],
          ),*/
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post['rawTitle'] ?? post['title'] ?? 'Post',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E))),
              const SizedBox(height: 12),
              Text(
                  post['fullDesc'] ??
                      'A heavy weather warning has been issued in your area '
                          'through the Stay Safe Emergency App.\n\nPlease remain '
                          'indoors if possible, avoid flooded roads, and stay updated '
                          'through the app for real-time alerts and safety '
                          'guidance.\n\nStay prepared, stay connected, and look out '
                          'for one another. ❤',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF1C1C1E),
                      height: 1.6)),
              if ((post['mediaUrls'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 20),
                Text('Images / Videos',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (post['mediaUrls'] as List)
                      .whereType<String>()
                      .take(6)
                      .map((url) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              url,
                              width: 88,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 88,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E5EA),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.broken_image_outlined,
                                    color: Color(0xFF8E8E93)),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              ...[
                'Stay Calm & Check for Injuries – Assess yourself and '
                    'passengers for injuries.',
                'Move to Safety (If Possible) – If the vehicle is drivable, '
                    'move it to the side of the road. If not, turn on hazard lights.',
              ].asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.key + 1}. ',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C1C1E))),
                        Expanded(
                            child: Text(e.value,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF1C1C1E),
                                    height: 1.5))),
                      ]
                      )
                      )
                      ),
            ]
            ),
          ),
        ),
      ),
    );
  }
}