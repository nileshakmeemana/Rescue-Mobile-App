import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';

/// Drop-in notification bell for any AppBar — shows unread badge
/// Usage: actions: [NotificationBell()]
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});
  @override State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (_, __) {
        final count = AppState().unreadCount;
        return IconButton(
          onPressed: () => _showNotifications(context),
          icon: Stack(clipBehavior: Clip.none, children: [
            const Icon(Icons.notifications_outlined,
                size: 24, color: Color(0xFF1C1C1E)),
            if (count > 0)
              Positioned(right: -3, top: -3,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: Center(child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 9, fontWeight: FontWeight.w700))))),
          ]),
        );
      },
    );
  }

  void _showNotifications(BuildContext ctx) {
    AppState().markAllRead();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotifSheet(),
    );
  }
}

class _NotifSheet extends StatelessWidget {
  const _NotifSheet();

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (_, __) {
        final notifs = AppState().notifications;
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.92,
          minChildSize: 0.35,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Text('Notifications', style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E))),
                  const Spacer(),
                  if (notifs.isNotEmpty)
                    TextButton(
                      onPressed: () => AppState().markAllRead(),
                      child: Text('Mark all read', style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFFE53935)))),
                ]),
              ),
              const SizedBox(height: 8),
              Expanded(child: notifs.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.notifications_none_rounded, size: 56,
                        color: const Color(0xFFD1D1D6)),
                    const SizedBox(height: 12),
                    Text('No notifications yet', style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF8E8E93))),
                  ]))
                : ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notifs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final n = notifs[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n.isRead ? Colors.white
                              : const Color(0xFFE53935).withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: n.isRead ? const Color(0xFFE5E5EA)
                                : const Color(0xFFE53935).withOpacity(0.2))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Container(width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.1),
                              shape: BoxShape.circle),
                            child: const Icon(Icons.notifications_rounded,
                                size: 18, color: Color(0xFFE53935))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Expanded(child: Text(n.title,
                                style: GoogleFonts.inter(fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1C1C1E)))),
                              if (!n.isRead)
                                Container(width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFE53935),
                                      shape: BoxShape.circle)),
                            ]),
                            const SizedBox(height: 4),
                            Text(n.message, style: GoogleFonts.inter(
                                fontSize: 12, color: const Color(0xFF8E8E93),
                                height: 1.4)),
                            const SizedBox(height: 6),
                            Text(_ago(n.time), style: GoogleFonts.inter(
                                fontSize: 10, color: const Color(0xFFAEAEB2))),
                          ])),
                        ]),
                      );
                    })),
            ]),
          ),
        );
      },
    );
  }
}
