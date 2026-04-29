import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../widgets/notification_bell.dart';
import 'map_picker_screen.dart';

class SetupSOSScreen extends StatefulWidget {
  const SetupSOSScreen({super.key});
  @override
  State<SetupSOSScreen> createState() => _SetupSOSScreenState();
}

class _SetupSOSScreenState extends State<SetupSOSScreen> {
  late TextEditingController _policeCtrl, _hospitalCtrl, _locCtrl;
  bool _locationSet = false;

  @override
  void initState() {
    super.initState();
    final s = AppState();
    _policeCtrl = TextEditingController(
        text: s.policeStation.isEmpty ? 'Maharagama' : s.policeStation);
    _hospitalCtrl = TextEditingController(
        text: s.hospital.isEmpty ? 'Kalubowila' : s.hospital);
    _locCtrl = TextEditingController(
        text: s.locationLabel.isEmpty ? '' : s.locationLabel);
    _locationSet = s.hasLocation;
  }

  @override
  void dispose() {
    _policeCtrl.dispose();
    _hospitalCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
        context, MaterialPageRoute(builder: (_) => const MapPickerScreen()));
    if (result != null) {
      setState(() {
        _locCtrl.text = result['address'] ?? _locCtrl.text;
        _locationSet = true;
      });
    }
  }

  void _useCurrentLocation() {
    // Simulate GPS — in real app use geolocator
    setState(() {
      _locCtrl.text = 'Maharagama Junction, Colombo';
      _locationSet = true;
    });
  }

  void _setupSOS() {
    AppState().setupSOS(
      police: _policeCtrl.text,
      hosp: _hospitalCtrl.text,
      loc: _locCtrl.text.isEmpty ? 'Colombo' : _locCtrl.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'SOS setup complete for ${AppState().region}! '
            'Regional emergency numbers & alerts activated.',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F2F7),
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 18, color: Color(0xFF1C1C1E)),
              onPressed: () => Navigator.pop(context)),
          title: Text('Setup SOS',
              style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E))),
          centerTitle: true,
          actions: const [NotificationBell(), SizedBox(width: 4)],
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Info banner
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE53935).withOpacity(0.2))),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Color(0xFFE53935)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                'Setup your SOS to personalise emergency numbers '
                                'and see local incidents based on your region.',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFFE53935),
                                    height: 1.5))),
                      ])),
              const SizedBox(height: 16),

              Text(
                  'We need to know your location in order to suggest nearby help',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF1C1C1E),
                      height: 1.5)),
              const SizedBox(height: 14),

              // Map tap to pick
              GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE5E5EA),
                          borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(alignment: Alignment.center, children: [
                            CustomPaint(
                                size: Size(
                                    MediaQuery.of(context).size.width - 40,
                                    170),
                                painter: _MiniMap()),
                            _Radar(),
                            if (!_locationSet)
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.touch_app,
                                            color: Colors.white, size: 15),
                                        const SizedBox(width: 6),
                                        Text('Tap to pick location',
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                      ])),
                          ])))),
              const SizedBox(height: 14),

              // Location field
              if (_locationSet) ...[
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.4))),
                    child: Row(children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(_locCtrl.text,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF1C1C1E),
                                  fontWeight: FontWeight.w500))),
                      GestureDetector(
                          onTap: _pickLocation,
                          child: Text('Change',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE53935)))),
                    ])),
                const SizedBox(height: 14),
              ],

              // Yellow button
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location_rounded,
                          size: 18, color: Colors.white),
                      label: Text('Use Current Location',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))))),
              const SizedBox(height: 22),

              _label('Nearest Police Station'),
              const SizedBox(height: 8),
              _field(_policeCtrl, 'Enter police station'),
              const SizedBox(height: 18),

              _label('Nearest Hospital'),
              const SizedBox(height: 8),
              _field(_hospitalCtrl, 'Enter hospital name'),
              const SizedBox(height: 28),

              SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                      onPressed: _setupSOS,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text('Setup SOS',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)))),
            ])));
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1C1E)));

  Widget _field(TextEditingController ctrl, String hint) => Container(
      decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(
            child: TextField(
                controller: ctrl,
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF1C1C1E)),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    hintText: hint,
                    hintStyle:
                        GoogleFonts.inter(color: const Color(0xFF8E8E93))))),
        GestureDetector(
            onTap: () => ctrl.clear(),
            child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                        color: Color(0xFFAEAEB2), shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        size: 14, color: Colors.white)))),
      ]));
}

class _MiniMap extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE8E0D0));
    final rp = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 28)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rp);
    for (double x = 0; x < size.width; x += 28)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), rp);
    final bp = Paint()..color = Colors.white.withOpacity(0.5);
    for (final b in [
      Rect.fromLTWH(8, 8, 55, 30),
      Rect.fromLTWH(72, 12, 45, 42),
      Rect.fromLTWH(126, 4, 62, 26),
      Rect.fromLTWH(8, 50, 52, 38),
      Rect.fromLTWH(126, 48, 58, 40),
      Rect.fromLTWH(200, 20, 48, 34),
    ])
      canvas.drawRRect(
          RRect.fromRectAndRadius(b, const Radius.circular(3)), bp);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Radar extends StatefulWidget {
  const _Radar();
  @override
  State<_Radar> createState() => _RadarState();
}

class _RadarState extends State<_Radar> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Stack(alignment: Alignment.center, children: [
            Container(
                width: 80 * _a.value,
                height: 80 * _a.value,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935)
                        .withOpacity((1 - _a.value) * 0.3))),
            Container(
                width: 40 * _a.value,
                height: 40 * _a.value,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935)
                        .withOpacity((1 - _a.value) * 0.2))),
            Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE53935),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x88E53935),
                          blurRadius: 8,
                          spreadRadius: 2)
                    ])),
          ]));
}
