// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../../utils/theme.dart';
// import '../../utils/validators.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _bioController = TextEditingController();

//   File? _profileImage;
//   String? _currentImageUrl;
//   bool _isLoading = false;
//   bool _hasChanges = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
    
//     // Add listeners to detect changes
//     _fullNameController.addListener(_onFieldChanged);
//     _emailController.addListener(_onFieldChanged);
//     _phoneController.addListener(_onFieldChanged);
//     _locationController.addListener(_onFieldChanged);
//     _bioController.addListener(_onFieldChanged);
//   }

//   void _onFieldChanged() {
//     if (!_hasChanges) {
//       setState(() => _hasChanges = true);
//     }
//   }

//   Future<void> _loadUserData() async {
//     // TODO: Load user data from Firebase
//     /*
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userData = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
      
//       if (mounted && userData.exists) {
//         final data = userData.data()!;
//         setState(() {
//           _fullNameController.text = data['fullName'] ?? '';
//           _emailController.text = data['email'] ?? user.email ?? '';
//           _phoneController.text = data['phone'] ?? '';
//           _locationController.text = data['location'] ?? '';
//           _bioController.text = data['bio'] ?? '';
//           _currentImageUrl = data['profileImage'];
//         });
//       }
//     }
//     */
    
//     // Temporary mock data (remove when Firebase is integrated)
//     setState(() {
//       _fullNameController.text = 'Alex Rivera';
//       _emailController.text = 'alex.rivera@email.com';
//       _phoneController.text = '+1 234 567 8900';
//       _locationController.text = 'New York, NY';
//       _bioController.text = 'Travel enthusiast exploring the world one city at a time.';
//     });
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _locationController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(
//         source: source,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _profileImage = File(pickedFile.path);
//           _hasChanges = true;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error picking image: ${e.toString()}'),
//             backgroundColor: AppTheme.errorRed,
//           ),
//         );
//       }
//     }
//   }

//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Choose Photo Source',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt, color: AppTheme.primaryPurple),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library, color: AppTheme.primaryPurple),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//               if (_profileImage != null || _currentImageUrl != null)
//                 ListTile(
//                   leading: const Icon(Icons.delete, color: AppTheme.errorRed),
//                   title: const Text('Remove Photo'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     setState(() {
//                       _profileImage = null;
//                       _currentImageUrl = null;
//                       _hasChanges = true;
//                     });
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<String?> _uploadProfileImage() async {
//     if (_profileImage == null) return _currentImageUrl;

//     // TODO: Upload to Firebase Storage
//     /*
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return null;

//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_images')
//           .child('${user.uid}.jpg');

//       await storageRef.putFile(_profileImage!);
//       final downloadUrl = await storageRef.getDownloadURL();
      
//       return downloadUrl;
//     } catch (e) {
//       debugPrint('Error uploading image: $e');
//       return null;
//     }
//     */
    
//     // Temporary - return empty string
//     return '';
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (!_hasChanges) {
//       Navigator.pop(context);
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Upload profile image if changed
//       String? imageUrl;
//       if (_profileImage != null) {
//         imageUrl = await _uploadProfileImage();
//       } else {
//         imageUrl = _currentImageUrl;
//       }

//       // TODO: Update user profile in Firestore
//       /*
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .update({
//           'fullName': _fullNameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'location': _locationController.text.trim(),
//           'bio': _bioController.text.trim(),
//           'profileImage': imageUrl,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });

//         // Update email in Firebase Auth if changed
//         if (_emailController.text.trim() != user.email) {
//           await user.updateEmail(_emailController.text.trim());
//         }
//       }
//       */

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile updated successfully!'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
        
//         // Wait a bit for the snackbar to show
//         await Future.delayed(const Duration(milliseconds: 500));
        
//         if (mounted) {
//           Navigator.pop(context, true); // Return true to indicate successful update
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update profile: ${e.toString()}'),
//             backgroundColor: AppTheme.errorRed,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (!_hasChanges) return true;

//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Discard Changes?'),
//         content: const Text('You have unsaved changes. Do you want to discard them?'),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text(
//               'Discard',
//               style: TextStyle(color: AppTheme.errorRed),
//             ),
//           ),
//         ],
//       ),
//     );

//     return result ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: AppTheme.white,
//         appBar: AppBar(
//           title: const Text('Edit Profile'),
//           backgroundColor: AppTheme.white,
//           foregroundColor: AppTheme.black,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () async {
//               if (await _onWillPop()) {
//                 if (mounted) Navigator.pop(context);
//               }
//             },
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: TextButton(
//                 onPressed: _isLoading ? null : _saveProfile,
//                 child: _isLoading
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             AppTheme.primaryPurple,
//                           ),
//                         ),
//                       )
//                     : Text(
//                         'Save',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: _hasChanges
//                               ? AppTheme.primaryPurple
//                               : AppTheme.darkGrey,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 // Profile Picture Section
//                 GestureDetector(
//                   onTap: _showImageSourceDialog,
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: AppTheme.lightGrey,
//                           border: Border.all(
//                             color: AppTheme.white,
//                             width: 4,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: ClipOval(
//                           child: _buildProfileImage(),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             color: AppTheme.primaryPurple,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: AppTheme.white,
//                               width: 3,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.camera_alt,
//                             size: 18,
//                             color: AppTheme.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   'Tap to change photo',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppTheme.primaryBlue,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Full Name
//                 TextFormField(
//                   controller: _fullNameController,
//                   textCapitalization: TextCapitalization.words,
//                   decoration: const InputDecoration(
//                     labelText: 'Full Name',
//                     hintText: 'Enter your full name',
//                     prefixIcon: Icon(Icons.person_outline),
//                   ),
//                   validator: Validator.validateName,
//                   enabled: !_isLoading,
//                 ),

//                 const SizedBox(height: 20),

//                 // Email
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     hintText: 'Enter your email',
//                     prefixIcon: Icon(Icons.email_outlined),
//                   ),
//                   validator: Validator.validateEmail,
//                   enabled: !_isLoading,
//                 ),

//                 const SizedBox(height: 20),

//                 // Phone Number
//                 TextFormField(
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                   decoration: const InputDecoration(
//                     labelText: 'Phone Number',
//                     hintText: 'Enter your phone number',
//                     prefixIcon: Icon(Icons.phone_outlined),
//                   ),
//                   validator: Validator.validatePhone,
//                   enabled: !_isLoading,
//                 ),

//                 const SizedBox(height: 20),

//                 // Location
//                 TextFormField(
//                   controller: _locationController,
//                   decoration: const InputDecoration(
//                     labelText: 'Location',
//                     hintText: 'City, State/Country',
//                     prefixIcon: Icon(Icons.location_on_outlined),
//                   ),
//                   enabled: !_isLoading,
//                 ),

//                 const SizedBox(height: 20),

//                 // Bio
//                 TextFormField(
//                   controller: _bioController,
//                   maxLines: 4,
//                   maxLength: 200,
//                   decoration: const InputDecoration(
//                     labelText: 'Bio',
//                     hintText: 'Tell us about yourself...',
//                     prefixIcon: Padding(
//                       padding: EdgeInsets.only(bottom: 60),
//                       child: Icon(Icons.description_outlined),
//                     ),
//                     alignLabelWithHint: true,
//                   ),
//                   enabled: !_isLoading,
//                 ),

//                 const SizedBox(height: 40),

//                 // Save Button (bottom)
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isLoading || !_hasChanges ? null : _saveProfile,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryPurple,
//                       foregroundColor: AppTheme.white,
//                       disabledBackgroundColor: AppTheme.lightGrey,
//                       disabledForegroundColor: AppTheme.darkGrey,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2.5,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 AppTheme.white,
//                               ),
//                             ),
//                           )
//                         : const Text(
//                             'Save Changes',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileImage() {
//     if (_profileImage != null) {
//       return Image.file(
//         _profileImage!,
//         fit: BoxFit.cover,
//       );
//     } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
//       return Image.network(
//         _currentImageUrl!,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return _buildPlaceholderIcon();
//         },
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                   : null,
//               valueColor: const AlwaysStoppedAnimation<Color>(
//                 AppTheme.primaryPurple,
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       return _buildPlaceholderIcon();
//     }
//   }

//   Widget _buildPlaceholderIcon() {
//     return Icon(
//       Icons.person,
//       size: 60,
//       color: AppTheme.darkGrey,
//     );
//   }
// }


// ##################################### 
// lib/screens/profile/edit_profile_screen.dart

// lib/screens/profile/edit_profile_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/validators.dart';

class _C {
  static const bg      = Color(0xFFEFF6FF);
  static const navy    = Color(0xFF0C2340);
  static const blue    = Color(0xFF1D6EF5);
  static const blueAlt = Color(0xFF3B82F6);
  static const lightB  = Color(0xFF93C5FD);
  static const white   = Color(0xFFFFFFFF);
  static const glass   = Color(0xE6FFFFFF);
  static const textMid = Color(0xFF4A6580);
  static const error   = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _nameFocus    = FocusNode();
  final _phoneFocus   = FocusNode();
  final _locFocus     = FocusNode();
  final _bioFocus     = FocusNode();

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locCtrl   = TextEditingController();
  final _bioCtrl   = TextEditingController();

  String? _photoUrl;
  File?   _pickedFile;
  bool    _loading  = true;
  bool    _saving   = false;
  bool    _dirty    = false;

  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
        ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    for (final c in [_nameCtrl, _phoneCtrl, _locCtrl, _bioCtrl]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() { if (!_dirty) setState(() => _dirty = true); }

  @override
  void dispose() {
    _ac.dispose();
    for (final c in [_nameCtrl, _phoneCtrl, _locCtrl, _bioCtrl]) {
      c.removeListener(_markDirty);
      c.dispose();
    }
    for (final f in [_nameFocus, _phoneFocus, _locFocus, _bioFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Firebase ──────────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      final d = doc.data() ?? {};
      if (!mounted) return;
      setState(() {
        _nameCtrl.text  = d['fullName']?.toString() ?? '';
        _phoneCtrl.text = d['phone']?.toString() ?? '';
        _locCtrl.text   = d['location']?.toString() ?? '';
        _bioCtrl.text   = d['bio']?.toString() ?? '';
        _photoUrl       = d['profileImage']?.toString();
        _loading        = false;
        _dirty          = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showSnack('Failed to load profile', success: false);
      }
    }
  }

  Future<String?> _uploadPhoto() async {
    if (_pickedFile == null) return _photoUrl;
    final ref = FirebaseStorage.instance.ref('profile_images/$_uid.jpg');
    final uploadTask = ref.putFile(_pickedFile!, SettableMetadata(contentType: 'image/jpeg'));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final url = await _uploadPhoto();
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'fullName'    : _nameCtrl.text.trim(),
        'phone'       : _phoneCtrl.text.trim(),
        'location'    : _locCtrl.text.trim(),
        'bio'         : _bioCtrl.text.trim(),
        'profileImage': url ?? '',
        'updatedAt'   : FieldValue.serverTimestamp(),
      });
      _showSnack('Profile saved!', success: true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      _showSnack(e.message ?? 'Save failed', success: false);
    } catch (e) {
      _showSnack(e.toString(), success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            success ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
            color: _C.white, size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(msg,
              style: const TextStyle(color: _C.white,
                  fontWeight: FontWeight.w600))),
        ]),
        backgroundColor: success ? _C.success : _C.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_dirty) return true;
    final leave = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _discardChangesSheet(),
    );
    return leave ?? false;
  }

  Widget _discardChangesSheet() => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                color: _C.error.withOpacity(0.09),
                shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded,
                color: _C.error, size: 26),
          ),
          const SizedBox(height: 16),
          const Text('Discard Changes?',
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _C.navy)),
          const SizedBox(height: 8),
          Text('Your edits will be lost.',
              style: TextStyle(color: _C.textMid, fontSize: 14)),
          const SizedBox(height: 26),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _C.navy.withOpacity(0.18)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Stay',
                    style: TextStyle(
                        color: _C.navy, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.error,
                  foregroundColor: _C.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Discard',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      );

  // ── Image picker ──────────────────────────────────────────────────────────
  void _showPhotoPicker() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Container(
                width: 42, height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Change Photo',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _C.navy)),
            ),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _photoSourceBtn(Icons.camera_alt_outlined, 'Camera', ImageSource.camera),
              _photoSourceBtn(Icons.photo_library_outlined, 'Gallery', ImageSource.gallery),
            ]),
            if (_pickedFile != null || (_photoUrl?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _pickedFile = null;
                    _photoUrl   = null;
                    _dirty      = true;
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, color: _C.error),
                label: const Text('Remove Photo',
                    style: TextStyle(
                        color: _C.error, fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 8),
          ]),
        ),
      );

  Widget _photoSourceBtn(IconData icon, String label, ImageSource src) =>
      GestureDetector(
        onTap: () async {
          Navigator.pop(context);
          try {
            final file = await ImagePicker().pickImage(
                source: src, maxWidth: 900, imageQuality: 82);
            if (file != null) {
              setState(() {
                _pickedFile = File(file.path);
                _dirty = true;
              });
            }
          } catch (e) {
            _showSnack('Failed to pick image', success: false);
          }
        },
        child: Column(children: [
          Container(
            width: 66, height: 66,
            decoration: BoxDecoration(
                color: _C.blue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: _C.blue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: _C.navy,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5)),
        ]),
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: _C.bg,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: _C.white),
              onPressed: () async {
                if (await _onWillPop()) Navigator.pop(context);
              },
            ),
            title: const Text('Edit Profile',
                style: TextStyle(
                    color: _C.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _saving
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: _C.white, strokeWidth: 2.2)))
                    : TextButton(
                        onPressed: _dirty ? _saveProfile : null,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: _dirty
                                ? _C.white
                                : _C.white.withOpacity(0.38),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(_C.blue)))
              : FadeTransition(
                  opacity: _fade,
                  child: Stack(children: [
                    Container(
                      height: 270,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_C.navy, Color(0xFF1A56CF), _C.blueAlt],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(top: -40, right: -40,
                        child: _blob(180, _C.white.withOpacity(0.05))),
                    Positioned(top: 70, left: -30,
                        child: _blob(110, _C.white.withOpacity(0.05))),
                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(children: [
                          const SizedBox(height: 72),
                          GestureDetector(
                            onTap: _showPhotoPicker,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 112, height: 112,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _C.white, width: 3.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: _C.navy.withOpacity(0.4),
                                          blurRadius: 22,
                                          offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _pickedFile != null
                                        ? Image.file(_pickedFile!, fit: BoxFit.cover)
                                        : (_photoUrl?.isNotEmpty ?? false)
                                            ? Image.network(_photoUrl!,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (_, child, loadingProgress) =>
                                                  loadingProgress == null
                                                      ? child
                                                      : Container(
                                                          color: _C.navy,
                                                          child: const Center(
                                                            child:
                                                              CircularProgressIndicator(
                                                                color: _C.white,
                                                                strokeWidth: 2,
                                                              ),
                                                          ),
                                                        ),
                                                errorBuilder: (_, __, ___) => _initialsBox())
                                            : _initialsBox(),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4, right: 4,
                                  child: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: _C.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _C.white, width: 2.5),
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 15, color: _C.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Tap to change photo',
                              style: TextStyle(color: _C.white.withOpacity(0.78), fontSize: 13)),
                          const SizedBox(height: 36),
                          _glassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                _sectionLabel('Personal Info'),
                                const SizedBox(height: 16),
                                _field(controller: _nameCtrl, focus: _nameFocus, nextFocus: _phoneFocus,
                                    label: 'Full Name', icon: Icons.person_outline_rounded,
                                    validator: Validator.validateName),
                                const SizedBox(height: 14),
                                _field(controller: _phoneCtrl, focus: _phoneFocus, nextFocus: _locFocus,
                                    label: 'Phone Number', icon: Icons.phone_outlined,
                                    type: TextInputType.phone, validator: Validator.validatePhone),
                                const SizedBox(height: 14),
                                _field(controller: _locCtrl, focus: _locFocus, nextFocus: _bioFocus,
                                    label: 'Location', icon: Icons.location_on_outlined),
                                const SizedBox(height: 24),
                                _sectionLabel('About You'),
                                const SizedBox(height: 16),
                                _field(controller: _bioCtrl, focus: _bioFocus,
                                    label: 'Bio', icon: Icons.auto_stories_outlined,
                                    maxLines: 4, maxLen: 200,
                                    hint: 'What\'s your travel story?',
                                    textAction: TextInputAction.newline),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity, height: 56,
                            child: ElevatedButton(
                              onPressed: _saving || !_dirty ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.blue,
                                foregroundColor: _C.white,
                                disabledBackgroundColor: _C.blue.withOpacity(0.32),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _saving
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(color: _C.white, strokeWidth: 2.5))
                                  : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 36),
                        ]),
                      ),
                    ),
                  ]),
                ),
        ),
      ),
    );
  }

  Widget _initialsBox() => Container(
      color: _C.navy,
      child: const Center(child: Icon(Icons.person_outline_rounded, color: _C.white, size: 44)));

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 2),
        ),
      );

  Widget _glassCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _C.glass,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: _C.navy.withOpacity(0.06), blurRadius: 20)],
        ),
        child: child,
      );

  Widget _sectionLabel(String title) => Text(title,
      style: const TextStyle(
          color: _C.navy, fontSize: 16, fontWeight: FontWeight.w700));

  Widget _field({
    required TextEditingController controller,
    required FocusNode focus,
    FocusNode? nextFocus,
    required String label,
    IconData? icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLen,
    String? hint,
    TextInputAction textAction = TextInputAction.next,
  }) =>
      TextFormField(
        controller: controller,
        focusNode: focus,
        textInputAction: nextFocus != null ? textAction : TextInputAction.done,
        keyboardType: type,
        validator: validator,
        maxLines: maxLines,
        maxLength: maxLen,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: _C.textMid) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          contentPadding: maxLines > 1
              ? const EdgeInsets.fromLTRB(12, 16, 12, 16)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
        onFieldSubmitted: (_) => nextFocus?.requestFocus(),
      );
}
