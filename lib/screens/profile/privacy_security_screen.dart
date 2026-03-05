// lib/screens/profile/privacy_security_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/theme.dart';
import '../../widgets/floating_bottom_nav_bar.dart';
import '../CityguideHome/CityListScreen.dart';
import '../favorites/FavoritesScreen.dart';
import '../map/AllPlacesMapScreen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen>
    with SingleTickerProviderStateMixin {
  // Privacy toggles
  bool _profileVisible = true;
  bool _showLocation = true;
  bool _showEmail = false;
  bool _allowMessages = true;

  // Security toggles
  bool _twoFA = false;
  bool _loginAlerts = true;

  bool _loading = true;

  // Bottom navigation index (profile tab)
  int _selectedNavIndex = 3;

  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
        ..forward();
  late final Animation<double> _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  // ── Firebase ──────────────────────────────────────────────────────────────
  Future<void> _loadSettings() async {
    if (_uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('settings')
          .doc('privacy')
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final d = doc.data()!;
        setState(() {
          _profileVisible = d['profileVisible'] as bool? ?? true;
          _showLocation = d['showLocation'] as bool? ?? true;
          _showEmail = d['showEmail'] as bool? ?? false;
          _allowMessages = d['allowMessages'] as bool? ?? true;
          _twoFA = d['twoFA'] as bool? ?? false;
          _loginAlerts = d['loginAlerts'] as bool? ?? true;
        });
      } else {
        await _saveAll();
      }
    } catch (_) {
      // Use defaults silently
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _set(String key, bool val) async {
    if (_uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('settings')
        .doc('privacy')
        .set({key: val}, SetOptions(merge: true));
  }

  Future<void> _saveAll() async {
    if (_uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('settings')
        .doc('privacy')
        .set({
      'profileVisible': _profileVisible,
      'showLocation': _showLocation,
      'showEmail': _showEmail,
      'allowMessages': _allowMessages,
      'twoFA': _twoFA,
      'loginAlerts': _loginAlerts,
    });
  }

  void _showSnack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          success ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        extendBody: true, // Required for floating nav bar
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Privacy & Security',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18)),
          centerTitle: true,
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              )
            : FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.primaryBlue.withOpacity(0.8),
                              AppTheme.primaryBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Privacy & Security',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Control your data and security settings',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Privacy Card ──────────────────────────────
                      _buildSectionCard(
                        title: 'Privacy',
                        icon: Icons.visibility_outlined,
                        children: [
                          _buildToggleTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Profile Visibility',
                            subtitle: 'Let others view your profile',
                            value: _profileVisible,
                            onChanged: (v) {
                              setState(() => _profileVisible = v);
                              _set('profileVisible', v);
                            },
                          ),
                          _buildDivider(),
                          _buildToggleTile(
                            icon: Icons.location_on_outlined,
                            title: 'Show Location',
                            subtitle: 'Display your city on your profile',
                            value: _showLocation,
                            onChanged: (v) {
                              setState(() => _showLocation = v);
                              _set('showLocation', v);
                            },
                          ),
                          _buildDivider(),
                          _buildToggleTile(
                            icon: Icons.email_outlined,
                            title: 'Show Email',
                            subtitle: 'Make email visible to others',
                            value: _showEmail,
                            onChanged: (v) {
                              setState(() => _showEmail = v);
                              _set('showEmail', v);
                            },
                          ),
                          _buildDivider(),
                          _buildToggleTile(
                            icon: Icons.forum_outlined,
                            title: 'Allow Messages',
                            subtitle: 'Let other travellers message you',
                            value: _allowMessages,
                            onChanged: (v) {
                              setState(() => _allowMessages = v);
                              _set('allowMessages', v);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Security Card ─────────────────────────────
                      _buildSectionCard(
                        title: 'Security',
                        icon: Icons.security_outlined,
                        children: [
                          _buildToggleTile(
                            icon: Icons.phonelink_lock_outlined,
                            title: 'Two-Factor Authentication',
                            subtitle: 'Extra verification on login',
                            value: _twoFA,
                            onChanged: (v) {
                              if (v) {
                                _show2FASetup();
                              } else {
                                _disable2FA();
                              }
                            },
                          ),
                          _buildDivider(),
                          _buildToggleTile(
                            icon: Icons.notifications_active_outlined,
                            title: 'Login Alerts',
                            subtitle: 'Notify me of new sign-ins',
                            value: _loginAlerts,
                            onChanged: (v) {
                              setState(() => _loginAlerts = v);
                              _set('loginAlerts', v);
                            },
                          ),
                          _buildDivider(),
                          _buildNavTile(
                            icon: Icons.devices_outlined,
                            title: 'Active Sessions',
                            subtitle: 'Manage logged-in devices',
                            onTap: _showActiveSessions,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Data Card ─────────────────────────────────
                      _buildSectionCard(
                        title: 'Data & Permissions',
                        icon: Icons.manage_accounts_outlined,
                        children: [
                          _buildNavTile(
                            icon: Icons.block_outlined,
                            title: 'Blocked Users',
                            subtitle: 'View and manage blocked accounts',
                            onTap: _showBlockedUsers,
                          ),
                          _buildDivider(),
                          _buildNavTile(
                            icon: Icons.download_outlined,
                            title: 'Download My Data',
                            subtitle: 'Export a copy of your information',
                            onTap: _requestDataDownload,
                          ),
                          _buildDivider(),
                          _buildNavTile(
                            icon: Icons.description_outlined,
                            title: 'Privacy Policy',
                            subtitle: 'How we use your data',
                            onTap: () => _showSnack('Opening Privacy Policy…'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: FloatingBottomNavBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) {
            setState(() => _selectedNavIndex = index);
            if (index == 3) return; // already on profile
            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            }
            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AllPlacesMapScreen()),
              );
            }
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CityListScreen()),
              );
            }
          },
        ),
      ),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          ...children,
          
          // Bottom Padding
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
            activeTrackColor: AppTheme.primaryBlue.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────
  void _show2FASetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: const Text(
          'Two-factor authentication adds an extra layer of security to your account. '
          'You\'ll receive a verification code via SMS each time you sign in.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFA = true);
              _set('twoFA', true);
              _showSnack('Two-Factor Authentication enabled');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _disable2FA() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Two-Factor Authentication'),
        content: const Text(
          'Are you sure you want to disable two-factor authentication? '
          'This will make your account less secure.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFA = false);
              _set('twoFA', false);
              _showSnack('Two-Factor Authentication disabled', success: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSessionItem(
                device: 'iPhone 15 Pro',
                location: 'New York, NY',
                time: 'Active now',
                isCurrent: true,
              ),
              const SizedBox(height: 12),
              _buildSessionItem(
                device: 'MacBook Pro',
                location: 'New York, NY',
                time: '2 hours ago',
                isCurrent: false,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem({
    required String device,
    required String location,
    required String time,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent 
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.devices,
              color: isCurrent ? AppTheme.primaryBlue : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$location • $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Current',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBlockedUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blocked Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No blocked users',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Users you block will appear here',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _requestDataDownload() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'We\'ll prepare a file with your account data and send you an email '
          'when it\'s ready for download. This may take up to 24 hours.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Data download requested');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }
}