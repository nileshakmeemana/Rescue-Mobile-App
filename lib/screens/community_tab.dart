import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../widgets/notification_bell.dart';
import 'add_post_screen.dart';
import 'community_post_detail_screen.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  static const _ads = [
    {'color': 0xFFE57373, 'icon': Icons.car_rental, 'label': 'Auto Deals'},
    {'color': 0xFF81C784, 'icon': Icons.calendar_today, 'label': 'Schedule'},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (_, __) {
        final region = AppState().region;
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
              child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Community',
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
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddPostScreen())),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE53935).withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text('Post',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE53935))))),
                      const SizedBox(width: 8),
                      const NotificationBell(),
                    ]))),

            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text('Posts',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1C1E))))),

            // Live posts stream from Firestore
            SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: region.isNotEmpty
                        ? FirebaseService().streamRegionalPosts(region)
                        : FirebaseService().streamMyPosts(),
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFE53935))));
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(children: [
                              const Icon(Icons.article_outlined,
                                  size: 48, color: Color(0xFFD1D1D6)),
                              const SizedBox(height: 12),
                              Text(
                                  region.isNotEmpty
                                      ? 'No posts for $region yet.'
                                      : 'Set your location to see regional posts.',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF8E8E93)),
                                  textAlign: TextAlign.center),
                            ]
                            )
                            );
                      }
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.85),
                              itemCount: docs.length,
                              itemBuilder: (_, i) {
                                final post =
                                    FirebaseService.postFromDoc(docs[i]);
                                final isOwn =
                                    post['postedBy'] == FirebaseService().uid;
                                return _PostCard(
                                    post: post,
                                    isUserPost: isOwn,
                                    onDelete: isOwn
                                        ? () => FirebaseService()
                                            .deletePost(post['id'])
                                        : null,
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                CommunityPostDetailScreen(
                                                    post: post))));
                              }
                              )
                              );
                    }
                    )
                    ),

            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text('Advertisements',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1C1E))))),

            SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                        (_, i) =>
                            _AdCard(ad: Map<String, dynamic>.from(_ads[i])),
                        childCount: _ads.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1))),
          ]
          )
          ),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isUserPost;
  final VoidCallback? onDelete;
  final VoidCallback onTap;
  const _PostCard(
      {required this.post,
      required this.isUserPost,
      this.onDelete,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(post['color'] as int? ?? 0xFF7CB342);
    final mediaUrls =
        (post['mediaUrls'] as List?)?.whereType<String>().toList() ?? const [];
    final thumbnailAsset = _thumbnailAssetFor(post);
    return GestureDetector(
        onTap: onTap,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    color: color.withOpacity(0.16),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: mediaUrls.isEmpty
                        ? Image.asset(
                            thumbnailAsset,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.image_outlined,
                                  size: 38, color: color),
                            ),
                          )
                        : Image.network(
                            mediaUrls.first,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.broken_image_outlined,
                                  size: 38, color: color),
                            ),
                          ),
                  ),
                ),
                if (isUserPost && onDelete != null)
                  Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                          onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)
                                              ),
                                      title: Text('Delete Post',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700)
                                              ),
                                      content: Text('Remove this post?',
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF8E8E93)
                                              )
                                              ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancel',
                                                style: GoogleFonts.inter(
                                                    color: const Color(
                                                        0xFF8E8E93))
                                                        )
                                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              onDelete!();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFE53935),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                            child: Text('Delete',
                                                style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                      ])),
                          child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: Color(0xFFE53935))))),
              ])),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['title'] as String,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C1C1E)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(post['subtitle'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: const Color(0xFF8E8E93))),
                      ])),
            ])));
  }

  String _thumbnailAssetFor(Map<String, dynamic> post) {
    final id = (post['id'] as String?) ?? '';
    final chooseFirst = id.hashCode.isEven;
    return chooseFirst
        ? 'assets/images/Post_1.png'
        : 'assets/images/Post_2.png';
  }
}

class _AdCard extends StatelessWidget {
  final Map<String, dynamic> ad;
  const _AdCard({required this.ad});
  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
          color: Color(ad['color'] as int),
          borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(ad['icon'] as IconData,
            size: 44, color: Colors.white.withOpacity(0.9)),
        const SizedBox(height: 8),
        Text(ad['label'] as String,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ]
      )
      );
}