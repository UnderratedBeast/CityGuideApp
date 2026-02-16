import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/routes.dart';
import '../../utils/validators.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String _userEmail = 'alex.rivera@email.com';
  String _userPhone = '+1 234 567 8900';

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    // TODO: Load account info from Firebase
    /*
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (mounted && userData.exists) {
        setState(() {
          _userEmail = userData.data()?['email'] ?? user.email ?? '';
          _userPhone = userData.data()?['phone'] ?? '';
        });
      }
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Account Management'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Account Information Section
          Container(
            color: AppTheme.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  subtitle: _userEmail,
                  onTap: () => _showChangeEmailDialog(),
                ),
                const Divider(height: 1, indent: 72),
                _buildListTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  subtitle: _userPhone,
                  onTap: () => _showChangePhoneDialog(),
                ),
                const Divider(height: 1, indent: 72),
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.changePassword);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Account Actions Section
          Container(
            color: AppTheme.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Account Actions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.download_outlined,
                  title: 'Download My Data',
                  subtitle: 'Get a copy of your data',
                  onTap: () => _showDownloadDataDialog(),
                ),
                const Divider(height: 1, indent: 72),
                _buildListTile(
                  icon: Icons.pause_circle_outline,
                  title: 'Deactivate Account',
                  subtitle: 'Temporarily disable your account',
                  onTap: () => _showDeactivateDialog(),
                ),
                const Divider(height: 1, indent: 72),
                _buildListTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  titleColor: AppTheme.errorRed,
                  onTap: () => _showDeleteAccountDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? AppTheme.primaryPurple,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? AppTheme.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkGrey,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: titleColor ?? AppTheme.darkGrey,
      ),
      onTap: onTap,
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController(text: _userEmail);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'New Email Address',
                  hintText: 'Enter new email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validator.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Verify your password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              // TODO: Implement email change with Firebase
              /*
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Re-authenticate user
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);
                  
                  // Update email
                  await user.updateEmail(emailController.text.trim());
                  await user.sendEmailVerification();
                  
                  // Update in Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({'email': emailController.text.trim()});
                  
                  setState(() {
                    _userEmail = emailController.text.trim();
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email updated! Please verify your new email.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
              */
              
              // Temporary implementation
              setState(() {
                _userEmail = emailController.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email update coming soon!'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePhoneDialog() {
    final phoneController = TextEditingController(text: _userPhone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Phone Number'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'New Phone Number',
              hintText: 'Enter new phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: Validator.validatePhone,
          ),
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              // TODO: Implement phone change with Firebase
              /*
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({'phone': phoneController.text.trim()});
                
                setState(() {
                  _userPhone = phoneController.text.trim();
                });
              }
              */
              
              setState(() {
                _userPhone = phoneController.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number updated!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'We\'ll prepare a copy of your data and send it to your email address. This may take a few minutes.\n\nThe file will include:\n• Profile information\n• Trip history\n• Saved places\n• Reviews and ratings',
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
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Preparing your data...'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              // TODO: Implement data download
              /*
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Trigger cloud function to generate data export
                await FirebaseFunctions.instance
                    .httpsCallable('exportUserData')
                    .call({'userId': user.uid});
              }
              */

              await Future.delayed(const Duration(seconds: 2));
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You\'ll receive an email with your data shortly!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Your account will be temporarily disabled. You can reactivate it anytime by logging in again.\n\nWhile deactivated:\n• Your profile won\'t be visible\n• You won\'t receive notifications\n• Your data will be preserved',
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
            onPressed: () async {
              Navigator.pop(context);

              // TODO: Implement deactivation
              /*
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'isActive': false,
                  'deactivatedAt': FieldValue.serverTimestamp(),
                });
                
                await FirebaseAuth.instance.signOut();
                
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              }
              */

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deactivated'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text(
              'Deactivate',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure? This action cannot be undone.\n\nAll your data will be permanently deleted:\n• Profile information\n• Trip history\n• Saved places\n• Reviews and ratings',
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
              _showFinalDeleteConfirmation();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action is irreversible. Type "DELETE" to confirm:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type DELETE',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.toUpperCase() != 'DELETE') {
                    return 'Please type DELETE to confirm';
                  }
                  return null;
                },
              ),
            ],
          ),
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // TODO: Implement account deletion
              /*
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Delete user data from Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .delete();
                  
                  // Delete user authentication
                  await user.delete();
                  
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                }
              } catch (e) {
                Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
              */

              await Future.delayed(const Duration(seconds: 2));

              if (mounted) {
                Navigator.pop(context); // Close loading
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Confirm Delete',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}