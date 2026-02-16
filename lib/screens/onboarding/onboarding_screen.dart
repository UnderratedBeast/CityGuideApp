// // lib/screens/onboarding/onboarding_screen.dart

// import 'package:flutter/material.dart';
// import '../../utils/routes.dart';
// import '../../utils/theme.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<OnboardingPage> _pages = [
//     OnboardingPage(
//       icon: Icons.explore,
//       title: 'Discover Amazing Places',
//       description: 'Find the best attractions, restaurants, and hidden gems in your city with personalized recommendations.',
//       gradient: [AppTheme.primaryPurple, AppTheme.primaryBlue],
//     ),
//     OnboardingPage(
//       icon: Icons.map,
//       title: 'Navigate with Ease',
//       description: 'Get detailed directions and real-time navigation to any location. Never get lost again!',
//       gradient: [AppTheme.primaryBlue, AppTheme.primaryPurple],
//     ),
//     OnboardingPage(
//       icon: Icons.favorite,
//       title: 'Save Your Favorites',
//       description: 'Create personalized lists of your favorite places and share them with friends and family.',
//       gradient: [AppTheme.primaryPurple, AppTheme.primaryBlue],
//     ),
//     OnboardingPage(
//       icon: Icons.star,
//       title: 'Rate & Review',
//       description: 'Share your experiences and help others discover the best spots in town.',
//       gradient: [AppTheme.primaryBlue, AppTheme.primaryPurple],
//     ),
//   ];

//   void _onPageChanged(int page) {
//     setState(() {
//       _currentPage = page;
//     });
//   }

//   void _nextPage() {
//     if (_currentPage < _pages.length - 1) {
//       _pageController.animateToPage(
//         _currentPage + 1,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _completeOnboarding();
//     }
//   }

//   void _skipOnboarding() {
//     _completeOnboarding();
//   }

//   void _completeOnboarding() {
//     // TODO: Save onboarding completion status to shared preferences
//     Navigator.of(context).pushReplacementNamed(AppRoutes.login);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Skip Button
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: TextButton(
//                   onPressed: _skipOnboarding,
//                   child: const Text(
//                     'Skip',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // PageView
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 onPageChanged: _onPageChanged,
//                 itemCount: _pages.length,
//                 itemBuilder: (context, index) {
//                   return _buildPage(_pages[index]);
//                 },
//               ),
//             ),

//             // Page Indicators
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   _pages.length,
//                   (index) => _buildIndicator(index),
//                 ),
//               ),
//             ),

//             // Next/Get Started Button
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _nextPage,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: Text(
//                     _currentPage == _pages.length - 1
//                         ? 'Get Started'
//                         : 'Next',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPage(OnboardingPage page) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Icon with Gradient Background
//           Container(
//             width: 140,
//             height: 140,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: page.gradient,
//               ),
//               borderRadius: BorderRadius.circular(35),
//               boxShadow: [
//                 BoxShadow(
//                   color: page.gradient[0].withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Icon(
//               page.icon,
//               size: 70,
//               color: AppTheme.white,
//             ),
//           ),

//           const SizedBox(height: 48),

//           // Title
//           Text(
//             page.title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: AppTheme.black,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Description
//           Text(
//             page.description,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 16,
//               color: AppTheme.darkGrey,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIndicator(int index) {
//     final isActive = index == _currentPage;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       width: isActive ? 24 : 8,
//       height: 8,
//       decoration: BoxDecoration(
//         color: isActive ? AppTheme.primaryPurple : AppTheme.lightGrey,
//         borderRadius: BorderRadius.circular(4),
//       ),
//     );
//   }
// }

// class OnboardingPage {
//   final IconData icon;
//   final String title;
//   final String description;
//   final List<Color> gradient;

//   OnboardingPage({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.gradient,
//   });
// }

// ###############################



// lib/screens/onboarding/onboarding_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
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
          'https://img.freepik.com/premium-vector/illustration-person-going-holiday-flat-minimalist-design-concept-travel-lifestyle_1140815-198.jpg?semt=ais_hybrid&w=740',
      title: 'Discover New Adventures',
      description:
          'Plan trips effortlessly and explore destinations curated just for you.',
    ),
    _OnboardingData(
      imageUrl:
          'https://img.freepik.com/free-photo/top-view-paper-style-community-map_23-2149377697.jpg?t=st=1771260111~exp=1771263711~hmac=480df07af662cbf7cd702ac37477d80e847e3b95cd94ffbedfcfef29f9393e82',
      title: 'Smart Navigation',
      description:
          'Move around the city confidently with intelligent routes and insights.',
    ),
    _OnboardingData(
      imageUrl:
          'https://img.freepik.com/premium-photo/isometric-view-3d-rendering-neon-city_978521-41846.jpg?semt=ais_hybrid&w=740&q=80',
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

  void _next() {
    if (_page.round() < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.login),
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
                    shadowColor: AppTheme.primaryBlue.withOpacity(0.35),
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
    final double delta = page - index;
    final double scale = 1 - (delta.abs() * 0.12).clamp(0, 0.12);

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
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
                  ),
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
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.75),
                          Colors.white.withOpacity(0.55),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.description,
                          style: const TextStyle(
                            color: AppTheme.darkGrey,
                            height: 1.45,
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
    );
  }
}

class _Indicators extends StatelessWidget {
  final int length;
  final double page;

  const _Indicators({required this.length, required this.page});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final active = (page.round() == i);
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
