import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Image 6 — Map pin-point location chooser (mock map, real device would use google_maps)
class MapPickerScreen extends StatefulWidget {
  final String initialLocation;
  const MapPickerScreen({super.key, this.initialLocation = 'Galle Road, Colombo'});
  @override State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Pin position on the mock map (normalized 0-1)
  double _pinX = 0.45, _pinY = 0.42;
  bool _submitted = false;
  String _chosenAddress = '';

  static const _mockAddresses = [
    'Galle Road, Colombo 03', 'Maharagama Junction', 'Bambalapitiya, Colombo',
    'Nugegoda Main Street', 'Wellawatte, Colombo', 'Borella, Colombo 08',
    'Rajagiriya, Colombo', 'Nawala Road, Rajagiriya',
  ];

  String get _address {
    final idx = ((_pinX * 4).floor() + (_pinY * 2).floor() * 4)
        .clamp(0, _mockAddresses.length - 1);
    return _mockAddresses[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          // ── Mock map canvas fills the screen
          GestureDetector(
            onPanUpdate: (d) {
              final box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(d.globalPosition);
              setState(() {
                _pinX = (local.dx / box.size.width).clamp(0.05, 0.95);
                _pinY = (local.dy / box.size.height).clamp(0.05, 0.85);
              });
            },
            onTapDown: (d) {
              final box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(d.globalPosition);
              setState(() {
                _pinX = (local.dx / box.size.width).clamp(0.05, 0.95);
                _pinY = (local.dy / box.size.height).clamp(0.05, 0.85);
              });
            },
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: _MockMapPainter(pinX: _pinX, pinY: _pinY),
            ),
          ),

          // ── Back button
          Positioned(top: 12, left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                        blurRadius: 8)]),
                child: const Icon(Icons.arrow_back_ios_new, size: 18,
                    color: Color(0xFF1C1C1E)),
              ),
            )),

          // ── "Choose Location" label above pin
          LayoutBuilder(builder: (ctx, constraints) {
            return Positioned(
              left: _pinX * constraints.maxWidth - 70,
              top: _pinY * constraints.maxHeight - 52,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Choose Location', style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: Colors.white)),
              ),
            );
          }),

          // ── Submit button at bottom
          Positioned(bottom: 20, left: 20, right: 20,
            child: SizedBox(height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _address),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
                child: Text('Submit', style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: Colors.white)),
              )),
          ),
        ]),
      ),
    );
  }
}

class _MockMapPainter extends CustomPainter {
  final double pinX, pinY;
  const _MockMapPainter({required this.pinX, required this.pinY});

  @override
  void paint(Canvas canvas, Size size) {
    // Background – light sand color like map
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFF5F0E8));

    // Road grid
    final roadPaint = Paint()..color = const Color(0xFFFFFFFF)..strokeWidth = 18;
    final roadBorder = Paint()..color = const Color(0xFFDDD8CC)..strokeWidth = 20;

    final hRoads = [0.18, 0.35, 0.52, 0.68, 0.82];
    final vRoads = [0.15, 0.30, 0.48, 0.65, 0.80];

    for (final y in hRoads) {
      canvas.drawLine(Offset(0, size.height * y),
          Offset(size.width, size.height * y), roadBorder);
      canvas.drawLine(Offset(0, size.height * y),
          Offset(size.width, size.height * y), roadPaint);
    }
    for (final x in vRoads) {
      canvas.drawLine(Offset(size.width * x, 0),
          Offset(size.width * x, size.height), roadBorder);
      canvas.drawLine(Offset(size.width * x, 0),
          Offset(size.width * x, size.height), roadPaint);
    }

    // Buildings / blocks
    final buildingPaint = Paint()..color = const Color(0xFFE8E0D0);
    final buildingStroke = Paint()
      ..color = const Color(0xFFD4CCBC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final blocks = [
      Rect.fromLTWH(size.width*0.02, size.height*0.02, size.width*0.12, size.height*0.14),
      Rect.fromLTWH(size.width*0.16, size.height*0.02, size.width*0.13, size.height*0.14),
      Rect.fromLTWH(size.width*0.31, size.height*0.02, size.width*0.16, size.height*0.14),
      Rect.fromLTWH(size.width*0.02, size.height*0.20, size.width*0.12, size.height*0.13),
      Rect.fromLTWH(size.width*0.16, size.height*0.20, size.width*0.13, size.height*0.13),
      Rect.fromLTWH(size.width*0.50, size.height*0.20, size.width*0.14, size.height*0.10),
      Rect.fromLTWH(size.width*0.66, size.height*0.20, size.width*0.15, size.height*0.13),
      Rect.fromLTWH(size.width*0.83, size.height*0.02, size.width*0.15, size.height*0.14),
      Rect.fromLTWH(size.width*0.66, size.height*0.02, size.width*0.15, size.height*0.14),
      Rect.fromLTWH(size.width*0.02, size.height*0.38, size.width*0.12, size.height*0.12),
      Rect.fromLTWH(size.width*0.16, size.height*0.38, size.width*0.13, size.height*0.12),
      Rect.fromLTWH(size.width*0.50, size.height*0.38, size.width*0.14, size.height*0.12),
      Rect.fromLTWH(size.width*0.66, size.height*0.38, size.width*0.15, size.height*0.12),
      Rect.fromLTWH(size.width*0.83, size.height*0.38, size.width*0.15, size.height*0.12),
      Rect.fromLTWH(size.width*0.02, size.height*0.56, size.width*0.12, size.height*0.10),
      Rect.fromLTWH(size.width*0.31, size.height*0.56, size.width*0.16, size.height*0.10),
      Rect.fromLTWH(size.width*0.50, size.height*0.56, size.width*0.14, size.height*0.10),
      Rect.fromLTWH(size.width*0.66, size.height*0.56, size.width*0.15, size.height*0.10),
      Rect.fromLTWH(size.width*0.02, size.height*0.72, size.width*0.12, size.height*0.10),
      Rect.fromLTWH(size.width*0.16, size.height*0.72, size.width*0.27, size.height*0.10),
      Rect.fromLTWH(size.width*0.50, size.height*0.72, size.width*0.14, size.height*0.10),
      Rect.fromLTWH(size.width*0.66, size.height*0.72, size.width*0.32, size.height*0.10),
    ];
    for (final b in blocks) {
      final rr = RRect.fromRectAndRadius(b, const Radius.circular(3));
      canvas.drawRRect(rr, buildingPaint);
      canvas.drawRRect(rr, buildingStroke);
    }

    // Green park area
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.31, size.height * 0.02,
              size.width * 0.14, size.height * 0.14),
          const Radius.circular(4)),
      Paint()..color = const Color(0xFFB8D4A8),
    );

    // Drop pin at tap position
    final px = size.width * pinX;
    final py = size.height * pinY;

    // Shadow
    canvas.drawCircle(Offset(px, py + 2),
        14, Paint()..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Pin stem
    final pinPath = Path()
      ..moveTo(px, py + 16)
      ..lineTo(px - 8, py)
      ..arcToPoint(Offset(px + 8, py),
          radius: const Radius.circular(8), clockwise: false)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFFE53935));

    // Pin circle
    canvas.drawCircle(Offset(px, py - 10), 14,
        Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(Offset(px, py - 10), 6,
        Paint()..color = Colors.white);
  }

  @override bool shouldRepaint(_MockMapPainter old) =>
      old.pinX != pinX || old.pinY != pinY;
}
