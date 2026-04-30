import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../services/user_state.dart';
import 'personal_profile_screen.dart';
import 'setup_sos_screen.dart';
import 'onboarding_screen.dart';
import '../widgets/notification_bell.dart';

// Profile tab now shows SETTINGS as the main view (per requirement 1)
// Bell icon → shows notification screen
// "Update Profile" → shows PersonalProfileScreen
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, String> _userData = {
    'name': 'Nilesh Akmeemana',
    'phone': '+94 123 456 678',
    'email': 'nilesh@gmail.com',
    'address': 'Galle Road, Colombo',
  };
  bool _interfaceToggle = true;
  bool _notificationsToggle = true;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await FirebaseService().getUserProfile();
    if (!mounted || profile == null) {
      setState(() => _loadingProfile = false);
      return;
    }

    final data = {
      'name': profile['name'] as String? ?? _userData['name'] ?? '',
      'phone': profile['phone'] as String? ?? _userData['phone'] ?? '',
      'email': profile['email'] as String? ?? _userData['email'] ?? '',
      'address': profile['address'] as String? ?? _userData['address'] ?? '',
    };

    if (mounted) {
      setState(() {
        _userData = data;
        _notificationsToggle = profile['notificationsEnabled'] as bool? ?? true;
        _loadingProfile = false;
      });

      if (data['name']?.isNotEmpty == true) {
        UserState().setName(data['name']!);
      }

      final photoUrl = profile['photoURL'] as String? ?? '';
      if (photoUrl.isNotEmpty) {
        UserState().setProfileImage(NetworkImage(photoUrl));
      }

      final region = profile['region'] as String? ?? '';
      final location =
          data['address']?.isNotEmpty == true ? data['address']! : region;
      if (location.isNotEmpty) {
        AppState().setLocation(location);
      }
    }
  }

  void _updateUser(Map<String, String> data) =>
      setState(() => _userData = data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Text('Profile Settings',
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E))),
              const Spacer(),
              const NotificationBell(),
            ]),
          ),
          const SizedBox(height: 24),

          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              if (_loadingProfile)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(
                    color: Color(0xFFE53935),
                    backgroundColor: Color(0xFFE5E5EA),
                    minHeight: 2,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  // Update Profile
                  _SettingsTile(
                      icon: Icons.account_circle_outlined,
                      title: 'Update Profile',
                      subtitle: 'Edit your personal information',
                      trailing: const Icon(Icons.chevron_right,
                          size: 20, color: Color(0xFFD1D1D6)),
                      onTap: () async {
                        final result =
                            await Navigator.push<Map<String, String>>(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PersonalProfileScreen(
                                        userData: _userData)));
                        if (result != null) _updateUser(result);
                      }),
                  _div(),

                  // Interface toggle
                  _SettingsTile(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Interface',
                      subtitle: 'Morning / Evening',
                      trailing: Switch.adaptive(
                          value: _interfaceToggle,
                          activeColor: const Color(0xFF34C759),
                          onChanged: (v) =>
                              setState(() => _interfaceToggle = v)),
                      onTap: () =>
                          setState(() => _interfaceToggle = !_interfaceToggle)),
                  _div(),

                  // Notifications toggle
                  _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Receive notifications',
                      subtitle:
                          'Receive push alerts for incidents and community posts.',
                      trailing: Switch.adaptive(
                          value: _notificationsToggle,
                          activeColor: const Color(0xFF34C759),
                          onChanged: (v) async {
                            setState(() => _notificationsToggle = v);
                            await FirebaseService()
                                .setPushNotificationsEnabled(v);
                          }),
                      onTap: () async {
                        final next = !_notificationsToggle;
                        setState(() => _notificationsToggle = next);
                        await FirebaseService()
                            .setPushNotificationsEnabled(next);
                      }),
                  _div(),

                  // Setup SOS
                  _SettingsTile(
                      icon: Icons.security_outlined,
                      title: 'Setup SOS',
                      subtitle: 'Configure your SOS contacts & location',
                      trailing: const Icon(Icons.chevron_right,
                          size: 20, color: Color(0xFFD1D1D6)),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SetupSOSScreen()))),
                  _div(),

                  // Language
                  _SettingsTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      trailing: const Icon(Icons.chevron_right,
                          size: 20, color: Color(0xFFD1D1D6)),
                      onTap: () => _showLanguage(context)),
                  _div(),

                  // Help Center
                  _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      trailing: const Icon(Icons.chevron_right,
                          size: 20, color: Color(0xFFD1D1D6)),
                      onTap: () => _showHelp(context)),
                  _div(),

                  // Send Donations
                  _SettingsTile(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'Send Donations',
                      trailing: const Icon(Icons.chevron_right,
                          size: 20, color: Color(0xFFD1D1D6)),
                      onTap: () => _showDonations(context)),
                ]),
              ),
              const SizedBox(height: 20),

              // Logout
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        onPressed: _logout,
                        child: Text('Logout',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE53935))))),
              ),
              const SizedBox(height: 24),
            ]),
          )),
        ],
      )),
    );
  }

  Widget _div() =>
      const Divider(height: 1, indent: 56, color: Color(0xFFF2F2F7));

  void _showLanguage(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Select Language',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700))),
              const SizedBox(height: 12),
              ...['English', 'Sinhala', 'Tamil'].map((lang) => ListTile(
                  title: Text(lang, style: GoogleFonts.inter(fontSize: 14)),
                  trailing: lang == 'English'
                      ? const Icon(Icons.check, color: Color(0xFFE53935))
                      : null,
                  onTap: () => Navigator.pop(ctx))),
              const SizedBox(height: 20),
            ]));
  }

  void _showHelp(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Help Center',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              content: Text(
                  'For support, contact us at:\nhelp@rescue.app\nor call +94 11 234 5678',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93), height: 1.6)),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text('OK',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w600)))
              ],
            ));
  }

  void _showDonations(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Send Donations',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              content: Text(
                  'Help us support emergency response.\nDonate via bank transfer:\nAcc: 1234 5678 9012\nBank: People\'s Bank',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93), height: 1.6)),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text('OK',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w600)))
              ],
            ));
  }

  Future<void> _logout() async {
    await FirebaseService().signOut();
    UserState().reset();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon,
      required this.title,
      this.subtitle,
      required this.trailing,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(icon, size: 22, color: const Color(0xFF8E8E93)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1C1E))),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF8E8E93),
                             profile tab, height: 1.4)),
                  ],
                ])),
            trailing,
          ]),
        ),
      );
}
