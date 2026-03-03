// lib/screens/profile/profile_screen.dart
//
// Design: Refined "arctic glass" — crisp white + ocean-blue gradient hero,
// frosted-glass cards floating over a subtle mesh background, smooth
// entrance animation, real-time Firestore stream.

import 'dart:ui';
import 'package:city_guide_app/screens/CityguideHome/CityListScreen.dart';
import 'package:city_guide_app/screens/favorites/FavoritesScreen.dart';
import 'package:city_guide_app/screens/map/AllPlacesMapScreen.dart';
import 'package:city_guide_app/widgets/floating_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/routes.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'privacy_security_screen.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFEFF6FF); // sky-50
  static const navy     = Color(0xFF0C2340); // deep brand navy
  static const blue     = Color(0xFF1D6EF5); // primary blue
  static const blueAlt  = Color(0xFF3B82F6); // blue-500
  static const lightB   = Color(0xFF93C5FD); // blue-300
  static const white    = Color(0xFFFFFFFF);
  static const glass    = Color(0xE6FFFFFF); // 90 % white
  static const divider  = Color(0x1A1D6EF5); // blue 10 %
  static const textMid  = Color(0xFF4A6580);
  static const error    = Color(0xFFDC2626);
}

// ── Shared Glass Card ─────────────────────────────────────────────────────────
class ProfileGlassCard extends StatelessWidget {

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  const ProfileGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: _C.glass,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: borderColor ?? _C.blue.withOpacity(0.14),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.blue.withOpacity(0.08),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
}

// ── Profile Screen ────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

     int _selectedNavIndex =3;
  // animations
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 750))
        ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
          begin: const Offset(0, .08), end: Offset.zero)
      .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  // toggles (local + synced to Firestore)
  bool _pushNotif   = true;
  bool _emailNotif  = false;
  bool _notifInited = false;

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Persist toggle updates
  Future<void> _setPref(String field, bool val) =>
      FirebaseFirestore.instance.collection('users').doc(_uid).update({field: val});

  // Sign-out
  Future<void> _signOut() async {
    final ok = await _confirmDialog(
      icon: Icons.logout_rounded,
      iconColor: _C.error,
      title: 'Sign Out',
      message: 'You will be returned to the login screen.',
      confirmLabel: 'Sign Out',
      destructive: true,
    );
    if (!ok) return;
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }
  }

  Future<bool> _confirmDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          barrierColor: _C.navy.withOpacity(0.45),
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, anim, __) => FadeTransition(
            opacity: anim,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ProfileGlassCard(
                  padding: const EdgeInsets.all(28),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 26),
                      ),
                      const SizedBox(height: 16),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _C.navy)),
                      const SizedBox(height: 8),
                      Text(message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: _C.textMid)),
                      const SizedBox(height: 28),
                      Row(children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                      color: _C.navy.withOpacity(0.18))),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(color: _C.navy, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  destructive ? _C.error : _C.blue,
                              foregroundColor: _C.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(confirmLabel,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
         extendBody: true,
        backgroundColor: _C.bg,
        extendBodyBehindAppBar: true,
        appBar: _appBar(),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_uid)
              .snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(_C.blue)));
            }
            final data =
                (snap.data?.data() as Map<String, dynamic>?) ?? {};

            // Sync toggles once after first load
            if (!_notifInited) {
              _pushNotif  = data['pushNotifications'] ?? true;
              _emailNotif = data['emailNotifications'] ?? false;
              _notifInited = true;
            }

            return FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [
                    _hero(data),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(children: [
                          _accountInfoCard(data),
                          const SizedBox(height: 16),
                          _notificationsCard(),
                          const SizedBox(height: 16),
                          _settingsCard(),
                          const SizedBox(height: 16),
                          _signOutCard(),
                          const SizedBox(height: 52),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 3) {
           }
            if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );}
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllPlacesMapScreen()),
            );
          }
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CityListScreen()),
            );          }
        },
      ),
      ),
    );
  }

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _C.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile',
            style: TextStyle(
                color: _C.white, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined,
                color: _C.white, size: 22),
            tooltip: 'Privacy & Security',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const PrivacySecurityScreen())),
          ),
        ],
      );

  // ── Hero ─────────────────────────────────────────────────────────────────────
  Widget _hero(Map<String, dynamic> data) {
    final name     = data['fullName']     as String? ?? 'Traveller';
    final email    = data['email']        as String? ??
        FirebaseAuth.instance.currentUser?.email ?? '';
    final location = data['location']     as String? ?? '';
    final photo    = data['profileImage'] as String? ?? '';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.navy, Color(0xFF1A56CF), _C.blueAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        // decorative blobs
        Positioned(top: -60, right: -60,
            child: _blob(220, _C.white.withOpacity(0.04))),
        Positioned(bottom: 30, left: -80,
            child: _blob(260, _C.white.withOpacity(0.04))),
        Positioned(top: 80, right: 50,
            child: _blob(90, _C.white.withOpacity(0.07))),
        Positioned(bottom: 80, right: 30,
            child: _blob(50, _C.lightB.withOpacity(0.15))),

        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 70, bottom: 70),
            child: Column(children: [
              // avatar
              Stack(children: [
                Container(
                  width: 104, height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.white, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: _C.navy.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(child: _avatarWidget(photo, name)),
                ),
                Positioned(
                  bottom: 2, right: 2,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    ),
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: _C.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: _C.white, width: 2.5),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: _C.white),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              Text(name,
                  style: const TextStyle(
                      color: _C.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),

              const SizedBox(height: 4),

              Text(email,
                  style: TextStyle(
                      color: _C.white.withOpacity(0.72), fontSize: 14)),

              if (location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.location_on_rounded,
                      size: 15, color: _C.lightB),
                  const SizedBox(width: 4),
                  Text(location,
                      style: TextStyle(
                          color: _C.white.withOpacity(0.85), fontSize: 13.5)),
                ]),
              ],

              const SizedBox(height: 24),

              // glass "Edit Profile" pill button
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 13),
                      decoration: BoxDecoration(
                        color: _C.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: _C.white.withOpacity(0.35), width: 1.2),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(
                              color: _C.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3)),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Account Info Card ─────────────────────────────────────────────────────────
  Widget _accountInfoCard(Map<String, dynamic> data) {
    final phone  = data['phone']     as String? ?? '—';
    final bio    = data['bio']       as String? ?? '';
    final ts     = data['createdAt'] as Timestamp?;
    final joined = ts != null
        ? '${_monthAbbr(ts.toDate().month)} ${ts.toDate().year}'
        : '—';

    return ProfileGlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle('Account Info', Icons.person_outline_rounded),
        const SizedBox(height: 18),
        _infoTile(Icons.phone_outlined, 'Phone', phone),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 14),
          _infoTile(Icons.auto_stories_outlined, 'Bio', bio),
        ],
        const SizedBox(height: 14),
        _infoTile(Icons.calendar_month_outlined, 'Member since', joined),
      ]),
    );
  }

  // ── Notifications Card ────────────────────────────────────────────────────────
  Widget _notificationsCard() => ProfileGlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardTitle('Notifications', Icons.notifications_outlined),
          const SizedBox(height: 18),
          _toggleRow(
            icon: Icons.campaign_outlined,
            label: 'Push Notifications',
            sub: 'Alerts sent directly to your device',
            value: _pushNotif,
            onChange: (v) {
              setState(() => _pushNotif = v);
              _setPref('pushNotifications', v);
            },
          ),
          Divider(height: 28, color: _C.divider),
          _toggleRow(
            icon: Icons.mark_email_unread_outlined,
            label: 'Email Updates',
            sub: 'News, tips and trip suggestions',
            value: _emailNotif,
            onChange: (v) {
              setState(() => _emailNotif = v);
              _setPref('emailNotifications', v);
            },
          ),
        ]),
      );

  // ── Settings Card ──────────────────────────────────────────────────────────────
  Widget _settingsCard() => ProfileGlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardTitle('Settings', Icons.tune_rounded),
          const SizedBox(height: 18),
          _settingRow(
            icon: Icons.lock_reset_rounded,
            label: 'Change Password',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen())),
          ),
          Divider(height: 28, color: _C.divider),
          _settingRow(
            icon: Icons.shield_outlined,
            label: 'Privacy & Security',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const PrivacySecurityScreen())),
          ),
          Divider(height: 28, color: _C.divider),
          _settingRow(
            icon: Icons.favorite_border_rounded,
            label: 'Saved Places',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.favorites),
          ),
          Divider(height: 28, color: _C.divider),
          _settingRow(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: _showHelp,
          ),
        ]),
      );

  // ── Sign-out Card ─────────────────────────────────────────────────────────────
  Widget _signOutCard() => GestureDetector(
        onTap: _signOut,
        child: ProfileGlassCard(
          borderColor: _C.error.withOpacity(0.28),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.logout_rounded, color: _C.error, size: 21),
            const SizedBox(width: 10),
            const Text('Sign Out',
                style: TextStyle(
                    color: _C.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ]),
        ),
      );

  // ── Help Bottom Sheet ─────────────────────────────────────────────────────────
  void _showHelp() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: _C.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding:
              const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // drag handle
            Center(
              child: Container(
                width: 42, height: 4, margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Help & Support',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _C.navy)),
            ),
            const SizedBox(height: 20),
            _helpItem(Icons.email_outlined, 'Email Support',
                'support@cityguide.app'),
            _helpItem(Icons.menu_book_outlined, 'Documentation',
                'Help centre & FAQs'),
            _helpItem(Icons.bug_report_outlined, 'Report a Bug',
                'Submit an issue report'),
          ]),
        ),
      );

  // ── Small shared helpers ──────────────────────────────────────────────────────
  Widget _avatarWidget(String photo, String name) {
    if (photo.isNotEmpty) {
      return Image.network(photo,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsBox(name));
    }
    return _initialsBox(name);
  }

  Widget _initialsBox(String name) {
    final parts = name.trim().split(' ');
    final initials =
        parts.map((e) => e.isEmpty ? '' : e[0]).take(2).join().toUpperCase();
    return Container(
      color: _C.navy,
      child: Center(
        child: Text(initials.isEmpty ? '?' : initials,
            style: const TextStyle(
                color: _C.white,
                fontSize: 36,
                fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _cardTitle(String label, IconData icon) => Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_C.blue, _C.blueAlt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: _C.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: _C.navy,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
      ]);

  Widget _infoTile(IconData icon, String label, String value) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: _C.blue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: _C.blue, size: 17),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11.5,
                    color: _C.textMid,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    color: _C.navy,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]);

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required String sub,
    required bool value,
    required Function(bool) onChange,
  }) =>
      Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: _C.blue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: _C.blue, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    color: _C.navy,
                    fontWeight: FontWeight.w600)),
            Text(sub,
                style: TextStyle(
                    fontSize: 12, color: _C.textMid)),
          ]),
        ),
        Switch(
          value: value,
          onChanged: onChange,
          activeColor: _C.blue,
          activeTrackColor: _C.blue.withOpacity(0.22),
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[200],
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]);

  Widget _settingRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: _C.blue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: _C.blue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    color: _C.navy,
                    fontWeight: FontWeight.w600)),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: _C.navy.withOpacity(0.30)),
        ]),
      );

  Widget _helpItem(IconData icon, String title, String sub) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: _C.blue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: _C.blue, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: _C.navy, fontSize: 15)),
        subtitle: Text(sub,
            style: TextStyle(color: _C.textMid, fontSize: 13)),
        trailing: Icon(Icons.chevron_right,
            color: _C.navy.withOpacity(0.28)),
      );

  String _monthAbbr(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}