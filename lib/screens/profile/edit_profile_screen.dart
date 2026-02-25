// lib/screens/profile/edit_profile_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // ─────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────
  // LOAD PROFILE
  // ─────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────
  // PICK IMAGE
  // ─────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────
  // COMPRESS IMAGE
  // ─────────────────────────────────────────────────────────────
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

  // UPLOAD TO CLOUDINARY
 
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

  // ─────────────────────────────────────────────────────────────
  // SAVE PROFILE
  // ─────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveProfile,
            child: Text(
              "Save",
              style: TextStyle(
                color: _saving ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ───── HEADER ─────
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0C3FB8), Color(0xFF2F80ED)],
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
                        CircleAvatar(
  radius: 55,
  backgroundColor: Colors.white,
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
          color: Color(0xFF0C2340),
        )
      : null,
),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Color(0xFF2F80ED),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap to change photo",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // ───── FORM CARD ─────
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
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
        fontWeight: FontWeight.w700,
        color: Color(0xFF0C2340),
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
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF5F8FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
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
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}