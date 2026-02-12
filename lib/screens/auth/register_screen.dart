// // lib/screens/auth/register_screen.dart

// import 'package:flutter/material.dart';
// import '../../utils/routes.dart';
// import '../../utils/theme.dart';
// import '../../utils/validators.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
  
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _acceptTerms = false;

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleRegister() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (!_acceptTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please accept the Terms and Conditions'),
//           backgroundColor: AppTheme.errorRed,
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // TODO: Implement Firebase authentication
//       // await AuthService().signUp(
//       //   email: _emailController.text.trim(),
//       //   password: _passwordController.text,
//       //   fullName: _fullNameController.text.trim(),
//       // );

//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));

//       if (mounted) {
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Account created successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Navigate to home
//         Navigator.of(context).pushReplacementNamed(AppRoutes.home);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Registration failed: ${e.toString()}'),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppTheme.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Logo
//                 Center(
//                   child: Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           AppTheme.primaryPurple,
//                           AppTheme.primaryBlue,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppTheme.primaryPurple.withOpacity(0.3),
//                           blurRadius: 15,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.location_city,
//                       size: 35,
//                       color: AppTheme.white,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),
                
//                 // Title
//                 const Text(
//                   'Create Account',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.black,
//                   ),
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 const Text(
//                   'Sign up to get started',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: AppTheme.darkGrey,
//                   ),
//                 ),
                
//                 const SizedBox(height: 32),

//                 // Full Name Field
//                 TextFormField(
//                   controller: _fullNameController,
//                   textCapitalization: TextCapitalization.words,
//                   textInputAction: TextInputAction.next,
//                   decoration: InputDecoration(
//                     labelText: 'Full Name',
//                     hintText: 'Enter your full name',
//                     prefixIcon: Icon(
//                       Icons.person_outline,
//                       color: AppTheme.primaryPurple,
//                     ),
//                   ),
//                   validator: Validator.validateName,
//                 ),
                
//                 const SizedBox(height: 20),

//                 // Email Field
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     hintText: 'Enter your email',
//                     prefixIcon: Icon(
//                       Icons.email_outlined,
//                       color: AppTheme.primaryPurple,
//                     ),
//                   ),
//                   validator: Validator.validateEmail,
//                 ),
                
//                 const SizedBox(height: 20),

//                 // Password Field
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   textInputAction: TextInputAction.next,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: 'Create a password',
//                     prefixIcon: Icon(
//                       Icons.lock_outline,
//                       color: AppTheme.primaryPurple,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                         color: AppTheme.darkGrey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: Validator.validatePassword,
//                 ),
                
//                 const SizedBox(height: 20),

//                 // Confirm Password Field
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   obscureText: _obscureConfirmPassword,
//                   textInputAction: TextInputAction.done,
//                   onFieldSubmitted: (_) => _handleRegister(),
//                   decoration: InputDecoration(
//                     labelText: 'Confirm Password',
//                     hintText: 'Re-enter your password',
//                     prefixIcon: Icon(
//                       Icons.lock_outline,
//                       color: AppTheme.primaryPurple,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirmPassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                         color: AppTheme.darkGrey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) => Validator.validateConfirmPassword(
//                     value,
//                     _passwordController.text,
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),

//                 // Terms and Conditions Checkbox
//                 Row(
//                   children: [
//                     SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: Checkbox(
//                         value: _acceptTerms,
//                         onChanged: (value) {
//                           setState(() {
//                             _acceptTerms = value ?? false;
//                           });
//                         },
//                         activeColor: AppTheme.primaryPurple,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _acceptTerms = !_acceptTerms;
//                           });
//                         },
//                         child: RichText(
//                           text: TextSpan(
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: AppTheme.darkGrey,
//                             ),
//                             children: [
//                               const TextSpan(text: 'I agree to the '),
//                               TextSpan(
//                                 text: 'Terms and Conditions',
//                                 style: TextStyle(
//                                   color: AppTheme.primaryBlue,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 32),

//                 // Register Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _handleRegister,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryPurple,
//                       foregroundColor: AppTheme.white,
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
//                             'Sign Up',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),

//                 // Login Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Already have an account? ',
//                       style: TextStyle(
//                         color: AppTheme.darkGrey,
//                         fontSize: 15,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacementNamed(context, AppRoutes.login);
//                       },
//                       child: const Text(
//                         'Login',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/routes.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Conditions'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // Show error from provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      // Clear error after showing
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth provider to show loading state
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryPurple,
                          AppTheme.primaryBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_city,
                      size: 35,
                      color: AppTheme.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkGrey,
                  ),
                ),
                
                const SizedBox(height: 32),

                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  validator: Validator.validateName,
                ),
                
                const SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  validator: Validator.validateEmail,
                ),
                
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.primaryPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.darkGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: Validator.validatePassword,
                ),
                
                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.primaryPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.darkGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => Validator.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),
                
                const SizedBox(height: 24),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.darkGrey,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppTheme.darkGrey,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}