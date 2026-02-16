// lib/screens/settings/privacy_security_screen.dart

import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // Privacy settings
  bool _profileVisibility = true;
  bool _showLocation = true;
  bool _showEmail = false;
  bool _allowMessages = true;

  // Security settings
  bool _twoFactorAuth = false;
  bool _loginAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Load settings from Firestore
    /*
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final settingsDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('privacy')
            .get();
        
        if (mounted && settingsDoc.exists) {
          final data = settingsDoc.data()!;
          setState(() {
            _profileVisibility = data['profileVisibility'] ?? true;
            _showLocation = data['showLocation'] ?? true;
            _showEmail = data['showEmail'] ?? false;
            _allowMessages = data['allowMessages'] ?? true;
            _twoFactorAuth = data['twoFactorAuth'] ?? false;
            _loginAlerts = data['loginAlerts'] ?? true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    */
  }

  Future<void> _updateSetting(String key, bool value) async {
    // TODO: Update setting in Firestore
    /*
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('privacy')
            .set({key: value}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error updating setting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Privacy Settings Section
          Container(
            color: AppTheme.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Privacy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ),
                _buildSwitchTile(
                  icon: Icons.visibility_outlined,
                  title: 'Profile Visibility',
                  subtitle: 'Make your profile visible to others',
                  value: _profileVisibility,
                  onChanged: (value) {
                    setState(() => _profileVisibility = value);
                    _updateSetting('profileVisibility', value);
                  },
                ),
                const Divider(height: 1, indent: 72),
                _buildSwitchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Show Location',
                  subtitle: 'Display your city on profile',
                  value: _showLocation,
                  onChanged: (value) {
                    setState(() => _showLocation = value);
                    _updateSetting('showLocation', value);
                  },
                ),
                const Divider(height: 1, indent: 72),
                _buildSwitchTile(
                  icon: Icons.email_outlined,
                  title: 'Show Email',
                  subtitle: 'Make email visible to others',
                  value: _showEmail,
                  onChanged: (value) {
                    setState(() => _showEmail = value);
                    _updateSetting('showEmail', value);
                  },
                ),
                const Divider(height: 1, indent: 72),
                _buildSwitchTile(
                  icon: Icons.message_outlined,
                  title: 'Allow Messages',
                  subtitle: 'Let other users message you',
                  value: _allowMessages,
                  onChanged: (value) {
                    setState(() => _allowMessages = value);
                    _updateSetting('allowMessages', value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Security Settings Section
          Container(
            color: AppTheme.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ),
                _buildSwitchTile(
                  icon: Icons.security,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add extra security to your account',
                  value: _twoFactorAuth,
                  onChanged: (value) {
                    if (value) {
                      _show2FASetupDialog();
                    } else {
                      _show2FADisableDialog();
                    }
                  },
                ),
                const Divider(height: 1, indent: 72),
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Login Alerts',
                  subtitle: 'Get notified of new logins',
                  value: _loginAlerts,
                  onChanged: (value) {
                    setState(() => _loginAlerts = value);
                    _updateSetting('loginAlerts', value);
                  },
                ),
                const Divider(height: 1, indent: 72),
                _buildListTile(
                  icon: Icons.devices_outlined,
                  title: 'Active Sessions',
                  subtitle: 'Manage devices and sessions',
                  onTap: () => _showActiveSessionsDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Data & Permissions Section
          Container(
            color: AppTheme.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Data & Permissions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.block_outlined,
                  title: 'Blocked Users',
                  subtitle: 'Manage blocked accounts',
                  onTap: () => _showBlockedUsersDialog(),
                ),
                const Divider(height: 1, indent: 72),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    // TODO: Open privacy policy URL or page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Privacy Policy...'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 72),
                _buildListTile(
                  icon: Icons.gavel_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () {
                    // TODO: Open terms of service URL or page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Terms of Service...'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Build Switch Tile Widget
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(
        icon,
        color: AppTheme.primaryPurple,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.darkGrey,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryPurple,
      ),
    );
  }

  // Build List Tile Widget (for navigation)
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(
        icon,
        color: AppTheme.primaryPurple,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.darkGrey,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.darkGrey,
      ),
      onTap: onTap,
    );
  }

  // Show Two-Factor Authentication Setup Dialog
  void _show2FASetupDialog() {
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your phone number to receive verification codes:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 234 567 8900',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppTheme.primaryPurple,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You\'ll receive a code via SMS for each login',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a phone number'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              _showVerificationCodeDialog(phoneController.text.trim());
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }

  // Show Verification Code Dialog
  void _showVerificationCodeDialog(String phoneNumber) {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We sent a 6-digit code to $phoneNumber',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                hintText: '------',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Resend verification code
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification code resent!'),
                    ),
                  );
                },
                child: const Text('Resend Code'),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (codeController.text.trim().length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter the 6-digit code'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }

              // TODO: Verify code with Firebase
              /*
              try {
                final verificationCode = codeController.text.trim();
                // Verify phone number with Firebase Auth
                // await FirebaseAuth.instance.verifyPhoneNumber(...)
                
                // Update 2FA status in Firestore
                await _updateSetting('twoFactorAuth', true);
              } catch (e) {
                // Handle error
              }
              */

              Navigator.pop(context);
              setState(() => _twoFactorAuth = true);
              _updateSetting('twoFactorAuth', true);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication enabled!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  // Show Disable 2FA Dialog
  void _show2FADisableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable 2FA'),
        content: const Text(
          'Are you sure you want to disable two-factor authentication?\n\nThis will make your account less secure.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorAuth = false);
              _updateSetting('twoFactorAuth', false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication disabled'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Disable',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  // Show Active Sessions Dialog
  void _showActiveSessionsDialog() {
    // Mock session data - TODO: Replace with actual Firebase data
    final sessions = [
      {
        'id': '1',
        'device': 'iPhone 13 Pro',
        'location': 'New York, NY',
        'time': 'Active now',
        'isCurrent': true,
      },
      {
        'id': '2',
        'device': 'MacBook Pro',
        'location': 'New York, NY',
        'time': '2 hours ago',
        'isCurrent': false,
      },
      {
        'id': '3',
        'device': 'iPad Air',
        'location': 'Brooklyn, NY',
        'time': '1 day ago',
        'isCurrent': false,
      },
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Active Sessions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionItem(
                device: session['device'] as String,
                location: session['location'] as String,
                time: session['time'] as String,
                isCurrent: session['isCurrent'] as bool,
                onEndSession: session['isCurrent'] as bool
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                        _endSession(session['id'] as String);
                      },
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _endAllOtherSessions();
            },
            child: const Text(
              'End All Other Sessions',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  // Build Session Item Widget
  Widget _buildSessionItem({
    required String device,
    required String location,
    required String time,
    required bool isCurrent,
    VoidCallback? onEndSession,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(
        Icons.devices,
        color: isCurrent ? AppTheme.primaryPurple : AppTheme.darkGrey,
        size: 28,
      ),
      title: Text(
        device,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        '$location\n$time',
        style: const TextStyle(fontSize: 13),
      ),
      isThreeLine: true,
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(
                Icons.close,
                color: AppTheme.errorRed,
              ),
              tooltip: 'End session',
              onPressed: onEndSession,
            ),
    );
  }

  // End Single Session
  void _endSession(String sessionId) {
    // TODO: End session in Firebase
    /*
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sessions')
            .doc(sessionId)
            .delete();
      }
    } catch (e) {
      debugPrint('Error ending session: $e');
    }
    */
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session ended successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // End All Other Sessions
  void _endAllOtherSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End All Other Sessions'),
        content: const Text(
          'This will sign you out from all other devices. Are you sure?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: End all other sessions in Firebase
              /*
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final sessionsQuery = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('sessions')
                      .where('isCurrent', isEqualTo: false)
                      .get();
                  
                  for (var doc in sessionsQuery.docs) {
                    await doc.reference.delete();
                  }
                }
              } catch (e) {
                debugPrint('Error ending sessions: $e');
              }
              */
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All other sessions ended'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'End Sessions',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  // Show Blocked Users Dialog
  void _showBlockedUsersDialog() {
    // TODO: Load blocked users from Firestore
    /*
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final blockedUsersQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('blocked')
          .get();
      
      final blockedUsers = blockedUsersQuery.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unknown',
          'blockedAt': doc.data()['blockedAt'],
        };
      }).toList();
    }
    */
    
    final List<Map<String, String>> blockedUsers = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blocked Users'),
        content: blockedUsers.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block_outlined,
                    size: 64,
                    color: AppTheme.darkGrey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t blocked any users yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: blockedUsers.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final user = blockedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                        child: Text(
                          user['name']![0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(user['name']!),
                      trailing: TextButton(
                        onPressed: () {
                          // TODO: Unblock user in Firebase
                          /*
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('blocked')
                              .doc(user['id'])
                              .delete();
                          */
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${user['name']} unblocked'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Unblock'),
                      ),
                    );
                  },
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}