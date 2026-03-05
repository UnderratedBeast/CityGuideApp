// lib/screens/profile/edit_profile_screen.dart

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/theme.dart';
import '../../utils/routes.dart';
import '../../widgets/floating_bottom_nav_bar.dart';
import '../CityguideHome/CityListScreen.dart';
import '../favorites/FavoritesScreen.dart';
import '../map/AllPlacesMapScreen.dart';

// ── Design Tokens (matching profile screen) ──────────────────────────────────
class _C {
  static const bg       = Color(0xFFEFF6FF);
  static const navy     = Color(0xFF0C2340);
  static const blue     = AppTheme.primaryBlue;
  static const blueAlt  = Color(0xFF3B82F6);
  static const lightB   = Color(0xFF93C5FD);
  static const white    = Color(0xFFFFFFFF);
  static const glass    = Color(0xE6FFFFFF);
  static const textMid  = Color(0xFF4A6580);
  static const error    = Color(0xFFDC2626);
}

// ── Shared Glass Card (reused from profile) ───────────────────────────────────
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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  final _picker = ImagePicker();

  File? _pickedFile;
  String? _photoUrl;
  bool _saving = false;

  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  // For bottom nav
  int _selectedNavIndex = 3; // Profile tab

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(_uid).get();

    final data = doc.data();
    if (data == null) return;

    setState(() {
      _nameCtrl.text = data["fullName"] ?? "";
      _phoneCtrl.text = data["phone"] ?? "";
      _locCtrl.text = data["location"] ?? "";
      _bioCtrl.text = data["bio"] ?? "";
      _photoUrl = data["profileImage"];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);

    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 90,
    );

    if (file != null) {
      setState(() {
        _pickedFile = File(file.path);
      });
    }
  }

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 75,
      minWidth: 600,
      minHeight: 600,
    );

    return result == null ? null : File(result.path);
  }

  Future<String?> _uploadToCloudinary() async {
    if (_pickedFile == null) return _photoUrl;

    const cloudName = "dgideyulk";
    const uploadPreset = "CityGuideApp";

    final compressed = await _compressImage(_pickedFile!);
    if (compressed == null) return null;

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = uploadPreset
      ..fields["folder"] = "cityguide/profile"
      ..files.add(
        await http.MultipartFile.fromPath("file", compressed.path),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(responseBody);
      return data["secure_url"];
    }

    debugPrint("Cloudinary error: $responseBody");
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final imageUrl = await _uploadToCloudinary();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(_uid)
          .set({
        "fullName": _nameCtrl.text.trim(),
        "phone": _phoneCtrl.text.trim(),
        "location": _locCtrl.text.trim(),
        "bio": _bioCtrl.text.trim(),
        "profileImage": imageUrl ?? _photoUrl ?? "",
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Save error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg, // ← Changed from solid blue to light sky
      extendBody: true,
appBar: AppBar(
  elevation: 0,
  systemOverlayStyle: SystemUiOverlayStyle.light,
  backgroundColor: Colors.transparent,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_C.navy, Color(0xFF1A56CF), _C.blueAlt],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  leading: IconButton(
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      color: _C.white,
      size: 20,
    ),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text(
    "Edit Profile",
    style: TextStyle(
      color: _C.white,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
  centerTitle: true,
  actions: [
    TextButton(
      onPressed: _saving ? null : _saveProfile,
      child: Text(
        "Save",
        style: TextStyle(
          color: _saving ? Colors.white54 : _C.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // space for bottom nav
        child: Column(
          children: [
            // ───── HEADER (gradient with avatar) ─────
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_C.navy, Color(0xFF1A56CF), _C.blueAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showPicker,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
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
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: _C.white,
                            backgroundImage: _pickedFile != null
                                ? FileImage(_pickedFile!) as ImageProvider
                                : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                    ? NetworkImage(_photoUrl!) as ImageProvider
                                    : null,
                            child: (_pickedFile == null &&
                                    (_photoUrl == null || _photoUrl!.isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: _C.navy,
                                  )
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: _C.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: _C.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap to change photo",
                    style: TextStyle(color: _C.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ───── FORM CARD (glass) ─────
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProfileGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("Personal Info"),
                        const SizedBox(height: 16),
                        _infoField(
                          icon: Icons.person_outline,
                          label: "Full Name",
                          controller: _nameCtrl,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Required" : null,
                        ),
                        _infoField(
                          icon: Icons.phone_outlined,
                          label: "Phone Number",
                          controller: _phoneCtrl,
                        ),
                        _infoField(
                          icon: Icons.location_on_outlined,
                          label: "Location",
                          controller: _locCtrl,
                        ),
                        const SizedBox(height: 24),
                        _sectionTitle("About You"),
                        const SizedBox(height: 16),
                        _infoField(
                          icon: Icons.info_outline,
                          label: "Bio",
                          controller: _bioCtrl,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _C.navy,
      ),
    );
  }

  Widget _infoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _C.blue),
          filled: true,
          fillColor: _C.blue.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: _C.textMid),
        ),
      ),
    );
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _C.blue),
              title: const Text("Camera"),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: _C.blue),
              title: const Text("Gallery"),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}