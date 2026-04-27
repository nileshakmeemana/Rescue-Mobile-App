import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/notification_bell.dart';
import '../services/app_state.dart';
import 'upload_media_screen.dart';
import 'map_picker_screen.dart';
import 'help_coming_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _locCtrl   = TextEditingController();
  // Fix 2: only photo and video — voice removed
  bool _hasPhoto = false, _hasVideo = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _locCtrl.text = AppState().locationLabel.isNotEmpty
        ? AppState().locationLabel
        : 'Galle Road, Colombo';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<String>(context,
        MaterialPageRoute(builder: (_) =>
            MapPickerScreen(initialLocation: _locCtrl.text)));
    if (result != null && mounted) setState(() => _locCtrl.text = result);
  }

  Future<void> _openUpload(MediaType type) async {
    final result = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => UploadMediaScreen(type: type)));
    if (result == true && mounted) {
      setState(() {
        if (type == MediaType.photo) _hasPhoto = true;
        if (type == MediaType.video) _hasVideo = true;
      });
    }
  }

  Future<void> _publish() async {
    if (_isSubmitting) return;
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a title',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _isSubmitting = true);

    final post = {
      'rawTitle': _titleCtrl.text.trim(),
      'title': '${_titleCtrl.text.trim()} →',
      'subtitle': _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim().split('\n').first
          : 'Community post',
      'fullDesc': _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : _titleCtrl.text.trim(),
      'color': 0xFF4CAF50,
      'userAdded': true,
    };

    // Store in AppState FIRST — CommunityTab rebuilds instantly
    AppState().addUserPost(post);

    AppState().addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Post Published',
      message: '"${_titleCtrl.text.trim()}" posted to the community.',
      time: DateTime.now(),
    ));

    if (!mounted) return;

    // Navigate to HelpComing, replacing this screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HelpComingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18,
              color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.pop(context)),
        title: Text('Community Post', style: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1E))),
        centerTitle: false,
        actions: const [NotificationBell(), SizedBox(width: 4)],
      ),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            // ── Media buttons — Fix 2: Photo and Video only, no Voice
            Text('Add Media', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1C1E))),
            const SizedBox(height: 10),
            Row(children: [
              _MediaBtn(
                label: 'Photo',
                icon: Icons.camera_alt_outlined,
                done: _hasPhoto,
                onTap: () => _openUpload(MediaType.photo)),
              const SizedBox(width: 12),
              _MediaBtn(
                label: 'Video',
                icon: Icons.videocam_outlined,
                done: _hasVideo,
                onTap: () => _openUpload(MediaType.video)),
            ]),
            const SizedBox(height: 20),

            // ── Title
            Text('Title', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1C1E))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: _titleCtrl,
                style: GoogleFonts.inter(fontSize: 14,
                    color: const Color(0xFF1C1C1E)),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'Enter post title',
                  hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93))))),
            const SizedBox(height: 20),

            // ── Description
            Text('Description', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1C1E))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: _descCtrl,
                maxLines: 6,
                style: GoogleFonts.inter(fontSize: 13,
                    color: const Color(0xFF1C1C1E), height: 1.6),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'Write a description...',
                  hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93))))),
            const SizedBox(height: 20),

            // ── Location
            Text('Location', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1C1E))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Text(_locCtrl.text,
                      style: GoogleFonts.inter(fontSize: 14,
                          color: const Color(0xFF1C1C1E))))),
                TextButton(
                  onPressed: _pickLocation,
                  child: Text('Change', style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: const Color(0xFFE53935)))),
              ])),
          ])),
        ),

        // ── Publish button
        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottom > 0 ? 8 : 28),
          child: SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              child: _isSubmitting
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text('Publish', style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Colors.white))))),
      ]),
    );
  }
}

// ── Media button ──────────────────────────────────────────────────────────────
class _MediaBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool done;
  final VoidCallback onTap;

  const _MediaBtn({
    required this.label,
    required this.icon,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: done
              ? const Color(0xFFE53935).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: done
                  ? const Color(0xFFE53935)
                  : const Color(0xFFE5E5EA))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(done ? Icons.check_circle_rounded : icon,
              size: 24,
              color: done
                  ? const Color(0xFFE53935)
                  : const Color(0xFF8E8E93)),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.inter(fontSize: 11,
              color: done
                  ? const Color(0xFFE53935)
                  : const Color(0xFF8E8E93))),
        ])),
    ),
  );
}
