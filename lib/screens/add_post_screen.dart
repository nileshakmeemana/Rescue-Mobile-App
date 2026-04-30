import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../widgets/notification_bell.dart';


class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  double? _pickedLat;
  double? _pickedLng;
  final List<File> _mediaFiles = [];
  bool _isSubmitting = false;
  final _picker = ImagePicker();

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
    final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
            builder: (_) => MapPickerScreen(initialLocation: _locCtrl.text)));
    if (result != null && mounted) {
      setState(() {
        _locCtrl.text = result['address'] ?? _locCtrl.text;
        _pickedLat = result['lat'] as double?;
        _pickedLng = result['lng'] as double?;
      });
    }
  }

  void _showMediaSheet() {
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
                    final f = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (f != null && mounted)
                      setState(() => _mediaFiles.add(File(f.path)));
                  }),
              ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose Photo from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final f = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (f != null && mounted)
                      setState(() => _mediaFiles.add(File(f.path)));
                  }),
              ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: const Text('Choose Video from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final f = await _picker.pickVideo(
                        source: ImageSource.gallery,
                        maxDuration: const Duration(minutes: 2));
                    if (f != null && mounted)
                      setState(() => _mediaFiles.add(File(f.path)));
                  }),
              const SizedBox(height: 12),
            ])));
  }

  Future<void> _publish() async {
    if (_isSubmitting) return;
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a title',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final mediaUrls = <String>[];
      for (final file in _mediaFiles) {
        final url = await FirebaseService().uploadMedia(file, 'post_media');
        mediaUrls.add(url);
      }

      /*await FirebaseService().addPost(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : _titleCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        region: AppState().region.isEmpty ? 'Colombo' : AppState().region,
        mediaUrls: mediaUrls,
        latitude: _pickedLat,
        longitude: _pickedLng,
      );

      await FirebaseService().addNotification(
        title: 'Post Published',
        message: '"${_titleCtrl.text.trim()}" posted to the community.',
        region: AppState().region.isEmpty ? 'Colombo' : AppState().region,
      );*/

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HelpComingScreen()));
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${e.toString()}',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating));
      }
    }
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
            icon: const Icon(Icons.arrow_back_ios,
                size: 18, color: Color(0xFF1C1C1E)),
            onPressed: () => Navigator.pop(context)),
        title: Text('Community Post',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E))),
        centerTitle: false,
        actions: const [NotificationBell(), SizedBox(width: 4)],
      ),
      body: Column(children: [
        Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Media picker
                      Text('Add Media',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1E))),
                      const SizedBox(height: 10),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        ..._mediaFiles.map((f) => Stack(children: [
                              Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          image: FileImage(f),
                                          fit: BoxFit.cover))),
                              Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _mediaFiles.remove(f)),
                                      child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                              color: Color(0xFFE53935),
                                              shape: BoxShape.circle),
                                          child: const Icon(Icons.close,
                                              size: 12, color: Colors.white)))),
                            ])),
                        GestureDetector(
                            onTap: _showMediaSheet,
                            child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE5E5EA))),
                                child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          size: 26, color: Color(0xFF8E8E93)),
                                      SizedBox(height: 4),
                                      Text('Add',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF8E8E93))),
                                    ]))),
                      ]),
                      const SizedBox(height: 20),
                      // Title
                      Text('Title',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1E))),
                      const SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14)),
                          child: TextField(
                              controller: _titleCtrl,
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: const Color(0xFF1C1C1E)),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  hintText: 'Enter post title',
                                  hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF8E8E93))))),
                      const SizedBox(height: 20),
                      // Description
                      Text('Description',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1E))),
                      const SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14)),
                          child: TextField(
                              controller: _descCtrl,
                              maxLines: 6,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF1C1C1E),
                                  height: 1.6),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  hintText: 'Write a description...',
                                  hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF8E8E93))))),
                      const SizedBox(height: 20),
                      // Location
                      Text('Location',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1E))),
                      const SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 14, 8, 14),
                                    child: Text(_locCtrl.text,
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFF1C1C1E))))),
                            TextButton(
                                onPressed: _pickLocation,
                                child: Text('Change',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFE53935)))),
                          ])),
                    ]))),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottom > 0 ? 8 : 28),
            child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _publish,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Publish',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white))))),
      ]),
    );
  }
}