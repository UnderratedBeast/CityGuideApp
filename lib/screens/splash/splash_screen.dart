import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/routes.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 10), () {
      if (!mounted) return;

      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            "https://i.pinimg.com/736x/94/b4/20/94b420d6ca60cf5ea8cd5f312752759b.jpg",
            fit: BoxFit.cover,
          ),

          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                // App Name
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "City",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "Guide",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                const Text(
                  "Explore Your City Like\nNever Before",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 80),

                // Loading Text
                const Text(
                  "LOCATING NEARBY GEMS",
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    color: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 12),

                // Progress Indicator
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    color: Colors.blueAccent,
                    minHeight: 3,
                  ),
                ),

                const SizedBox(height: 30),

                // Footer
                const Text(
                  "• PREMIUM URBAN TRAVEL GUIDE •",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
