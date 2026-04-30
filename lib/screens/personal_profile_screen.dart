import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../services/user_state.dart';
import '../widgets/notification_bell.dart';
import 'onboarding_screen.dart';
import 'setup_sos_screen.dart';

class PersonalProfileScreen extends StatefulWidget {
  final Map<String, String> userData;
  const PersonalProfileScreen({super.key, required this.userData});
  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  late TextEditingController _nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl;
  bool _changed = false, _saving = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userData['name']);
    _phoneCtrl = TextEditingController(text: widget.userData['phone']);
    _emailCtrl = TextEditingController(text: widget.userData['email']);
    _addressCtrl = TextEditingController(text: widget.userData['address']);
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl])
      c.addListener(() => setState(() => _changed = true));

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await FirebaseService().getUserProfile();
    if (!mounted || profile == null) return;

    setState(() {
      _nameCtrl.text = profile['name'] as String? ?? _nameCtrl.text;
      _phoneCtrl.text = profile['phone'] as String? ?? _phoneCtrl.text;
      _emailCtrl.text = profile['email'] as String? ?? _emailCtrl.text;
      _addressCtrl.text = profile['address'] as String? ?? _addressCtrl.text;
      _changed = false;
    });

    final photoUrl = profile['photoURL'] as String? ?? '';
    if (photoUrl.isNotEmpty) {
      UserState().setProfileImage(NetworkImage(photoUrl));
    }

    if ((_nameCtrl.text).isNotEmpty) {
      UserState().setName(_nameCtrl.text);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseService().updateUserProfile({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      });
      AppState().setLocation(_addressCtrl.text.trim());
      UserState().setName(_nameCtrl.text.trim());
      if (mounted) {
        Navigator.pop(context, {
          'name': _nameCtrl.text,
          'phone': _phoneCtrl.text,
          'email': _emailCtrl.text,
          'address': _addressCtrl.text,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: const Color(0xFFE53935)));
      }
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 8),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _doPickImage(ImageSource.camera);
                  }),
              ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _doPickImage(ImageSource.gallery);
                  }),
              ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: Color(0xFFE53935)),
                  title: Text('Remove Photo',
                      style: GoogleFonts.inter(color: const Color(0xFFE53935))),
                  onTap: () {
                    Navigator.pop(context);
                    UserState().clearProfileImage();
                  }),
              const SizedBox(height: 12),
            ])));
  }

  Future<void> _doPickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 512);
    if (xFile == null || !mounted) return;
    final file = File(xFile.path);
    // Show immediately in UI
    final bytes = await file.readAsBytes();
    UserState().setProfileImage(MemoryImage(bytes));
    setState(() => _changed = true);
    // Upload to Firebase Storage
    try {
      final url = await FirebaseService().uploadProfilePhoto(file);
      await FirebaseService().updateUserProfile({'photoURL': url});
    } catch (_) {}
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1)
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedBuilder(
      animation: UserState(),
      builder: (_, __) {
        final profileImg = UserState().profileImage;
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF2F2F7),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    size: 18, color: Color(0xFF1C1C1E)),
                onPressed: () => Navigator.pop(context)),
            title: Text('Profile',
                style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E))),
            centerTitle: true,
            actions: const [NotificationBell(), SizedBox(width: 4)],
          ),
          body: Column(children: [
            Expanded(
                child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, bottom),
                    child: Column(children: [
                      GestureDetector(
                          onTap: _pickImage,
                          child: Stack(children: [
                            CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFE53935),
                                backgroundImage: profileImg,
                                child: profileImg == null
                                    ? Text(_getInitials(_nameCtrl.text),
                                        style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white))
                                    : null),
                            Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE53935),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2)),
                                    child: const Icon(Icons.camera_alt_rounded,
                                        size: 16, color: Colors.white))),
                          ])),
                      const SizedBox(height: 4),
                      Text('Tap to change photo',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFE53935),
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text(_nameCtrl.text,
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C1C1E))),
                      const SizedBox(height: 24),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(children: [
                            _EditRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone Number',
                                ctrl: _phoneCtrl,
                                type: TextInputType.phone),
                            _div(),
                            _EditRow(
                                icon: Icons.email_outlined,
                                label: 'E-mail',
                                ctrl: _emailCtrl,
                                type: TextInputType.emailAddress),
                            _div(),
                            _EditRow(
                                icon: Icons.location_on_outlined,
                                label: 'Address',
                                ctrl: _addressCtrl,
                                type: TextInputType.streetAddress),
                            _div(),
                            ListTile(
                                leading: const Icon(Icons.security_outlined,
                                    color: Color(0xFF8E8E93)),
                                title: Text('Setup SOS',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text('Setup your SOS',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF8E8E93))),
                                trailing: const Icon(Icons.chevron_right,
                                    color: Color(0xFFD1D1D6)),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SetupSOSScreen()))),
                          ])),
                      const SizedBox(height: 24),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)),
                          child: SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                  onPressed: () => _confirmDelete(context),
                                  child: Text('Delete Account Permanently',
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFE53935)))))),
                    ]))),
            if (_changed)
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, bottom > 0 ? 8 : 28),
                  child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : Text('Save Changes',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white))))),
          ]),
        );
      },
    );
  }

  Widget _div() =>
      const Divider(height: 1, indent: 56, color: Color(0xFFF2F2F7));

  void _confirmDelete(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Delete Account',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE53935))),
              content: Text('This action is permanent and cannot be undone.',
                  style: GoogleFonts.inter(color: const Color(0xFF8E8E93))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel',
                        style:
                            GoogleFonts.inter(color: const Color(0xFF8E8E93)))),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await FirebaseService().deleteCurrentUserAccount();
                        UserState().reset();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Delete failed: $e'),
                          backgroundColor: const Color(0xFFE53935),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text('Delete',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ));
  }
}

class _EditRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final TextEditingController ctrl;
  final TextInputType type;
  const _EditRow(
      {required this.icon,
      required this.label,
      required this.ctrl,
      required this.type});
  @override
  State<_EditRow> createState() => _EditRowState();
}

class _EditRowState extends State<_EditRow> {
  bool _editing = false;
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) setState(() => _editing = false);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        setState(() => _editing = true);
        _focus.requestFocus();
      },
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icon(widget.icon, size: 22, color: const Color(0xFF8E8E93)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(widget.label,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF8E8E93))),
                  const SizedBox(height: 2),
                  _editing
                      ? TextField(
                          controller: widget.ctrl,
                          focusNode: _focus,
                          keyboardType: widget.type,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1C1C1E)),
                          decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero))
                      : Text(widget.ctrl.text,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1C1C1E))),
                ])),
            Icon(_editing ? Icons.check : Icons.chevron_right,
                size: 20,
                color: _editing
                    ? const Color(0xFFE53935)
                    : const Color(0xFFD1D1D6)),
          ])));
}
