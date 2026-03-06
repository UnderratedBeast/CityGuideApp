import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/routes.dart';
import '../../utils/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  double _page = 0.0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      imageUrl:
          'https://img.freepik.com/premium-vector/illustration-person-going-holiday-flat-minimalist-design-concept-travel-lifestyle_1140815-198.jpg',
      title: 'Discover New Adventures',
      description:
          'Plan trips effortlessly and explore destinations curated just for you.',
    ),
    _OnboardingData(
      imageUrl:
          'https://media.istockphoto.com/id/522142862/vector/smartphone-with-navigation.jpg?s=612x612&w=0&k=20&c=6JhXH6VVm--dWi4YZBG3IqoDok-_-1_5rmif2TSTmW0=',
      title: 'Smart Navigation',
      description:
          'Move around the city confidently with intelligent routes and insights.',
    ),
    _OnboardingData(
      imageUrl:
          'https://img.freepik.com/premium-photo/isometric-view-3d-rendering-neon-city_978521-41846.jpg',
      title: 'Experience the City Like a Local',
      description:
          'Find hidden gems, local favorites, and authentic urban experiences.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;
    // Navigator.pushReplacementNamed(context, AppRoutes.signUp);
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _next() {
    if (_page.round() < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                itemBuilder: (_, i) =>
                    _OnboardingCard(data: _pages[i], index: i, page: _page),
              ),
            ),
            _Indicators(length: _pages.length, page: _page),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    _page.round() == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}

/* ---------------- CARD ---------------- */

class _OnboardingCard extends StatelessWidget {
  final _OnboardingData data;
  final int index;
  final double page;

  const _OnboardingCard({
    required this.data,
    required this.index,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final delta = page - index;
final scale = 1.0 - (delta.abs() * 0.12).clamp(0.0, 0.12).toDouble();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Transform.scale(
        scale: scale,
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(delta * 40, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(data.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 36,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.description,
                          style: const TextStyle(height: 1.45),
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
}

/* ---------------- INDICATORS ---------------- */

class _Indicators extends StatelessWidget {
  final int length;
  final double page;

  const _Indicators({required this.length, required this.page});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final active = page.round() == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primaryBlue
                : AppTheme.primaryBlue.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/* ---------------- MODEL ---------------- */

class _OnboardingData {
  final String imageUrl;
  final String title;
  final String description;

  const _OnboardingData({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}
