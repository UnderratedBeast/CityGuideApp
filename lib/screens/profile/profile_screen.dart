import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/routes.dart';
import '../settings/account_management_screen.dart';
import '../settings/privacy_security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;

  // Mock user data - Replace with actual Firebase data
  // final String userName = "Alex Rivera";
  //final String userLocation = "New York, NY";
  final String userName = {'fullName': "Alex Rivera"}['fullName'] ?? "Alex Rivera"; // Placeholder until Firebase is integrated
  final String userLocation = {'location': "New York, NY"}['location'] ?? "New York, NY"; // Placeholder until Firebase is integrated
  final String userImageUrl = ""; // Will be loaded from Firebase Storage

  // Mock trips data - Replace with Firestore data
  final List<Map<String, dynamic>> myTrips = [
    {
      'id': '1',
      'title': 'Summer in Abuja',
      'date': 'July 2024',
      'nights': '12 Nights',
      'image': '', // Placeholder - add actual image URL
      'isFavorite': true,
    },
    {
      'id': '2',
      'title': 'Lagos Weekend',
      'date': 'May 2024',
      'nights': '3 Nights',
      'image': '', // Placeholder - add actual image URL
      'isFavorite': false,
    },
  ];
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPreferences();
  }

  Future<void> _loadUserData() async {
    // TODO: Load user data from Firebase
    /*
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (mounted && userData.exists) {
        setState(() {
          userName = userData.data()?['fullName'] ?? '';
          userLocation = userData.data()?['location'] ?? '';
          userImageUrl = userData.data()?['profileImage'] ?? '';
        });
      }
    }
    */
  }

  Future<void> _loadPreferences() async {
    // TODO: Load preferences from SharedPreferences or Firestore
    /*
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailUpdates = prefs.getBool('email_updates') ?? false;
    });
    */
  }

  Future<void> _updateNotificationPreference(bool value) async {
    setState(() => _pushNotifications = value);
    
    // TODO: Save to SharedPreferences and Firestore
    /*
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'pushNotifications': value});
    }
    */
  }

  Future<void> _updateEmailPreference(bool value) async {
    setState(() => _emailUpdates = value);
    
    // TODO: Save to SharedPreferences and Firestore
    /*
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_updates', value);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'emailUpdates': value});
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text(
          'User Profile & My Trips',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              color: AppTheme.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  // Profile Image with Edit Badge
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightGrey,
                          border: Border.all(
                            color: AppTheme.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: userImageUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppTheme.darkGrey,
                                )
                              : Image.network(
                                  userImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppTheme.darkGrey,
                                    );
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.editProfile);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Name
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userLocation,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.editProfile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // My Trips Section
            Container(
              width: double.infinity,
              color: AppTheme.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Trips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all trips screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('View all trips coming soon!')),
                          );
                        },
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Trips List
                  myTrips.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.card_travel_outlined,
                                  size: 64,
                                  color: AppTheme.darkGrey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No trips yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start exploring and save your favorite places!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.darkGrey.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: myTrips.length,
                            itemBuilder: (context, index) {
                              final trip = myTrips[index];
                              return _buildTripCard(trip);
                            },
                          ),
                        ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Settings Section
            Container(
              width: double.infinity,
              color: AppTheme.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Push Notifications
                  _buildSettingTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppTheme.primaryPurple,
                    title: 'Push Notifications',
                    trailing: Switch(
                      value: _pushNotifications,
                      onChanged: _updateNotificationPreference,
                      activeColor: AppTheme.primaryPurple,
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Email Updates
                  _buildSettingTile(
                    icon: Icons.email_outlined,
                    iconColor: AppTheme.primaryPurple,
                    title: 'Email Updates',
                    trailing: Switch(
                      value: _emailUpdates,
                      onChanged: _updateEmailPreference,
                      activeColor: AppTheme.primaryPurple,
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Account Management
                  _buildSettingTile(
                    icon: Icons.person_outline,
                    iconColor: AppTheme.darkGrey,
                    title: 'Account Management',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.darkGrey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountManagementScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  // Privacy & Security
                  _buildSettingTile(
                    icon: Icons.security_outlined,
                    iconColor: AppTheme.darkGrey,
                    title: 'Privacy & Security',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.darkGrey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacySecurityScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  const SizedBox(height: 8),
                  
                  // Sign Out
                  _buildSettingTile(
                    icon: Icons.logout,
                    iconColor: AppTheme.errorRed,
                    title: 'Sign Out',
                    titleColor: AppTheme.errorRed,
                    onTap: _showSignOutDialog,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to trip details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening ${trip['title']}')),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Image
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryPurple.withOpacity(0.3),
                        AppTheme.primaryBlue.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: trip['image'] != null && trip['image'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            trip['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          ),
                        )
                      : _buildPlaceholderImage(),
                ),
                
                // Trip Details
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trip['date']} • ${trip['nights']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Favorite Icon
            if (trip['isFavorite'] == true)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 18,
                    color: AppTheme.errorRed,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: AppTheme.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? AppTheme.black,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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
              
              // TODO: Implement Firebase sign out
              /*
              try {
                await FirebaseAuth.instance.signOut();
                
                // Clear local data
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: ${e.toString()}'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
              */
              
              // Temporary sign out (remove when Firebase is integrated)
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}