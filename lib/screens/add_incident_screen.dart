import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/notification_bell.dart';
import '../services/app_state.dart';
import 'upload_media_screen.dart';
import 'map_picker_screen.dart';
import 'help_coming_screen.dart';

class AddIncidentScreen extends StatefulWidget {
  final String? prefilledCategory;
  const AddIncidentScreen({super.key, this.prefilledCategory});
  @override State<AddIncidentScreen> createState() =>
      _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  late String _selectedCategory;
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  // Fix 2: only photo and video — voice removed
  bool _hasPhoto = false, _hasVideo = false;
  bool _isSubmitting = false;

  final _categories = [
    'Accident', 'Fire', 'Flood', 'Quake',
    'Robbery', 'Assault', 'Medical', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.prefilledCategory ?? 'Accident';
    _locationCtrl.text = AppState().locationLabel.isNotEmpty
        ? AppState().locationLabel
        : 'Galle Road, Colombo';
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<String>(context,
        MaterialPageRoute(builder: (_) =>
            MapPickerScreen(initialLocation: _locationCtrl.text)));
    if (result != null && mounted) setState(() => _locationCtrl.text = result);
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

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final incident = {
      'location': _locationCtrl.text.trim().isEmpty
          ? 'Unknown Location'
          : _locationCtrl.text.trim(),
      'type': _selectedCategory,
      'description': _descCtrl.text.trim().isEmpty
          ? 'Incident of type $_selectedCategory reported at ${_locationCtrl.text.trim()}.'
          : _descCtrl.text.trim(),
      'hasPin': true,
    };

    // Fix 1: Store in AppState FIRST — this triggers AnimatedBuilder in SOSTab
    AppState().addUserIncident(incident);

    AppState().addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Incident Reported',
      message: '$_selectedCategory at ${incident['location']}.',
      time: DateTime.now(),
    ));

    if (!mounted) return;

    // Navigate to HelpComing, clearing this screen from the stack
    // SOSTab will already show the new incident because AppState notified it
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
        title: Text('Emergency Incident', style: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1E))),
        centerTitle: true,
        actions: const [NotificationBell(), SizedBox(width: 4)],
      ),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            // ── Category chips
            Text('Incident Type', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1C1E))),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: _categories.map((cat) {
                final sel = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFE53935)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? const Color(0xFFE53935)
                              : const Color(0xFFE5E5EA))),
                    child: Text(cat, style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: sel
                            ? Colors.white
                            : const Color(0xFF8E8E93)))));
              }).toList()),
            const SizedBox(height: 20),

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
                maxLines: 5,
                style: GoogleFonts.inter(fontSize: 14,
                    color: const Color(0xFF1C1C1E)),
                decoration: InputDecoration(
                  hintText: 'Describe the incident...',
                  hintStyle: GoogleFonts.inter(fontSize: 14,
                      color: const Color(0xFF8E8E93)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16)))),
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
                  child: Text(_locationCtrl.text,
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

        // ── Submit button
        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottom > 0 ? 8 : 28),
          child: SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              child: _isSubmitting
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text('Report Incident', style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Colors.white))))),
      ]),
    );
  }
}

// ── Media button — reusable ───────────────────────────────────────────────────
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
