import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/notification_bell.dart';
import '../services/user_state.dart';

class PersonalProfileScreen extends StatefulWidget {
  final Map<String, String> userData;
  const PersonalProfileScreen({super.key, required this.userData});
  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  late TextEditingController _nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userData['name']);
    _phoneCtrl = TextEditingController(text: widget.userData['phone']);
    _emailCtrl = TextEditingController(text: widget.userData['email']);
    _addressCtrl = TextEditingController(text: widget.userData['address']);
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl]) {
      c.addListener(() => setState(() => _changed = true));
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

  void _save() {
    UserState().setName(_nameCtrl.text);
    Navigator.pop(context, {
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'address': _addressCtrl.text,
    });
  }

  // Fix 4: Simulate image picker — generates a random colour avatar
  // On real device swap this for image_picker package
  void _pickImage() {
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
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF1C1C1E)),
              title: Text('Take Photo',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _simulateImagePick();
              }),
          ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF1C1C1E)),
              title: Text('Choose from Gallery',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _simulateImagePick();
              }),
          ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
              title: Text('Remove Photo',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE53935))),
              onTap: () {
                Navigator.pop(context);
                // Clear image back to initials avatar
                // On real device: UserState().setProfileImage(null)
                setState(() {}); // triggers rebuild with initials
              }),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _simulateImagePick() {
    // Generate a 1x1 pixel image of a random colour to simulate selection
    // In production replace with actual picked image bytes from image_picker
    final colours = [
      0xFFE53935,
      0xFF1565C0,
      0xFF2E7D32,
      0xFFFF8F00,
      0xFF6A1B9A,
      0xFF00838F,
      0xFFAD1457,
    ];
    final colour = colours[Random().nextInt(colours.length)];
    final r = (colour >> 16) & 0xFF;
    final g = (colour >> 8) & 0xFF;
    final b = colour & 0xFF;
    // 1×1 BMP in memory as a simple colour indicator
    final bytes = _makeColorBytes(r, g, b);
    UserState().setProfileImage(MemoryImage(Uint8List.fromList(bytes)));
    setState(() => _changed = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile photo updated!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF4CAF50),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // Minimal 1×1 PNG bytes for a solid colour
  static List<int> _makeColorBytes(int r, int g, int b) {
    // BMP 1x1 pixel — simple enough without dart:ui
    return [
      0x42,
      0x4D,
      0x3A,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x36,
      0x00,
      0x00,
      0x00,
      0x28,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x18,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x04,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      b,
      g,
      r,
      0x00,
    ];
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
                    // Fix 4: Profile image with camera button
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(children: [
                        CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFD1D1D6),
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
                                        color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 4)
                                    ]),
                                child: const Icon(Icons.camera_alt_rounded,
                                    size: 16, color: Colors.white))),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    // Tap to change hint
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

                    // Editable fields
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
                        _divider(),
                        _EditRow(
                            icon: Icons.email_outlined,
                            label: 'E-mail',
                            ctrl: _emailCtrl,
                            type: TextInputType.emailAddress),
                        _divider(),
                        _EditRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            ctrl: _addressCtrl,
                            type: TextInputType.streetAddress),
                        _divider(),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(children: [
                              const Icon(Icons.security_outlined,
                                  size: 22, color: Color(0xFF8E8E93)),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text('Setup SOS',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFF8E8E93))),
                                    Text('Setup your SOS',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1C1C1E))),
                                  ])),
                              const Icon(Icons.chevron_right,
                                  size: 20, color: Color(0xFFD1D1D6)),
                            ])),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    // Delete account
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
                                      color: const Color(0xFFE53935))))),
                    ),
                  ])),
            ),
            if (_changed)
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, bottom > 0 ? 8 : 28),
                  child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: Text('Save Changes',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white))))),
          ]),
        );
      },
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56, color: Color(0xFFF2F2F7));

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

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
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(ctx);
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
  Widget build(BuildContext context) {
    return GestureDetector(
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
              color:
                  _editing ? const Color(0xFFE53935) : const Color(0xFFD1D1D6)),
        ]),
      ),
    );
  }
}
