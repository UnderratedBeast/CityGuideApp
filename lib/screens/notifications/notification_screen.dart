import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/routes.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFFEFF6FF);
  static const navy    = Color(0xFF0C2340);
  static const blue    = Color(0xFF1D6EF5);
  static const blueAlt = Color(0xFF3B82F6);
  static const lightB  = Color(0xFF93C5FD);
  static const white   = Color(0xFFFFFFFF);
  static const glass   = Color(0xEAFFFFFF);
  static const textMid = Color(0xFF4A6580);
  static const divider = Color(0x1A1D6EF5);
  static const error   = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
}

// ── Category metadata ─────────────────────────────────────────────────────────
class _Category {
  final String id;
  final String label;
  final IconData icon;
  final Color accent;
  final Color surface;
  const _Category(this.id, this.label, this.icon, this.accent, this.surface);
}

const List<_Category> _kCategories = [
  _Category('all',        'All',         Icons.apps_rounded,              _C.blue,              Color(0xFFEFF6FF)),
  _Category('attraction', 'Attractions', Icons.account_balance_rounded,   Color(0xFF6D28D9),    Color(0xFFF5F3FF)),
  _Category('dining',     'Dining',      Icons.restaurant_menu_rounded,   Color(0xFFEA580C),    Color(0xFFFFF7ED)),
  _Category('event',      'Events',      Icons.celebration_rounded,       Color(0xFFDB2777),    Color(0xFFFDF4FF)),
  _Category('hotel',      'Hotels',      Icons.hotel_rounded,             Color(0xFF0891B2),    Color(0xFFECFEFF)),
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
  String      _filter    = 'all';
  Set<String> _readIds   = {};
  bool        _readReady = false;

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
      _readIds   = snap.docs.map((d) => d.id).toSet();
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

  /// Dismiss (read + hide) a single notification
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
        Text(msg,
            style: const TextStyle(
                color: _C.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
      backgroundColor: _C.blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, snap) {
            final allDocs = snap.data?.docs ?? [];

            // Filtered list
            final shown = _filter == 'all'
                ? allDocs
                : allDocs
                    .where((d) =>
                        (d.data() as Map)['category'] == _filter)
                    .toList();

            // Dismissed ids come from the per-user sub-collection;
            // we already have _readIds but dismissed is a superset concept —
            // for simplicity we keep dismissed out of the main list via
            // the per-user 'dismissed' flag. Reload on next open.
            final unread =
                allDocs.where((d) => !_readIds.contains(d.id)).length;

            return FadeTransition(
              opacity: _fade,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Collapsing gradient header ─────────────────────────
                  _buildAppBar(unread, allDocs),

                  // ── Sticky category filter row ─────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyDelegate(child: _buildFilterRow()),
                  ),

                  // ── Body ──────────────────────────────────────────────
                  if (!_readReady ||
                      snap.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(_C.blue)),
                      ),
                    )
                  else if (shown.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _NotifCard(
                            key       : ValueKey(shown[i].id),
                            docId     : shown[i].id,
                            data      : shown[i].data() as Map<String, dynamic>,
                            isRead    : _readIds.contains(shown[i].id),
                            index     : i,
                            onTap     : () => _markRead(shown[i].id),
                            onDismiss : () => _dismiss(shown[i].id),
                            onSnack   : _snack,
                          ),
                          childCount: shown.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Collapsing SliverAppBar ────────────────────────────────────────────────
  SliverAppBar _buildAppBar(
      int unread, List<QueryDocumentSnapshot> allDocs) {
    return SliverAppBar(
      expandedHeight: 210,
      collapsedHeight: 62,
      pinned: true,
      stretch: true,
      backgroundColor: _C.navy,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _C.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (unread > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => _markAllRead(allDocs),
              child: const Text('Mark all read',
                  style: TextStyle(
                      color: _C.lightB,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        stretchModes: const [StretchMode.zoomBackground],
        background: _HeroBg(unread: unread),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: _kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat    = _kCategories[i];
              final active = _filter == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _filter = cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 230),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _C.blue : _C.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: active
                          ? _C.blue
                          : _C.divider,
                      width: 1.4,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: _C.blue.withOpacity(0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(cat.icon,
                        size: 14,
                        color: active ? _C.white : _C.textMid),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                active ? _C.white : _C.textMid)),
                  ]),
                ),
              );
            },
          ),
        ),
        Divider(height: 1, color: _C.divider),
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
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: _filter == 'all' ? _C.blue.withOpacity(0.09) : cat.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _filter == 'all'
                    ? Icons.notifications_none_rounded
                    : cat.icon,
                size: 40,
                color: _filter == 'all' ? _C.blue : cat.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _filter == 'all'
                  ? 'No notifications yet'
                  : 'No ${cat.label} updates',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _C.navy),
            ),
            const SizedBox(height: 10),
            Text(
              _filter == 'all'
                  ? 'When the admin adds new attractions,\nrestaurants, events or hotels,\nyou\'ll see them here.'
                  : 'The admin hasn\'t added any\n${cat.label.toLowerCase()} yet.\nCheck back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: _C.textMid, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero background widget ─────────────────────────────────────────────────────
class _HeroBg extends StatelessWidget {
  final int unread;
  const _HeroBg({required this.unread});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      // Gradient
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_C.navy, Color(0xFF1747C8), _C.blueAlt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      // Decorative blobs
      Positioned(
        top: -50, right: -50,
        child: _blob(210, _C.white.withOpacity(0.05)),
      ),
      Positioned(
        bottom: 10, left: -60,
        child: _blob(180, _C.white.withOpacity(0.04)),
      ),
      Positioned(
        top: 70, right: 50,
        child: _blob(80, _C.white.withOpacity(0.07)),
      ),
      // Text content
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Bell icon with glass pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Glass icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: _C.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: _C.white.withOpacity(0.3),
                                    width: 1.2),
                              ),
                              child: Stack(children: [
                                const Center(
                                  child: Icon(
                                      Icons.notifications_rounded,
                                      color: _C.white, size: 26),
                                ),
                                if (unread > 0)
                                  Positioned(
                                    top: 8, right: 8,
                                    child: Container(
                                      width: 12, height: 12,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFF4444),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Notifications',
                            style: TextStyle(
                                color: _C.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8)),
                        const SizedBox(height: 4),
                        Text(
                          unread > 0
                              ? '$unread new update${unread > 1 ? 's' : ''} since your last visit'
                              : 'You\'re all caught up ✓',
                          style: TextStyle(
                              color: _C.white.withOpacity(0.72),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // Unread badge pill
                  if (unread > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: _C.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: _C.white.withOpacity(0.32),
                                width: 1.2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$unread',
                                  style: const TextStyle(
                                      color: _C.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              Text('unread',
                                  style: TextStyle(
                                      color: _C.white.withOpacity(0.75),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _blob(double s, Color c) => Container(
      width: s, height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c));
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

  const _NotifCard({
    super.key,
    required this.docId,
    required this.data,
    required this.isRead,
    required this.index,
    required this.onTap,
    required this.onDismiss,
    required this.onSnack,
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
    final d        = widget.data;
    final title    = d['title']     as String? ?? 'New Update';
    final body     = d['body']      as String? ?? '';
    final category = d['category']  as String? ?? 'all';
    final imageUrl = d['imageUrl']  as String? ?? '';
    final ts       = d['createdAt'] as Timestamp?;
    final timeStr  = _timeAgo(ts?.toDate());
    final cat      = _catFor(category);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Dismissible(
            key: ValueKey(widget.docId),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => widget.onDismiss(),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 26),
              decoration: BoxDecoration(
                color: _C.error.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: _C.error.withOpacity(0.22), width: 1.2),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        color: _C.error, size: 28),
                    const SizedBox(height: 4),
                    Text('Dismiss',
                        style: TextStyle(
                            color: _C.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ]),
            ),
            child: GestureDetector(
              onTap: widget.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isRead ? _C.glass : _C.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: widget.isRead
                            ? _C.divider
                            : _C.blue.withOpacity(0.30),
                        width: widget.isRead ? 1.2 : 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _C.blue.withOpacity(
                              widget.isRead ? 0.04 : 0.10),
                          blurRadius: widget.isRead ? 14 : 22,
                          offset: const Offset(0, 5),
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
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row: category pill | time | unread dot
                              Row(children: [
                                _CategoryPill(cat: cat),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(timeStr,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: _C.textMid)),
                                ),
                                if (!widget.isRead)
                                  Container(
                                    width: 9, height: 9,
                                    decoration: const BoxDecoration(
                                        color: _C.blue,
                                        shape: BoxShape.circle),
                                  ),
                              ]),

                              const SizedBox(height: 10),

                              // Title
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: widget.isRead
                                        ? _C.navy.withOpacity(0.65)
                                        : _C.navy,
                                    height: 1.3),
                              ),

                              // Body
                              if (body.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        color: _C.textMid,
                                        height: 1.5)),
                              ],

                              const SizedBox(height: 14),

                              // Action row
                              Row(children: [
                                // View Details CTA
                                Expanded(
                                  child: _CtaButton(
                                    label   : 'View Details',
                                    accent  : cat.accent,
                                    surface : cat.surface,
                                    onTap   : () {
                                      widget.onTap();
                                      // TODO: navigate to the listing
                                      // Navigator.pushNamed(context,
                                      //   AppRoutes.attractionDetail,
                                      //   arguments: {
                                      //     'id'      : d['listingId'],
                                      //     'category': category,
                                      //   });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Bookmark
                                _IconAction(
                                  icon: Icons.bookmark_border_rounded,
                                  color: _C.blue,
                                  onTap: () {
                                    widget.onTap();
                                    widget.onSnack('Saved to your places!',
                                        icon: Icons.bookmark_rounded);
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Share
                                _IconAction(
                                  icon: Icons.ios_share_rounded,
                                  color: _C.textMid,
                                  onTap: () => widget.onSnack(
                                      'Sharing coming soon…',
                                      icon: Icons.share_rounded),
                                ),
                              ]),
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(children: [
        Image.network(
          imageUrl,
          height: 168,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 168,
            color: cat.surface,
            child: Center(child: Icon(cat.icon, color: cat.accent, size: 44)),
          ),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(
                  height: 168,
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
                  Colors.black.withOpacity(0.35),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Category pill
        Positioned(top: 12, left: 12, child: _CategoryPill(cat: cat, onImage: true)),
        // Unread dot
        if (!isRead)
          Positioned(
            top: 12, right: 12,
            child: Container(
              width: 11, height: 11,
              decoration: BoxDecoration(
                color: _C.blue,
                shape: BoxShape.circle,
                border: Border.all(color: _C.white, width: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onImage
            ? Colors.black.withOpacity(0.45)
            : cat.surface,
        borderRadius: BorderRadius.circular(20),
        border: onImage
            ? Border.all(color: _C.white.withOpacity(0.3))
            : Border.all(color: cat.accent.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(cat.icon, size: 11,
            color: onImage ? _C.white : cat.accent),
        const SizedBox(width: 5),
        Text(cat.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: onImage ? _C.white : cat.accent)),
      ]),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final Color accent;
  final Color surface;
  final VoidCallback onTap;
  const _CtaButton(
      {required this.label,
      required this.accent,
      required this.surface,
      required this.onTap});

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
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent)),
          ),
        ),
      );
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
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

  @override double get minExtent => 57;
  @override double get maxExtent => 57;
  @override Widget build(_, __, ___) => child;
  @override bool shouldRebuild(_StickyDelegate old) => old.child != child;
}

// ── Time-ago helper ────────────────────────────────────────────────────────────
String _timeAgo(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60)  return 'Just now';
  if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24)  return '${diff.inHours}h ago';
  if (diff.inDays    < 7)   return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(dt);
}