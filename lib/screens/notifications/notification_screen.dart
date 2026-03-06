import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../attraction/AttractionDetailScreen.dart';
import '../CityguideHome/CityDetailScreen.dart';
import '../../widgets/floating_bottom_nav_bar.dart';
import '../profile/profile_screen.dart';
import '../favorites/FavoritesScreen.dart';
import '../map/AllPlacesMapScreen.dart';

// ── Design tokens using AppTheme ────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF8FAFC);
  static const navy = AppTheme.primaryBlue;
  static const blue = AppTheme.primaryBlue;
  static const blueAlt = Color(0xFF3B82F6);
  static const lightB = Color(0xFF93C5FD);
  static const white = Color(0xFFFFFFFF);
  static const glass = Color(0xEAFFFFFF);
  static const textMid = Color(0xFF4A6580);
  static const divider = Color(0x1A1D6EF5);
  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
}

// ── Category metadata matching app categories ───────────────────────────────
class _Category {
  final String id;
  final String label;
  final IconData icon;
  final Color accent;
  final Color surface;
  final String collectionName; // For Firestore navigation

  const _Category(
    this.id,
    this.label,
    this.icon,
    this.accent,
    this.surface,
    this.collectionName,
  );
}

const List<_Category> _kCategories = [
  _Category('all', 'All', Icons.apps_rounded, _C.blue, Color(0xFFEFF6FF), ''),
  _Category('attraction', 'Attractions', Icons.attractions, Colors.orange, Color(0xFFFFF7ED), 'attractions'),
  _Category('dining', 'Dining', Icons.restaurant, Colors.green, Color(0xFFF0FDF4), 'dining'),
  _Category('event', 'Events', Icons.event, Colors.purple, Color(0xFFFAF5FF), 'events'),
  _Category('hotel', 'Hotels', Icons.hotel, Colors.blue, Color(0xFFEFF6FF), 'hotels'),
];

_Category _catFor(String id) =>
    _kCategories.firstWhere((c) => c.id == id, orElse: () => _kCategories[0]);

// ── Screen ────────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  // Animations
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
        ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);

  // State
  String _filter = 'all';
  Set<String> _readIds = {};
  bool _readReady = false;

  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadReadState();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  // ── Firebase helpers ───────────────────────────────────────────────────────

  /// Pull which notif IDs this user has already read
  Future<void> _loadReadState() async {
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .get();

    if (!mounted) return;

    setState(() {
      _readIds = snap.docs.map((d) => d.id).toSet();
      _readReady = true;
    });
  }

  /// Mark a single notification as read
  Future<void> _markRead(String id) async {
    if (_readIds.contains(id)) return;
    setState(() => _readIds.add(id));
    await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(id)
        .set({'readAt': FieldValue.serverTimestamp()});
  }

  /// Batch-mark every visible notification as read
  Future<void> _markAllRead(List<QueryDocumentSnapshot> docs) async {
    final unread = docs.where((d) => !_readIds.contains(d.id)).toList();
    if (unread.isEmpty) return;
    setState(() => _readIds.addAll(unread.map((d) => d.id)));
    final batch = _db.batch();
    for (final d in unread) {
      batch.set(
        _db.collection('users').doc(_uid).collection('notifications').doc(d.id),
        {'readAt': FieldValue.serverTimestamp()},
      );
    }
    await batch.commit();
    _snack('All notifications marked as read', icon: Icons.done_all_rounded);
  }

  /// Dismiss a single notification
  Future<void> _dismiss(String id) async {
    setState(() => _readIds.add(id));
    await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(id)
        .set({'readAt': FieldValue.serverTimestamp(), 'dismissed': true});
  }

  void _snack(String msg, {IconData icon = Icons.check_circle_outline_rounded}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: _C.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(msg,
              style: const TextStyle(
                  color: _C.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ]),
      backgroundColor: _C.blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  /// Navigate to the appropriate detail screen using data from the notification
  Future<void> _navigateToDetail(Map<String, dynamic> data) async {
    try {
      // --- SAFE CONVERSIONS: replace 'as String?' with .toString() ---
      final category = data['category']?.toString() ?? 'attraction';
      final listingId = data['listingId']?.toString();
      final cityId = data['cityId']?.toString();
      final title = data['title']?.toString() ?? 'New Update';
      final imageUrl = data['imageUrl']?.toString() ?? '';
      final address = data['address']?.toString() ?? '';
      final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final priceLevel = data['priceLevel']?.toString() ?? '';

      print('Navigating to: category=$category, listingId=$listingId, cityId=$cityId');

      if (category == 'city') {
        // Navigate to city detail
        final cityDoc = await _db.collection('cities').doc(cityId).get();
        // Ensure cityName is non-null (use fallback)
        final cityName = cityDoc.data()?['name']?.toString() ?? cityId ?? 'City';
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CityDetailScreen(
              cityName: cityName, // now guaranteed non-null
              country: cityDoc.data()?['country']?.toString() ?? 'Nigeria',
              heroImageUrl: imageUrl,
            ),
          ),
        );
        return;
      }

      // For attractions, restaurants, hotels, events
      final cat = _catFor(category);

      // If we don't have cityId or listing ID, we can't navigate
      if (cityId == null || cityId.isEmpty || listingId == null || listingId.isEmpty) {
        _snack('Cannot open details: missing information', icon: Icons.error);
        return;
      }

      // Get city name for display
      final cityDoc = await _db.collection('cities').doc(cityId).get();
      final cityName = cityDoc.data()?['name']?.toString() ?? cityId;

      // Try to find the document - first try by document ID
      DocumentSnapshot doc;
      try {
        doc = await _db
            .collection('cities')
            .doc(cityId)
            .collection(cat.collectionName)
            .doc(listingId)
            .get();
      } catch (e) {
        // If direct ID fails, try searching by name
        print('Direct lookup failed, trying name search: $e');
        final querySnapshot = await _db
            .collection('cities')
            .doc(cityId)
            .collection(cat.collectionName)
            .where('name', isEqualTo: listingId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          _snack('Listing not found', icon: Icons.error);
          return;
        }
        doc = querySnapshot.docs.first;
      }

      if (!doc.exists) {
        _snack('Listing not found', icon: Icons.error);
        return;
      }

      final docData = doc.data() as Map<String, dynamic>;

      // ✅ FIX: Extract coordinates from GeoPoint correctly
      double? lat, lng;
      if (docData['location'] != null && docData['location'] is GeoPoint) {
        final loc = docData['location'] as GeoPoint; // cast to GeoPoint, not Map
        lat = loc.latitude;
        lng = loc.longitude;
      }

      // Navigate to the detail screen with all the data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttractionDetailScreen(
            name: docData['name']?.toString() ?? title,
            imageUrl: docData['imageUrl']?.toString() ?? imageUrl,
            rating: (docData['rating'] as num?)?.toDouble() ?? rating,
            reviewCount: docData['reviewCount'] as int? ?? 0,
            priceLevel: docData['priceLevel']?.toString() ?? priceLevel,
            description: docData['details']?.toString() ?? docData['description']?.toString() ?? '',
            address: docData['address']?.toString() ?? address,
            city: cityName ?? '', // ensure non-null
            website: docData['website']?.toString() ?? '',
            latitude: lat,
            longitude: lng,
            additionalImages: docData['extraImages'] != null
                ? List<String>.from(docData['extraImages'].map((e) => e.toString()))
                : null,
            listingType: cat.collectionName,
          ),
        ),
      );
    } catch (e) {
      print('Navigation error: $e');
      _snack('Could not load details', icon: Icons.error);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        backgroundColor: _C.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey.shade800),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          actions: [
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection('notifications').snapshots(),
              builder: (ctx, snap) {
                final allDocs = snap.data?.docs ?? [];
                final unread = allDocs.where((d) => !_readIds.contains(d.id)).length;
                if (unread == 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => _markAllRead(allDocs),
                    child: Text(
                      'Mark all read',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, snap) {
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text('Error: ${snap.error}'),
                  ],
                ),
              );
            }

            final allDocs = snap.data?.docs ?? [];

            // Filtered list
            final shown = _filter == 'all'
                ? allDocs
                : allDocs
                    .where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['category']?.toString() ?? '') == _filter;
                    })
                    .toList();

            return FadeTransition(
              opacity: _fade,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Sticky category filter row ─────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyDelegate(child: _buildFilterRow()),
                  ),

                  // ── Body ──────────────────────────────────────────────
                  if (!_readReady || snap.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue)),
                      ),
                    )
                  else if (shown.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final data = shown[i].data() as Map<String, dynamic>;
                            return _NotifCard(
                              key: ValueKey(shown[i].id),
                              docId: shown[i].id,
                              data: data,
                              isRead: _readIds.contains(shown[i].id),
                              index: i,
                              onTap: () => _markRead(shown[i].id),
                              onDismiss: () => _dismiss(shown[i].id),
                              onSnack: _snack,
                              onNavigate: () => _navigateToDetail(data),
                            );
                          },
                          childCount: shown.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: FloatingBottomNavBar(
          currentIndex: -1,
          onTap: (index) {
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            }
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllPlacesMapScreen()),
              );
            }
            if (index == 0) {
              // Already on home, maybe do nothing or scroll to top
            }
          },
        ),
      ),
    );
  }

  // ── Filter row ────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Container(
      color: _C.bg,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _kCategories[i];
              final active = _filter == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _filter = cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 230),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: active ? AppTheme.primaryBlue : Colors.grey.shade300,
                      width: 1.4,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(cat.icon,
                        size: 14,
                        color: active ? Colors.white : Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : Colors.grey.shade700)),
                  ]),
                ),
              );
            },
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade200),
      ]),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    final cat = _catFor(_filter);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _filter == 'all'
                    ? AppTheme.primaryBlue.withOpacity(0.1)
                    : cat.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _filter == 'all'
                    ? Icons.notifications_none_rounded
                    : cat.icon,
                size: 40,
                color: _filter == 'all' ? AppTheme.primaryBlue : cat.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _filter == 'all'
                  ? 'No notifications yet'
                  : 'No ${cat.label.toLowerCase()} updates',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              _filter == 'all'
                  ? 'When new attractions, restaurants,\nevents or hotels are added,\nyou\'ll see them here.'
                  : 'No ${cat.label.toLowerCase()} notifications yet.\nCheck back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Card ──────────────────────────────────────────────────────────
class _NotifCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final bool isRead;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final void Function(String, {IconData icon}) onSnack;
  final VoidCallback onNavigate;

  const _NotifCard({
    super.key,
    required this.docId,
    required this.data,
    required this.isRead,
    required this.index,
    required this.onTap,
    required this.onDismiss,
    required this.onSnack,
    required this.onNavigate,
  });

  @override
  State<_NotifCard> createState() => _NotifCardState();
}

class _NotifCardState extends State<_NotifCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
          begin: const Offset(0, 0.08), end: Offset.zero)
      .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    // Stagger cards nicely
    Future.delayed(Duration(milliseconds: 60 + widget.index * 55), () {
      if (mounted) _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    // --- SAFE CONVERSIONS for card fields ---
    final title = d['title']?.toString() ?? 'New Update';
    final body = d['body']?.toString() ?? '';
    final category = d['category']?.toString() ?? 'all';
    final imageUrl = d['imageUrl']?.toString() ?? '';
    final ts = d['createdAt'] as Timestamp?;
    final timeStr = _timeAgo(ts?.toDate());
    final cat = _catFor(category);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey(widget.docId),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => widget.onDismiss(),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 26),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.2),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 24),
                    const SizedBox(height: 4),
                    Text('Dismiss',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
            child: GestureDetector(
              onTap: () {
                widget.onTap();
                widget.onNavigate();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isRead
                        ? Colors.grey.shade200
                        : AppTheme.primaryBlue.withOpacity(0.3),
                    width: widget.isRead ? 1 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image banner ────────────────────────────────
                    if (imageUrl.isNotEmpty)
                      _ImageBanner(
                          imageUrl: imageUrl,
                          cat: cat,
                          isRead: widget.isRead),

                    // ── Card body ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row: category pill | time | unread dot
                          Row(
                            children: [
                              _CategoryPill(cat: cat),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!widget.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: const BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Title
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.isRead ? Colors.grey.shade700 : Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Body
                          if (body.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Action row
                          Row(
                            children: [
                              // View Details CTA
                              Expanded(
                                child: _CtaButton(
                                  label: 'View Details',
                                  accent: cat.accent,
                                  surface: cat.surface,
                                  onTap: () {
                                    widget.onTap();
                                    widget.onNavigate();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Bookmark
                              _IconAction(
                                icon: Icons.bookmark_border_rounded,
                                color: AppTheme.primaryBlue,
                                onTap: () {
                                  widget.onTap();
                                  widget.onSnack('Saved to your places!',
                                      icon: Icons.bookmark_rounded);
                                },
                              ),
                              const SizedBox(width: 8),
                              // Share
                              _IconAction(
                                icon: Icons.share_outlined,
                                color: Colors.grey.shade600,
                                onTap: () => widget.onSnack(
                                    'Sharing coming soon…',
                                    icon: Icons.share_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _ImageBanner extends StatelessWidget {
  final String imageUrl;
  final _Category cat;
  final bool isRead;
  const _ImageBanner(
      {required this.imageUrl, required this.cat, required this.isRead});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(children: [
        Image.network(
          imageUrl,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 160,
            color: cat.surface,
            child: Center(child: Icon(cat.icon, color: cat.accent, size: 40)),
          ),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(
                  height: 160,
                  color: cat.surface,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: cat.accent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Category pill
        Positioned(
          top: 12,
          left: 12,
          child: _CategoryPill(cat: cat, onImage: true),
        ),
        // Unread dot
        if (!isRead)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ]),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final _Category cat;
  final bool onImage;
  const _CategoryPill({required this.cat, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onImage ? Colors.black.withOpacity(0.6) : cat.surface,
        borderRadius: BorderRadius.circular(20),
        border: onImage
            ? Border.all(color: Colors.white.withOpacity(0.3))
            : Border.all(color: cat.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            cat.icon,
            size: 11,
            color: onImage ? Colors.white : cat.accent,
          ),
          const SizedBox(width: 4),
          Text(
            cat.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: onImage ? Colors.white : cat.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final Color accent;
  final Color surface;
  final VoidCallback onTap;
  const _CtaButton({
    required this.label,
    required this.accent,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      );
}

// ── Sticky header delegate ─────────────────────────────────────────────────────
class _StickyDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _StickyDelegate({required this.child});

  @override
  double get minExtent => 57;
  @override
  double get maxExtent => 57;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(_StickyDelegate old) => old.child != child;
}

// ── Time-ago helper ────────────────────────────────────────────────────────────
String _timeAgo(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7}w ago';
  return DateFormat('MMM d').format(dt);
}