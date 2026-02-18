// lib/screens/profile/change_password_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/validators.dart';

class _C {
  static const bg      = Color(0xFFEFF6FF);
  static const navy    = Color(0xFF0C2340);
  static const blue    = Color(0xFF1D6EF5);
  static const blueAlt = Color(0xFF3B82F6);
  static const white   = Color(0xFFFFFFFF);
  static const glass   = Color(0xE6FFFFFF);
  static const textMid = Color(0xFF4A6580);
  static const error   = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _currCtrl = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _confCtrl = TextEditingController();

  bool _showCurr = false;
  bool _showNew  = false;
  bool _showConf = false;
  bool _saving   = false;

  // Password strength
  double _strength = 0;
  String _strengthLabel = '';
  Color  _strengthColor = _C.error;

  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
        ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(_evalStrength);
  }

  @override
  void dispose() {
    _ac.dispose();
    _currCtrl.dispose();
    _newCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  void _evalStrength() {
    final p = _newCtrl.text;
    double s = 0;
    if (p.length >= 8) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s += 0.25;

    String label;
    Color  color;
    if (s <= 0.25) { label = 'Weak';   color = _C.error; }
    else if (s <= 0.5)  { label = 'Fair';   color = const Color(0xFFF97316); }
    else if (s <= 0.75) { label = 'Good';   color = const Color(0xFFEAB308); }
    else                { label = 'Strong'; color = _C.success; }

    setState(() {
      _strength      = s;
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final user  = FirebaseAuth.instance.currentUser!;
      final cred  = EmailAuthProvider.credential(
          email: user.email!, password: _currCtrl.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);

      _showSnack('Password changed successfully!', success: true);
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'wrong-password'
          ? 'Current password is incorrect'
          : e.code == 'weak-password'
              ? 'New password is too weak'
              : e.message ?? 'Something went wrong';
      _showSnack(msg, success: false);
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
              style: const TextStyle(
                  color: _C.white, fontWeight: FontWeight.w600))),
        ]),
        backgroundColor: success ? _C.success : _C.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _C.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Change Password',
              style: TextStyle(
                  color: _C.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fade,
          child: Stack(children: [
            // Gradient band
            Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_C.navy, Color(0xFF1A56CF), _C.blueAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(top: -50, right: -50,
                child: _blob(200, _C.white.withOpacity(0.04))),
            Positioned(top: 70, left: -40,
                child: _blob(120, _C.white.withOpacity(0.04))),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  const SizedBox(height: 32),

                  // Lock icon hero
                  Center(
                    child: Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _C.white.withOpacity(0.15),
                        border: Border.all(
                            color: _C.white.withOpacity(0.32), width: 1.5),
                      ),
                      child: const Icon(Icons.lock_reset_rounded,
                          color: _C.white, size: 34),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Update Password',
                      style: TextStyle(
                          color: _C.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Keep your account secure',
                      style: TextStyle(
                          color: _C.white.withOpacity(0.68), fontSize: 14)),

                  const SizedBox(height: 38),

                  // Glass form
                  _glassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _sectionLabel('Current'),
                        const SizedBox(height: 14),
                        _pwdField(
                          ctrl: _currCtrl,
                          label: 'Current Password',
                          icon: Icons.lock_outline_rounded,
                          show: _showCurr,
                          onToggle: () =>
                              setState(() => _showCurr = !_showCurr),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 26),
                        _sectionLabel('New Password'),
                        const SizedBox(height: 14),
                        _pwdField(
                          ctrl: _newCtrl,
                          label: 'New Password',
                          icon: Icons.lock_open_outlined,
                          show: _showNew,
                          onToggle: () =>
                              setState(() => _showNew = !_showNew),
                          validator: Validator.validatePassword,
                        ),

                        // Strength indicator
                        if (_newCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _strength,
                                    minHeight: 5,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation(
                                        _strengthColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(_strengthLabel,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _strengthColor)),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),
                        _pwdField(
                          ctrl: _confCtrl,
                          label: 'Confirm New Password',
                          icon: Icons.check_circle_outline_rounded,
                          show: _showConf,
                          onToggle: () =>
                              setState(() => _showConf = !_showConf),
                          validator: (v) => Validator
                              .validateConfirmPassword(v, _newCtrl.text),
                          action: TextInputAction.done,
                        ),

                        const SizedBox(height: 22),

                        // Hint box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _C.blue.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Icon(Icons.info_outline_rounded,
                                color: _C.blue, size: 17),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Strong passwords include uppercase, numbers and symbols.',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: _C.navy.withOpacity(0.65),
                                    height: 1.4),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Update button
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.blue,
                        foregroundColor: _C.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: _C.white, strokeWidth: 2.5))
                          : const Text('Update Password',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t.toUpperCase(),
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _C.navy.withOpacity(0.42),
          letterSpacing: 1.3));

  Widget _glassCard({required Widget child}) => ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _C.glass,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                  color: _C.blue.withOpacity(0.14), width: 1.4),
              boxShadow: [
                BoxShadow(
                    color: _C.blue.withOpacity(0.07),
                    blurRadius: 26,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: child,
          ),
        ),
      );

  Widget _pwdField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    TextInputAction action = TextInputAction.next,
  }) =>
      TextFormField(
        controller: ctrl,
        obscureText: !show,
        textInputAction: action,
        validator: validator,
        style: const TextStyle(
            color: _C.navy, fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: _C.navy.withOpacity(0.52), fontSize: 14),
          prefixIcon: Icon(icon, color: _C.blue, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              show ? Icons.visibility_off_outlined
                   : Icons.visibility_outlined,
              color: _C.navy.withOpacity(0.38), size: 20,
            ),
            onPressed: onToggle,
          ),
          filled: true,
          fillColor: _C.blue.withOpacity(0.05),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: _C.blue.withOpacity(0.14))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _C.blue, width: 1.8)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _C.error)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _C.error, width: 1.8)),
        ),
      );

  Widget _blob(double s, Color c) => Container(
      width: s, height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}