// import 'package:city_guide_app/screens/CityguideHome/CityDetailScreen.dart';
// import 'package:flutter/material.dart';

// class CityListScreen extends StatelessWidget {
//   const CityListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: CustomScrollView(
//         slivers: [
//           // Pinned header with title + search bar - KEPT AS IN IMAGE 1
//           SliverAppBar(
//             pinned: true,
//             floating: false,
//             backgroundColor: Colors.grey.shade50,
//             elevation: 0,
//             titleSpacing: 0,
//             title: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "CitiGuide",
//                     style: TextStyle(
//                       fontSize: 23,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: -0.5,
//                       color: Colors.black,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.person_outline_rounded),
//                     onPressed: () {},
//                   ),
//                 ],
//               ),
//             ),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(68),
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: const TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search for a city or attractions...",
//                       hintStyle: TextStyle(color: Colors.grey),
//                       prefixIcon: Icon(Icons.search, color: Colors.grey),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Featured Cities header
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Featured Cities",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text(
//                       "View all",
//                       style: TextStyle(color: const Color.fromARGB(255, 159, 7, 229)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Horizontal featured cities list
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 180,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 children: [
//                   FeaturedCityCard(
//                     city: "Ibadan",
//                     subtitle: "THE CITY OF LIGHT",
//                     imageUrl:
//                         "https://content.r9cdn.net/rimg/dimg/79/88/0abba836-city-24644-172728ab650.jpg?width=1366&height=768&xhint=4341&yhint=1691&crop=true",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CityDetailScreen(
//                             cityName: "Ibadan",
//                             country: "Nigeria",
//                             heroImageUrl: "https://content.r9cdn.net/rimg/dimg/79/88/0abba836-city-24644-172728ab650.jpg?width=1366&height=768&xhint=4341&yhint=1691&crop=true",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   FeaturedCityCard(
//                     city: "Lagos",
//                     subtitle: "NEON HEART",
//                     imageUrl:
//                         "https://naijabiography.com/wp-content/uploads/2022/09/Lagos11.jpg",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CityDetailScreen(
//                             cityName: "Lagos",
//                             country: "Nigeria",
//                             heroImageUrl: "https://naijabiography.com/wp-content/uploads/2022/09/Lagos11.jpg",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   FeaturedCityCard(
//                     city: "Abuja",
//                     subtitle: "THE CAPITAL CITY",
//                     imageUrl:
//                         "https://i1.wp.com/gazettengr.com/wp-content/uploads/Screenshot_20240107-232700_Chrome.jpg",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CityDetailScreen(
//                             cityName: "Abuja",
//                             country: "Nigeria",
//                             heroImageUrl: "https://i1.wp.com/gazettengr.com/wp-content/uploads/Screenshot_20240107-232700_Chrome.jpg",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Spacing
//           const SliverToBoxAdapter(child: SizedBox(height: 24)),

//           // Available Cities title
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 "Available Cities",
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),

//           const SliverToBoxAdapter(child: SizedBox(height: 12)),

//           // REDESIGNED Available cities list - Image left, transparent container right
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             sliver: SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   final cities = [
//                     {
//                       'city': 'Calabar',
//                       'country': 'Nigeria',
//                       'description': 'Historic city known for the Calabar Carnival and colonial architecture.',
//                       'tags': ["HISTORY", "DINING"],
//                       'imageUrl':
//                           "https://steemitimages.com/DQmXgUouUrXXnPKdTzLKjvvFaQLv5DmQEGyMLjiwRwjVZrx/calabar6.jpg",
//                     },
//                     {
//                       'city': 'Uyo',
//                       'country': 'Nigeria',
//                       'description': 'Modern capital city with beautiful parks and the impressive Nest of Champions stadium.',
//                       'tags': ["LUXURY", "MODERN"],
//                       'imageUrl':
//                           "https://afrikanza.com/cdn/shop/articles/biggest-sport-stadiums-in-africa_34c0c09f-7ab3-4b46-bc1b-48f099bc8d15_1200x630.jpg?v=1590689925",
//                     },
//                     {
//                       'city': 'Enugu',
//                       'country': 'Nigeria',
//                       'description': 'Coal city state surrounded by hills and known for its scenic beauty.',
//                       'tags': ["NATURE", "URBAN"],
//                       'imageUrl':
//                           "https://media.cnn.com/api/v1/images/stellar/prod/170215190625-enugu-restricted.jpg?q=w_1110,c_fill",
//                     },
//                     {
//                       'city': 'Port Harcourt',
//                       'country': 'Nigeria',
//                       'description': 'Oil-rich city with vibrant nightlife and waterfront attractions.',
//                       'tags': ["INDUSTRIAL", "RIVER"],
//                       'imageUrl':
//                           "https://www.nairaland.com/attachments/18964801_ph5_jpeg3905053f31f3253362c8ab6e18716e78",
//                     },
//                     {
//                       'city': 'Abeokuta',
//                       'country': 'Nigeria',
//                       'description': 'City under the rocks, home to the famous Olumo Rock and historic sites.',
//                       'tags': ["HISTORY", "ROCKS"],
//                       'imageUrl':
//                           "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Central_Mosque_Abeokuta.jpg/500px-Central_Mosque_Abeokuta.jpg",
//                     },
//                   ];
                  
//                   final cityData = cities[index];
//                   return CityHorizontalCard(
//                     city: cityData['city'] as String,
//                     country: cityData['country'] as String,
//                     description: cityData['description'] as String,
//                     tags: cityData['tags'] as List<String>,
//                     imageUrl: cityData['imageUrl'] as String,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CityDetailScreen(
//                             cityName: cityData['city'] as String,
//                             country: cityData['country'] as String,
//                             heroImageUrl: cityData['imageUrl'] as String,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//                 childCount: 5,
//               ),
//             ),
//           ),
//         ],
//       ),

//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const Color.fromARGB(255, 146, 4, 151),
//         unselectedItemColor: Colors.grey.shade500,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
//           BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
//         ],
//         currentIndex: 0,
//         onTap: (index) {
//           // Handle bottom nav taps
//         },
//       ),
//     );
//   }
// }

// class FeaturedCityCard extends StatelessWidget {
//   final String city;
//   final String subtitle;
//   final String imageUrl;
//   final VoidCallback? onTap;

//   const FeaturedCityCard({
//     super.key,
//     required this.city,
//     required this.subtitle,
//     required this.imageUrl,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 260,
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 height: double.infinity,
//                 width: double.infinity,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   color: Colors.grey.shade300,
//                   child: const Icon(Icons.error),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 20,
//               left: 20,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     city,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       shadows: const [Shadow(blurRadius: 6, color: Colors.black54)],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CityHorizontalCard extends StatelessWidget {
//   final String city;
//   final String country;
//   final String description;
//   final List<String> tags;
//   final String imageUrl;
//   final VoidCallback? onTap;

//   const CityHorizontalCard({
//     super.key,
//     required this.city,
//     required this.country,
//     required this.description,
//     required this.tags,
//     required this.imageUrl,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//         height: 120,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Left side - Image
//             ClipRRect(
//               borderRadius: const BorderRadius.horizontal(
//                 left: Radius.circular(16),
//               ),
//               child: Image.network(
//                 imageUrl,
//                 width: 120,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   width: 120,
//                   color: const Color.fromARGB(255, 0, 0, 0),
//                   child: const Icon(Icons.image_not_supported, color: Color.fromARGB(255, 5, 5, 5)),
//                 ),
//               ),
//             ),
            
//             // Right side - Transparent container with gradient
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.horizontal(
//                     right: Radius.circular(16),
//                   ),
//                    border: Border.all(
//                   color: const Color.fromARGB(255, 237, 237, 237),
//                   width: 1,
//                     ),
//                   gradient: LinearGradient(
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                     colors: [
//                       const Color.fromARGB(255, 255, 255, 255).withOpacity(0.75),
//                       const Color.fromARGB(255, 255, 255, 255).withOpacity(0.85),
//                     ],
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // City name
//                       Text(
//                         city,
//                         style: const TextStyle(
//                           color: Color.fromARGB(255, 0, 0, 0),
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       // Country
//                       Text(
//                         country,
//                         style: TextStyle(
//                           color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       // Very short description with ellipsis
//                       Text(
//                         description,
//                         style: TextStyle(
//                           color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
//                           fontSize: 12,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:city_guide_app/screens/CityguideHome/CityDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
// import 'profile_screen.dart';

class CityListScreen extends StatelessWidget {
  const CityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Pinned header with title + search bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Colors.grey.shade50,
            elevation: 0,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "CitiGuide",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline_rounded),
                    onPressed: () {
                      // Slide + fade transition
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const ProfileScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0); // slide from right
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          final tween =
                              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: FadeTransition(
                              opacity: animation.drive(fadeTween),
                              child: child,
                            ),
                          );
                        },
                      ));
                    },
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(68),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search for a city or attractions...",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Featured Cities header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Cities",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "View all",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 159, 7, 229)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal featured cities list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  FeaturedCityCard(
                    city: "Ibadan",
                    subtitle: "THE CITY OF LIGHT",
                    imageUrl:
                        "https://content.r9cdn.net/rimg/dimg/79/88/0abba836-city-24644-172728ab650.jpg?width=1366&height=768&xhint=4341&yhint=1691&crop=true",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CityDetailScreen(
                            cityName: "Ibadan",
                            country: "Nigeria",
                            heroImageUrl:
                                "https://content.r9cdn.net/rimg/dimg/79/88/0abba836-city-24644-172728ab650.jpg?width=1366&height=768&xhint=4341&yhint=1691&crop=true",
                          ),
                        ),
                      );
                    },
                  ),
                  FeaturedCityCard(
                    city: "Lagos",
                    subtitle: "NEON HEART",
                    imageUrl:
                        "https://naijabiography.com/wp-content/uploads/2022/09/Lagos11.jpg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CityDetailScreen(
                            cityName: "Lagos",
                            country: "Nigeria",
                            heroImageUrl:
                                "https://naijabiography.com/wp-content/uploads/2022/09/Lagos11.jpg",
                          ),
                        ),
                      );
                    },
                  ),
                  FeaturedCityCard(
                    city: "Abuja",
                    subtitle: "THE CAPITAL CITY",
                    imageUrl:
                        "https://i1.wp.com/gazettengr.com/wp-content/uploads/Screenshot_20240107-232700_Chrome.jpg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CityDetailScreen(
                            cityName: "Abuja",
                            country: "Nigeria",
                            heroImageUrl:
                                "https://i1.wp.com/gazettengr.com/wp-content/uploads/Screenshot_20240107-232700_Chrome.jpg",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Available Cities title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Available Cities",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // REDESIGNED Available cities list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cities = [
                    {
                      'city': 'Calabar',
                      'country': 'Nigeria',
                      'description':
                          'Historic city known for the Calabar Carnival and colonial architecture.',
                      'tags': ["HISTORY", "DINING"],
                      'imageUrl':
                          "https://steemitimages.com/DQmXgUouUrXXnPKdTzLKjvvFaQLv5DmQEGyMLjiwRwjVZrx/calabar6.jpg",
                    },
                    {
                      'city': 'Uyo',
                      'country': 'Nigeria',
                      'description':
                          'Modern capital city with beautiful parks and the impressive Nest of Champions stadium.',
                      'tags': ["LUXURY", "MODERN"],
                      'imageUrl':
                          "https://afrikanza.com/cdn/shop/articles/biggest-sport-stadiums-in-africa_34c0c09f-7ab3-4b46-bc1b-48f099bc8d15_1200x630.jpg?v=1590689925",
                    },
                    {
                      'city': 'Enugu',
                      'country': 'Nigeria',
                      'description':
                          'Coal city state surrounded by hills and known for its scenic beauty.',
                      'tags': ["NATURE", "URBAN"],
                      'imageUrl':
                          "https://media.cnn.com/api/v1/images/stellar/prod/170215190625-enugu-restricted.jpg?q=w_1110,c_fill",
                    },
                    {
                      'city': 'Port Harcourt',
                      'country': 'Nigeria',
                      'description':
                          'Oil-rich city with vibrant nightlife and waterfront attractions.',
                      'tags': ["INDUSTRIAL", "RIVER"],
                      'imageUrl':
                          "https://www.nairaland.com/attachments/18964801_ph5_jpeg3905053f31f3253362c8ab6e18716e78",
                    },
                    {
                      'city': 'Abeokuta',
                      'country': 'Nigeria',
                      'description':
                          'City under the rocks, home to the famous Olumo Rock and historic sites.',
                      'tags': ["HISTORY", "ROCKS"],
                      'imageUrl':
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Central_Mosque_Abeokuta.jpg/500px-Central_Mosque_Abeokuta.jpg",
                    },
                  ];

                  final cityData = cities[index];
                  return CityHorizontalCard(
                    city: cityData['city'] as String,
                    country: cityData['country'] as String,
                    description: cityData['description'] as String,
                    tags: cityData['tags'] as List<String>,
                    imageUrl: cityData['imageUrl'] as String,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CityDetailScreen(
                            cityName: cityData['city'] as String,
                            country: cityData['country'] as String,
                            heroImageUrl: cityData['imageUrl'] as String,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: 5,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 146, 4, 151),
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom nav taps
        },
      ),
    );
  }
}

class FeaturedCityCard extends StatelessWidget {
  final String city;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;

  const FeaturedCityCard({
    super.key,
    required this.city,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: const [Shadow(blurRadius: 6, color: Colors.black54)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CityHorizontalCard extends StatelessWidget {
  final String city;
  final String country;
  final String description;
  final List<String> tags;
  final String imageUrl;
  final VoidCallback? onTap;

  const CityHorizontalCard({
    super.key,
    required this.city,
    required this.country,
    required this.description,
    required this.tags,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side - Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: 120,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  child: const Icon(Icons.image_not_supported, color: Color.fromARGB(255, 5, 5, 5)),
                ),
              ),
            ),
            
            // Right side - Transparent container with gradient
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                   border: Border.all(
                  color: const Color.fromARGB(255, 237, 237, 237),
                  width: 1,
                    ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.75),
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.85),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // City name
                      Text(
                        city,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Country
                      Text(
                        country,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Very short description with ellipsis
                      Text(
                        description,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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