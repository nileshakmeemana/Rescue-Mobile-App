import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../widgets/notification_bell.dart';
import '../services/location_service.dart';
import '../services/user_state.dart';
import 'sos_tab.dart';
import 'community_tab.dart';
import 'profile_tab.dart';
import 'emergency_numbers_screen.dart';
import 'map_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _navIndex;
  late AnimationController _rippleCtrl;
  late Animation<double> _r1, _r2, _r3;
  String? _pendingCategory;

  static const _categories = [
    {'label': 'Accident', 'image': 'assets/images/Accident.png'},
    {'label': 'Fire', 'image': 'assets/images/Fire.png'},
    {'label': 'Flood', 'image': 'assets/images/Flood.png'},
    {'label': 'Quake', 'image': 'assets/images/Quake.png'},
    {'label': 'Robbery', 'image': 'assets/images/Robbery.png'},
    {'label': 'Assault', 'image': 'assets/images/Assault.png'},
    {'label': 'Medical', 'image': 'assets/images/Medical.png'},
    {'label': 'Other', 'image': 'assets/images/Other.png'},
  ];

  @override
  void initState() {
    super.initState();
    _navIndex = widget.initialTab;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    _r1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut)));
    _r2 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));
    _r3 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  void switchToSOS({String? category}) => setState(() {
        _navIndex = 1;
        _pendingCategory = category;
      });

  // SOS big button → Emergency Numbers screen
  void _onSOSPressed() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const EmergencyNumbersScreen(
                mode: EmergencyScreenMode.fromSOS)));
  }

  // Use Current Location / Setup Location — tries real GPS first, falls back to map picker
  Future<void> _setLocation() async {
    // Try real GPS
    final pos = await LocationService().getCurrentPosition();
    dynamic result;
    if (pos != null) {
      result = await LocationService().getAddressFromPosition(pos);
    } else {
      // Fall back to map picker
      result = await Navigator.push<Map<String, dynamic>>(
          context, MaterialPageRoute(builder: (_) => const MapPickerScreen()));
    }

    String? addr;
    if (result is String) addr = result;
    if (result is Map<String, dynamic>) addr = result['address'] as String?;

    if (addr != null && addr.isNotEmpty) {
      AppState().setLocation(addr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Location set to ${AppState().region}. Emergency numbers & local alerts updated.',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (_, __) {
        final tabs = [
          _buildHomeTab(),
          SOSTab(
              initialCategory: _pendingCategory,
              onCategoryConsumed: () =>
                  setState(() => _pendingCategory = null)),
          CommunityTab(),
          ProfileTab(),
        ];
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: IndexedStack(index: _navIndex, children: tabs),
          bottomNavigationBar: _BottomNav(
              currentIndex: _navIndex,
              onTap: (i) => setState(() {
                    _navIndex = i;
                    _pendingCategory = null;
                  })),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    final hasLoc = AppState().hasLocation;
    final region = AppState().region;

    return CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              // Fix 4: Tap profile circle → switch to Profile tab
              GestureDetector(
                  onTap: () => setState(() {
                        _navIndex = 3;
                        _pendingCategory = null;
                      }),
                  child: AnimatedBuilder(
                      animation: UserState(),
                      builder: (_, __) {
                        final img = UserState().profileImage;
                        final name = UserState().name;
                        final initials = name.trim().split(' ').length > 1
                            ? '\${name.trim().split('
                                    ')[0][0]}\${name.trim().split('
                                    ')[1][0]}'
                                .toUpperCase()
                            : name.trim().isNotEmpty
                                ? name.trim()[0].toUpperCase()
                                : '?';
                        return CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFE53935),
                            backgroundImage: img,
                            child: img == null
                                ? Text(initials,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white))
                                : null);
                      })),
              const Spacer(),
              Text('Rescue',
                  style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E))),
              const Spacer(),
              const NotificationBell(),
            ])),
      ),
      SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 20),

          // Location chip
          if (hasLoc)
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFE53935).withOpacity(0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on,
                      size: 14, color: Color(0xFFE53935)),
                  const SizedBox(width: 5),
                  Text('Region: $region',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE53935))),
                ]))
          else
            const SizedBox(height: 0),

          Text('Help is just a\nclick away!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1E),
                  height: 1.2)),
          const SizedBox(height: 8),
          RichText(
              text: TextSpan(
                  text: 'Click ',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF8E8E93)),
                  children: [
                TextSpan(
                    text: 'SOS button',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE53935))),
                TextSpan(
                    text: ' to call the help.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF8E8E93))),
              ])),
          const SizedBox(height: 28),

          // SOS button
          AnimatedBuilder(
              animation: _rippleCtrl,
              builder: (_, child) {
                return SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(alignment: Alignment.center, children: [
                      _Ring(
                          scale: 0.6 + _r3.value * 0.4,
                          opacity: (1 - _r3.value) * 0.10,
                          size: 220),
                      _Ring(
                          scale: 0.6 + _r2.value * 0.35,
                          opacity: (1 - _r2.value) * 0.16,
                          size: 200),
                      _Ring(
                          scale: 0.7 + _r1.value * 0.28,
                          opacity: (1 - _r1.value) * 0.22,
                          size: 180),
                      child!,
                    ]));
              },
              child: GestureDetector(
                  onTap: _onSOSPressed,
                  child: Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x55E53935),
                                blurRadius: 20,
                                spreadRadius: 4)
                          ]),
                      child: Center(
                          child: Text('SOS',
                              style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 2)))))),
          const SizedBox(height: 28),

          // Report Emergency
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Report Emergency',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E)))),
          const SizedBox(height: 14),
          for (int row = 0; row < 2; row++) ...[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (col) {
                  final item = _categories[row * 4 + col];
                  return _CategoryTile(
                      label: item['label']!,
                      imagePath: item['image']!,
                      onTap: () => switchToSOS(category: item['label']));
                })),
            if (row == 0) const SizedBox(height: 12),
          ],
          const SizedBox(height: 24),

          // Location section
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'We need to know your location in order to\nsuggest nearby stations',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFFE53935),
                      height: 1.4,
                      fontWeight: FontWeight.w500))),
          const SizedBox(height: 12),

          // Mini map tap to set location
          GestureDetector(
              onTap: _setLocation,
              child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(alignment: Alignment.center, children: [
                        CustomPaint(
                            size: Size(
                                MediaQuery.of(context).size.width - 40, 150),
                            painter: _MapGrid()),
                        const _RadarDot(),
                        if (!hasLoc)
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.touch_app,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text('Tap to set location',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  ])),
                      ])))),
          const SizedBox(height: 14),

          // Use Current Location button
          SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                  onPressed: _setLocation,
                  icon: const Icon(Icons.my_location_rounded,
                      size: 18, color: Colors.white),
                  label: Text(
                      hasLoc
                          ? 'Update Location (${AppState().region})'
                          : 'Use Current Location',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))))),
          const SizedBox(height: 24),
        ]),
      )),
    ]);
  }
}

class _Ring extends StatelessWidget {
  final double scale, opacity, size;
  const _Ring({required this.scale, required this.opacity, required this.size});
  @override
  Widget build(BuildContext context) => Transform.scale(
      scale: scale,
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE53935).withOpacity(opacity))));
}

class _CategoryTile extends StatelessWidget {
  final String label, imagePath;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.label, required this.imagePath, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 40 - 24) / 4;
    return GestureDetector(
        onTap: onTap,
        child: SizedBox(
            width: w,
            child: Column(children: [
              Container(
                width: w,
                height: w * 0.75,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]),
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF8E8E93),
                          ),
                        ))),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C1C1E))),
            ])));
  }
}

class _MapGrid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 28)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    for (double x = 0; x < size.width; x += 28)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    final bp = Paint()..color = Colors.white.withOpacity(0.45);
    for (final b in [
      Rect.fromLTWH(10, 10, 55, 35),
      Rect.fromLTWH(75, 15, 40, 50),
      Rect.fromLTWH(130, 5, 60, 30),
      Rect.fromLTWH(200, 20, 45, 40),
      Rect.fromLTWH(15, 60, 50, 45),
      Rect.fromLTWH(130, 55, 65, 45),
      Rect.fromLTWH(210, 68, 45, 38),
      Rect.fromLTWH(10, 115, 60, 28),
    ])
      canvas.drawRRect(
          RRect.fromRectAndRadius(b, const Radius.circular(4)), bp);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RadarDot extends StatefulWidget {
  const _RadarDot();
  @override
  State<_RadarDot> createState() => _RadarDotState();
}

class _RadarDotState extends State<_RadarDot>
    with SingleTickerProviderStateMixin {
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
                width: 70 * _a.value,
                height: 70 * _a.value,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935)
                        .withOpacity((1 - _a.value) * 0.25))),
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

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.home_outlined,
        'active': Icons.home_rounded,
        'label': 'Home'
      },
      {
        'icon': Icons.warning_amber_outlined,
        'active': Icons.warning_amber_rounded,
        'label': 'SOS'
      },
      {
        'icon': Icons.people_outline,
        'active': Icons.people_rounded,
        'label': 'Community'
      },
      {
        'icon': Icons.person_outline,
        'active': Icons.person_rounded,
        'label': 'Profile'
      },
    ];
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border:
                Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 1))),
        child: SafeArea(
            top: false,
            child: SizedBox(
                height: 60,
                child: Row(
                    children: List.generate(items.length, (i) {
                  final active = i == currentIndex;
                  return Expanded(
                      child: GestureDetector(
                          onTap: () => onTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    active
                                        ? items[i]['active'] as IconData
                                        : items[i]['icon'] as IconData,
                                    size: 24,
                                    color: active
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFF8E8E93)),
                                const SizedBox(height: 3),
                                Text(items[i]['label'] as String,
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: active
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: active
                                            ? const Color(0xFFE53935)
                                            : const Color(0xFF8E8E93))),
                              ])));
                })))));
  }
}
