import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MediaType { photo, video, voice }

// Images 2, 3, 4 — Upload Photo / Video / Voice screens
class UploadMediaScreen extends StatefulWidget {
  final MediaType type;
  final void Function(MediaType)? onUploaded;
  const UploadMediaScreen({super.key, required this.type, this.onUploaded});
  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen>
    with SingleTickerProviderStateMixin {
  bool _captured = false;
  bool _isRecording = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case MediaType.photo:
        return 'Upload Photo';
      case MediaType.video:
        return 'Upload Video';
      case MediaType.voice:
        return 'Upload Voice';
    }
  }

  String get _hint {
    switch (widget.type) {
      case MediaType.photo:
        return 'Ensure the photo is neither too blurry nor too bright, and that all the information is within the frame.';
      case MediaType.video:
        return 'Ensure the video is neither too blurry nor too bright, and that all the information is within the frame.';
      case MediaType.voice:
        return 'Ensure the voice is neither too blurry nor too bright, and that all the information is within the frame.';
    }
  }

  void _onCapture() {
    if (widget.type == MediaType.voice) {
      setState(() => _isRecording = !_isRecording);
      if (_isRecording) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted)
            setState(() {
              _isRecording = false;
              _captured = true;
            });
        });
      }
    } else {
      setState(() => _captured = true);
    }
    if (_captured || widget.type == MediaType.voice) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onUploaded?.call(widget.type);
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Back
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Color(0xFF1C1C1E),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              _title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 20),

            // Preview area or audio player
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: widget.type == MediaType.voice
                  ? _AudioPlayer(hasAudio: _captured)
                  : _CameraPreview(captured: _captured),
            ),
            const SizedBox(height: 24),

            // Hint text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _hint,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF8E8E93),
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),

            // Capture / Record button
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulse.value : 1.0,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _onCapture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE53935),
                        width: 3,
                      ),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE53935),
                        ),
                        child: widget.type == MediaType.voice
                            ? const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 26,
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  final bool captured;
  const _CameraPreview({required this.captured});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: captured
            ? const Color(0xFFD1D1D6).withOpacity(0.6)
            : const Color(0xFFD1D1D6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: captured
          ? const Center(
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: Color(0xFF4CAF50),
              ),
            )
          : null,
    );
  }
}

class _AudioPlayer extends StatelessWidget {
  final bool hasAudio;
  const _AudioPlayer({required this.hasAudio});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(
            hasAudio ? Icons.play_arrow : Icons.mic_none,
            size: 22,
            color: const Color(0xFF1C1C1E),
          ),
          const SizedBox(width: 12),
          Text(
            'Recorded Audio',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const Spacer(),
          if (hasAudio)
            const Icon(Icons.check_circle, size: 20, color: Color(0xFF4CAF50)),
        ],
      ),
    );
  }
}
