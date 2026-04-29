import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../widgets/notification_bell.dart';
import 'add_incident_screen.dart';
import 'incident_detail_screen.dart';

class SOSTab extends StatefulWidget {
  final String? initialCategory;
  final VoidCallback? onCategoryConsumed;
  const SOSTab({super.key, this.initialCategory, this.onCategoryConsumed});
  @override
  State<SOSTab> createState() => _SOSTabState();
}

class _SOSTabState extends State<SOSTab> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAdd(prefilledCategory: widget.initialCategory);
        widget.onCategoryConsumed?.call();
      });
    }
  }

  @override
  void didUpdateWidget(SOSTab old) {
    super.didUpdateWidget(old);
    if (widget.initialCategory != null &&
        widget.initialCategory != old.initialCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAdd(prefilledCategory: widget.initialCategory);
        widget.onCategoryConsumed?.call();
      });
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAdd({String? prefilledCategory}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                AddIncidentScreen(prefilledCategory: prefilledCategory)));
  }

  void _openDetail(Map<String, dynamic> incident, {bool canDelete = false}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(
                incident: incident,
                canDelete: canDelete,
                onDelete: canDelete
                    ? () =>
                        FirebaseService().deleteIncident(incident['id'] ?? '')
                    : null)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (_, __) {
        final region = AppState().region;
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
              child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergencies',
                            style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C1C1E))),
                        if (region.isNotEmpty)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.location_on,
                                size: 12, color: Color(0xFFE53935)),
                            const SizedBox(width: 3),
                            Text(region,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFFE53935),
                                    fontWeight: FontWeight.w500)),
                          ]),
                      ]),
                  const Spacer(),
                  GestureDetector(
                      onTap: () => _openAdd(),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.add,
                                size: 16, color: Color(0xFFE53935)),
                            const SizedBox(width: 4),
                            Text('Add Incident',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE53935))),
                          ]))),
                  const SizedBox(width: 10),
                  const NotificationBell(),
                ])),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22)),
                    child: TabBar(
                        controller: _tabCtrl,
                        indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w400),
                        labelColor: const Color(0xFFE53935),
                        unselectedLabelColor: const Color(0xFF8E8E93),
                        tabs: const [
                          Tab(text: 'Reported By You'),
                          Tab(text: 'Reported By Other'),
                        ]))),
            const SizedBox(height: 16),
            Expanded(
                child: TabBarView(controller: _tabCtrl, children: [
              // My incidents — live Firestore stream
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseService().streamMyIncidents(),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE53935)));
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return _emptyState(
                          icon: Icons.warning_amber_outlined,
                          msg:
                              'No incidents reported by you yet.\nTap "Add Incident" to report one.');
                    }
                    return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final inc = FirebaseService.incidentFromDoc(docs[i]);
                          return _IncidentCard(
                              incident: inc,
                              showClear: true,
                              onClear: () =>
                                  FirebaseService().deleteIncident(inc['id']),
                              onTap: () => _openDetail(inc, canDelete: true));
                        });
                  }),

              // Regional — live Firestore stream
              region.isEmpty
                  ? _noLocation()
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseService().streamRegionalIncidents(region),
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFE53935)));
                        }
                        final docs = (snap.data?.docs ?? []).where((doc) {
                          final incident = FirebaseService.incidentFromDoc(doc);
                          return incident['reportedBy'] !=
                              FirebaseService().uid;
                        }).toList();
                        if (docs.isEmpty) {
                          return _emptyState(
                              icon: Icons.check_circle_outline,
                              msg: 'No incidents near $region right now.');
                        }
                        return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final inc =
                                  FirebaseService.incidentFromDoc(docs[i]);
                              return _IncidentCard(
                                  incident: inc,
                                  showClear: false,
                                  onTap: () => _openDetail(inc));
                            });
                      }),
            ])),
          ])),
        );
      },
    );
  }

  Widget _emptyState({required IconData icon, required String msg}) => Center(
      child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 56, color: const Color(0xFFD1D1D6)),
            const SizedBox(height: 14),
            Text(msg,
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF8E8E93), height: 1.5),
                textAlign: TextAlign.center),
          ])));

  Widget _noLocation() => Center(
      child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.location_off_outlined,
                size: 56, color: Color(0xFFD1D1D6)),
            const SizedBox(height: 14),
            Text(
                'Set your location on the Home screen\nto see regional incidents.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF8E8E93), height: 1.5),
                textAlign: TextAlign.center),
          ])));
}

class _IncidentCard extends StatelessWidget {
  final Map<String, dynamic> incident;
  final bool showClear;
  final VoidCallback? onClear;
  final VoidCallback onTap;
  const _IncidentCard(
      {required this.incident,
      required this.showClear,
      this.onClear,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF1C1C1E)),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(incident['location'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1C1E)))),
              if (showClear && onClear != null)
                GestureDetector(
                    onTap: onClear,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Clear',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE53935))))),
            ]),
            const SizedBox(height: 8),
            Text(incident['type'] as String,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E))),
            const SizedBox(height: 6),
            Text(incident['description'] as String,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF8E8E93), height: 1.5)),
          ])));
}
