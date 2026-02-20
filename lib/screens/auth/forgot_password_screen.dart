import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/header_clipper.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success =
        await auth.sendPasswordReset(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Email Sent"),
          content: const Text(
            "A password reset link has been sent to your email.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to login
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(auth.errorMessage ?? "Something went wrong"),
          backgroundColor: AppTheme.errorRed,
        ),
      );

      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: 360,
            width: double.infinity,
            child: ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xCC1E40AF),
                      Color(0x992563EB),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 120),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 30,
                        sigmaY: 30,
                      ),
                      child: Container(
                        padding:
                            const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white
                                  .withOpacity(0.30),
                              Colors.white
                                  .withOpacity(0.18),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white
                                .withOpacity(0.35),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(
                                  height: 8),
                              const Text(
                                "Enter your email to receive a reset link.",
                              ),
                              const SizedBox(
                                  height: 30),

                              TextFormField(
                                controller:
                                    _emailController,
                                validator:
                                    Validator
                                        .validateEmail,
                                decoration:
                                    InputDecoration(
                                  labelText:
                                      "Email Address",
                                  prefixIcon: const Icon(
                                    Icons
                                        .email_outlined,
                                    color: AppTheme
                                        .primaryBlue,
                                  ),
                                  filled: true,
                                  fillColor:
                                      Colors.white
                                          .withOpacity(
                                              0.65),
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                16),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  height: 30),

                              SizedBox(
                                width:
                                    double.infinity,
                                height: 56,
                                child:
                                    ElevatedButton(
                                  style: ElevatedButton
                                      .styleFrom(
                                    backgroundColor:
                                        AppTheme
                                            .primaryBlue,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  16),
                                    ),
                                  ),
                                  onPressed: auth
                                          .isLoading
                                      ? null
                                      : _handleReset,
                                  child: auth
                                          .isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors
                                              .white,
                                        )
                                      : const Text(
                                          "Send Reset Link",
                                          style:
                                              TextStyle(
                                            fontSize:
                                                16,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                            color: Colors
                                                .white,
                                          ),
                                        ),
                                ),
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
          ),
        ],
      ),
    );
  }
}