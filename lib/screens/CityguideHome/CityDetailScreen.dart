// import 'package:city_guide_app/screens/attraction/AttractionListScreen.dart';
// import 'package:flutter/material.dart';

// class CityDetailScreen extends StatefulWidget {
//   final String cityName;
//   final String country;
//   final String heroImageUrl;

//   const CityDetailScreen({
//     super.key,
//     required this.cityName,
//     required this.country,
//     required this.heroImageUrl,
//   });

//   @override
//   State<CityDetailScreen> createState() => _CityDetailScreenState();
// }

// class _CityDetailScreenState extends State<CityDetailScreen> {
//   // City descriptions based on the cities from CityListScreen
//   final Map<String, String> cityDescriptions = {
//     'Calabar':
//         'Calabar is a historic port city known as the "Canaan City". It serves as the capital of Cross River State and is famous for the annual Calabar Carnival, colonial architecture, and being a major tourist destination in Nigeria.',
//     'Uyo':
//         'Uyo is the capital of Akwa Ibom State, known for its rapid modernization, beautiful parks, and the impressive Nest of Champions stadium. The city blends urban development with cultural heritage.',
//     'Enugu':
//         'Enugu, the "Coal City State", is nestled among hills and known for its scenic beauty. It was named after the Enugu Coal Mines and serves as a major commercial and political hub in southeastern Nigeria.',
//     'Port Harcourt':
//         'Port Harcourt is an oil-rich city in Rivers State, known as the "Garden City". It features vibrant nightlife, waterfront attractions, and serves as the economic heartbeat of the Niger Delta.',
//     'Abeokuta':
//         'Abeokuta, meaning "Under the Rock", is home to the famous Olumo Rock. This historic city served as a refuge during inter-tribal wars and features unique rock formations and colonial-era architecture.',
//     'Ibadan':
//         'Ibadan is the capital of Oyo State and one of the largest cities in Africa by geographical area. Known for its ancient landmarks, University of Ibadan, and vibrant cultural heritage.',
//     'Lagos':
//         'Lagos is Nigeria\'s largest city and economic capital, featuring a dynamic blend of modern skyscrapers, historic districts, and vibrant nightlife. It\'s the heartbeat of West African commerce and entertainment.',
//     'Abuja':
//         'Abuja is Nigeria\'s purpose-built capital city, known for its impressive architecture, Aso Rock, and planned urban development. It serves as the seat of Nigerian government and diplomacy.',
//   };

//   // City slideshow images
//   final Map<String, List<String>> citySlideshowImages = {
//     'Calabar': [
//       "https://steemitimages.com/DQmXgUouUrXXnPKdTzLKjvvFaQLv5DmQEGyMLjiwRwjVZrx/calabar6.jpg",
//       "https://media.premiumtimesng.com/wp-content/files/2021/12/Calabar-Carnival.jpg",
//       "https://guardian.ng/wp-content/uploads/2020/12/Calabar-Museum.jpg",
//     ],
//     'Uyo': [
//       "https://afrikanza.com/cdn/shop/articles/biggest-sport-stadiums-in-africa_34c0c09f-7ab3-4b46-bc1b-48f099bc8d15_1200x630.jpg?v=1590689925",
//       "https://akwaibomstate.gov.ng/wp-content/uploads/2021/05/Godswill-Akpabio-International-Stadium-2.jpg",
//       "https://hotels.ng/guides/wp-content/uploads/2021/08/ibom-tropicana.jpg",
//     ],
//     'Enugu': [
//       "https://media.cnn.com/api/v1/images/stellar/prod/170215190625-enugu-restricted.jpg?q=w_1110,c_fill",
//       "https://pbs.twimg.com/media/Eqxf1cJW4AEwUct.jpg",
//       "https://www.nigeriagalleria.com/Nigeria/States_Nigeria/Enugu/Enugu-State.html",
//     ],
//     'Port Harcourt': [
//       "https://www.nairaland.com/attachments/18964801_ph5_jpeg3905053f31f3253362c8ab6e18716e78",
//       "https://tourism.africa/wp-content/uploads/2022/03/Port-Harcourt.jpg",
//       "https://www.vanguardngr.com/wp-content/uploads/2021/07/Port-Harcourt-768x512.jpg",
//     ],
//     'Abeokuta': [
//       "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Central_Mosque_Abeokuta.jpg/500px-Central_Mosque_Abeokuta.jpg",
//       "https://guardian.ng/wp-content/uploads/2022/01/Olumo-Rock.jpg",
//       "https://www.pulse.ng/files/2016/08/Olumo-Rock-Abeokuta.jpg",
//     ],
//     'Ibadan': [
//       "https://content.r9cdn.net/rimg/dimg/79/88/0abba836-city-24644-172728ab650.jpg?width=1366&height=768&xhint=4341&yhint=1691&crop=true",
//       "https://i.pinimg.com/originals/87/f2/b6/87f2b6e396327ef311ad3cf0ea21a106.jpg?nii=t",
//       "https://i.pinimg.com/736x/6c/1c/53/6c1c5339fa9f6060a5fc4cf2bb7cb24d.jpg",
//     ],
//     'Lagos': [
//       "https://naijabiography.com/wp-content/uploads/2022/09/Lagos11.jpg",
//       "https://media.cnn.com/api/v1/images/stellar/prod/191010113235-03-lagos-nigeria-okafor.jpg",
//       "https://guardian.ng/wp-content/uploads/2021/03/Lagos-Island.jpg",
//     ],
//     'Abuja': [
//       "https://i1.wp.com/gazettengr.com/wp-content/uploads/Screenshot_20240107-232700_Chrome.jpg",
//       "https://media.premiumtimesng.com/wp-content/files/2022/02/Aso-Rock-1.jpg",
//       "https://guardian.ng/wp-content/uploads/2021/10/National-Mosque-Abuja.jpg",
//     ],
//   };

//   late PageController _pageController;
//   late List<String> slideshowImages;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     slideshowImages = citySlideshowImages[widget.cityName] ??
//         [widget.heroImageUrl, widget.heroImageUrl, widget.heroImageUrl];

//     _pageController = PageController(
//       initialPage: 0,
//     );

//     // Auto slide every 6 seconds
//     Future.delayed(Duration.zero, () {
//       _startAutoSlide();
//     });
//   }

//   void _startAutoSlide() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           if (_currentPage < slideshowImages.length - 1) {
//             _currentPage++;
//           } else {
//             _currentPage = 0;
//           }
//           _pageController.animateToPage(
//             _currentPage,
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         });
//         _startAutoSlide(); // Recursive call for continuous sliding
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final description = cityDescriptions[widget.cityName] ??
//         'Explore the beautiful city of ${widget.cityName}, ${widget.country}. Discover its unique culture, history, and attractions.';

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // Hero image with slideshow - AUTO SLIDING

//           SliverAppBar(
//             expandedHeight: 300.0,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // PageView for slideshow - AUTO SLIDING
//                   PageView.builder(
//                     controller: _pageController,
//                     itemCount: slideshowImages.length,
//                     onPageChanged: (index) {
//                       setState(() {
//                         _currentPage = index;
//                       });
//                     },
//                     itemBuilder: (context, index) {
//                       return Image.network(
//                         slideshowImages[index],
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Container(
//                           color: Colors.grey.shade300,
//                           child: const Center(
//                             child: Icon(Icons.image_not_supported,
//                                 size: 50, color: Colors.grey),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   // Gradient overlay
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.black.withOpacity(0.2),
//                           Colors.black.withOpacity(0.7),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Page indicator dots
//                   Positioned(
//                     bottom: 20,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: List.generate(
//                           slideshowImages.length,
//                           (index) => Container(
//                             width: 8,
//                             height: 8,
//                             margin: const EdgeInsets.only(right: 6),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: index == _currentPage
//                                   ? Colors.white
//                                   : Colors.white.withOpacity(0.5),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               titlePadding: const EdgeInsets.only(
//                 left: 26,
//                 top: 10,
//                 bottom: 10,
//               ),
//               title: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.cityName,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         size: 10,
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         widget.country,
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.white.withOpacity(0.9),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.favorite_border, color: Colors.white),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.share, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//             leadingWidth: 20, // reduce default width (default is 56)
//             leading: IconButton(
//               padding: EdgeInsets.zero, // removes internal padding
//               constraints:
//                   const BoxConstraints(), // removes default constraints
//               icon: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: Colors.white,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             backgroundColor:
//                 const Color.fromARGB(255, 78, 0, 85).withOpacity(1),
//           ),

//           // City Description - Full description under city name
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'About ${widget.cityName}',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.purple.shade900,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     description,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       height: 1.5,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Divider
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Divider(
//                 color: Colors.grey.shade300,
//                 thickness: 1,
//               ),
//             ),
//           ),

//           // Category buttons - Redesigned to match image with purple theme
// // Category buttons - now with navigation
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _CategoryButton(
//                     icon: Icons.attractions,
//                     label: "Attractions",
//                     color: Colors.purple,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => AttractionListScreen(
//                             category: "Attractions",
//                             cityName: widget.cityName,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   _CategoryButton(
//                     icon: Icons.restaurant,
//                     label: "Dining",
//                     color: Colors.purple,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => AttractionListScreen(
//                             category: "Dining",
//                             cityName: widget.cityName,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   _CategoryButton(
//                     icon: Icons.hotel,
//                     label: "Hotels",
//                     color: Colors.purple,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => AttractionListScreen(
//                             category: "Hotels",
//                             cityName: widget.cityName,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   _CategoryButton(
//                     icon: Icons.event,
//                     label: "Events",
//                     color: Colors.purple,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => AttractionListScreen(
//                             category: "Events",
//                             cityName: widget.cityName,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Popular Now section header
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Popular Now",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: const Color.fromARGB(255, 0, 0, 0),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.purple.shade600,
//                     ),
//                     child: const Text(
//                       "See All",
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 PopularCard(
//                   title: "The High Line",
//                   imageUrl:
//                       "https://upload.wikimedia.org/wikipedia/commons/5/5a/High_Line_Park%2C_Section_1a.jpg",
//                   description:
//                       "Elevated linear park on the west side with stunning city views.",
//                   category: "Attraction",
//                   location: "West Side",
//                   distance: "1.2 mi",
//                   phone: "+1 212-555-1234",
//                   website: "thehighline.org",
//                   openingHours: "Mon–Sun 07:00–22:00",
//                   rating: 4.8,
//                   action: "Explore",
//                   isOpen: true,
//                 ),
//                 const SizedBox(height: 16),
//                 PopularCard(
//                   title: "Le Bernardin",
//                   imageUrl:
//                       "https://www.le-bernardin.com/content/slides/lb-gallery-main.jpg",
//                   description:
//                       "World-renowned seafood dining in a sophisticated Midtown space.",
//                   category: "Dining",
//                   location: "Midtown",
//                   distance: "0.8 mi",
//                   phone: "+1 212-555-5678",
//                   website: "le-bernardin.com",
//                   openingHours: "Mon–Fri 12:00–22:30, Sat 17:00–22:30",
//                   rating: 4.9,
//                   action: "Book Table",
//                   isOpen: true,
//                 ),
//                 const SizedBox(height: 16),
//                 PopularCard(
//                   title: "The Standard, High Line",
//                   imageUrl:
//                       "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2c/20/b7/7c/stnd-hlexterior-highline.jpg",
//                   description: "Hip boutique hotel straddling the iconic park.",
//                   category: "Hotel",
//                   location: "West Side",
//                   distance: "1.5 mi",
//                   phone: "+1 212-555-9012",
//                   website: "standardhotels.com",
//                   openingHours: "24/7",
//                   rating: 4.6,
//                   action: "Check In",
//                   isOpen: true,
//                 ),
//                 const SizedBox(height: 16),
//                 PopularCard(
//                   title: "Chelsea Market",
//                   imageUrl:
//                       "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/0d/97/8c/chelsea-market.jpg",
//                   description:
//                       "Historic food hall with artisanal vendors and unique shops.",
//                   category: "Attractions",
//                   location: "Chelsea",
//                   distance: "0.9 mi",
//                   phone: "+1 212-555-3456",
//                   website: "chelseamarket.com",
//                   openingHours: "Mon–Sat 07:00–21:00, Sun 08:00–20:00",
//                   rating: 4.7,
//                   action: "Visit",
//                   isOpen: true,
//                 ),
//               ]),
//             ),
//           ),

//           const SliverToBoxAdapter(child: SizedBox(height: 30)),
//         ],
//       ),

//       // Bottom Navigation
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.purple.shade700,
//         unselectedItemColor: Colors.grey.shade500,
//         currentIndex: 0,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.favorite_border), label: "Saved"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.settings_outlined), label: "Settings"),
//         ],
//       ),
//     );
//   }
// }

// class _CategoryButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback? onTap;

//   const _CategoryButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap, // 👈 make tappable
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 251, 251, 251),
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   color:
//                       const Color.fromARGB(255, 112, 112, 112).withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Icon(
//               icon,
//               color: Colors.purple.shade700,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade800,
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PopularCard extends StatefulWidget {
//   final String title;
//   final String imageUrl;
//   final String description;
//   final String category; // e.g. "Attractions", "Dining"
//   final String location; // e.g. "Downtown"
//   final String distance;
//   final String phone;
//   final String website;
//   final String openingHours;
//   final double rating;
//   final String action;
//   final bool isOpen;

//   const PopularCard({
//     super.key,
//     required this.title,
//     required this.imageUrl,
//     required this.description,
//     required this.category,
//     required this.location,
//     required this.distance,
//     required this.phone,
//     required this.website,
//     required this.openingHours,
//     required this.rating,
//     required this.action,
//     required this.isOpen,
//   });

//   @override
//   State<PopularCard> createState() => _PopularCardState();
// }

// class _PopularCardState extends State<PopularCard> {
//   bool isFavorited = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ----- IMAGE WITH OVERLAYS -----
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(16)),
//                 child: Image.network(
//                   widget.imageUrl,
//                   height: 180,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     height: 180,
//                     color: Colors.grey.shade300,
//                     child: const Icon(Icons.image_not_supported),
//                   ),
//                 ),
//               ),
//               // Favorite heart (toggle)
//               Positioned(
//                 top: 12,
//                 right: 12,
//                 child: GestureDetector(
//                   onTap: () => setState(() => isFavorited = !isFavorited),
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       isFavorited ? Icons.favorite : Icons.favorite_border,
//                       color: isFavorited ? Colors.red : Colors.grey.shade700,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),
//               // Open/Closed badge
//               Positioned(
//                 bottom: 12,
//                 left: 12,
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: widget.isOpen ? Colors.green : Colors.red,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     widget.isOpen ? "OPEN" : "CLOSED",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // ----- CONTENT -----
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Name
//                 Text(
//                   widget.title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 // Category • location • distance
//                 Text(
//                   "${widget.category} • ${widget.location} • ${widget.distance}",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 // Description (2 lines max)
//                 Text(
//                   widget.description,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade800,
//                     height: 1.4,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 16),

//                 // ----- CONTACT & OPENING HOURS -----
//                 Row(
//                   children: [
//                     Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
//                     const SizedBox(width: 4),
//                     Text(
//                       widget.phone,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Icon(Icons.language, size: 16, color: Colors.grey.shade600),
//                     const SizedBox(width: 4),
//                     Text(
//                       widget.website,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.blue.shade700,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 // Opening hours
//                 Row(
//                   children: [
//                     Icon(Icons.access_time,
//                         size: 16, color: Colors.grey.shade600),
//                     const SizedBox(width: 4),
//                     Text(
//                       widget.openingHours,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // ----- RATING & ACTION BUTTON -----
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Rating with stars
//                     Row(
//                       children: [
//                         Text(
//                           widget.rating.toStringAsFixed(1),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Row(
//                           children: List.generate(5, (index) {
//                             if (index < widget.rating.floor()) {
//                               return const Icon(Icons.star,
//                                   color: Colors.amber, size: 18);
//                             } else if (index < widget.rating) {
//                               return const Icon(Icons.star_half,
//                                   color: Colors.amber, size: 18);
//                             } else {
//                               return Icon(Icons.star_border,
//                                   color: Colors.amber.shade300, size: 18);
//                             }
//                           }),
//                         ),
//                       ],
//                     ),
//                     // Action button
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.purple.shade600,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         widget.action,
//                         style: const TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ########################################

import 'package:city_guide_app/screens/attraction/AttractionListScreen.dart';
import 'package:flutter/material.dart';

class CityDetailScreen extends StatefulWidget {
  final String cityName;
  final String country;
  final String heroImageUrl;

  const CityDetailScreen({
    super.key,
    required this.cityName,
    required this.country,
    required this.heroImageUrl,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  final Map<String, String> cityDescriptions = {
    'Calabar':
        'Calabar is a historic port city known as the "Canaan City". It serves as the capital of Cross River State and is famous for the annual Calabar Carnival, colonial architecture, and being a major tourist destination in Nigeria.',
    'Uyo':
        'Uyo is the capital of Akwa Ibom State, known for its rapid modernization, beautiful parks, and the impressive Nest of Champions stadium. The city blends urban development with cultural heritage.',
    'Enugu':
        'Enugu, the "Coal City State", is nestled among hills and known for its scenic beauty. It was named after the Enugu Coal Mines and serves as a major commercial and political hub in southeastern Nigeria.',
    'Port Harcourt':
        'Port Harcourt is an oil-rich city in Rivers State, known as the "Garden City". It features vibrant nightlife, waterfront attractions, and serves as the economic heartbeat of the Niger Delta.',
    'Abeokuta':
        'Abeokuta, meaning "Under the Rock", is home to the famous Olumo Rock. This historic city served as a refuge during inter-tribal wars and features unique rock formations and colonial-era architecture.',
    'Ibadan':
        'Ibadan is the capital of Oyo State and one of the largest cities in Africa by geographical area. Known for its ancient landmarks, University of Ibadan, and vibrant cultural heritage.',
    'Lagos':
        'Lagos is Nigeria\'s largest city and economic capital, featuring a dynamic blend of modern skyscrapers, historic districts, and vibrant nightlife. It\'s the heartbeat of West African commerce and entertainment.',
    'Abuja':
        'Abuja is Nigeria\'s purpose-built capital city, known for its impressive architecture, Aso Rock, and planned urban development. It serves as the seat of Nigerian government and diplomacy.',
  };

  final Map<String, List<String>> citySlideshowImages = {
    'Calabar': [
      "https://steemitimages.com/DQmXgUouUrXXnPKdTzLKjvvFaQLv5DmQEGyMLjiwRwjVZrx/calabar6.jpg",
      "https://media.premiumtimesng.com/wp-content/files/2021/12/Calabar-Carnival.jpg",
      "https://guardian.ng/wp-content/uploads/2020/12/Calabar-Museum.jpg",
    ],
    'Uyo': [
      "https://afrikanza.com/cdn/shop/articles/biggest-sport-stadiums-in-africa_34c0c09f-7ab3-4b46-bc1b-48f099bc8d15_1200x630.jpg?v=1590689925",
      "https://akwaibomstate.gov.ng/wp-content/uploads/2021/05/Godswill-Akpabio-International-Stadium-2.jpg",
      "https://hotels.ng/guides/wp-content/uploads/2021/08/ibom-tropicana.jpg",
    ],
    'Enugu': [
      "https://media.cnn.com/api/v1/images/stellar/prod/170215190625-enugu-restricted.jpg?q=w_1110,c_fill",
      "https://pbs.twimg.com/media/Eqxf1cJW4AEwUct.jpg",
      "https://www.nigeriagalleria.com/Nigeria/States_Nigeria/Enugu/Enugu-State.html",
    ],
    'Port Harcourt': [
      "https://www.nairaland.com/attachments/18964801_ph5_jpeg3905053f31f3253362c8ab6e18716e78",
      "https://tourism.africa/wp-content/uploads/2022/03/Port-Harcourt.jpg",
      "https://www.vanguardngr.com/wp-content/uploads/2021/07/Port-Harcourt-768x512.jpg",
    ],
    'Abeokuta': [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Central_Mosque_Abeokuta.jpg/500px-Central_Mosque_Abeokuta.jpg",
      "https://guardian.ng/wp-content/uploads/2022/01/Olumo-Rock.jpg",
      "https://www.pulse.ng/files/2016/08/Olumo-Rock-Abeokuta.jpg",
    ],
    'Ibadan': [
      "https://content.r9cdn.net/rimg/dimg/79/88/0abba836-city-24644-172728ab650.jpg?width=1366&height=768&xhint=4341&yhint=1691&crop=true",
      "https://i.pinimg.com/originals/87/f2/b6/87f2b6e396327ef311ad3cf0ea21a106.jpg?nii=t",
      "https://i.pinimg.com/736x/6c/1c/53/6c1c5339fa9f6060a5fc4cf2bb7cb24d.jpg",
    ],
    'Lagos': [
      "https://naijabiography.com/wp-content/uploads/2022/09/Lagos11.jpg",
      "https://media.cnn.com/api/v1/images/stellar/prod/191010113235-03-lagos-nigeria-okafor.jpg",
      "https://guardian.ng/wp-content/uploads/2021/03/Lagos-Island.jpg",
    ],
    'Abuja': [
      "https://i1.wp.com/gazettengr.com/wp-content/uploads/Screenshot_20240107-232700_Chrome.jpg",
      "https://media.premiumtimesng.com/wp-content/files/2022/02/Aso-Rock-1.jpg",
      "https://guardian.ng/wp-content/uploads/2021/10/National-Mosque-Abuja.jpg",
    ],
  };

  late PageController _pageController;
  late List<String> slideshowImages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    slideshowImages = citySlideshowImages[widget.cityName] ??
        [widget.heroImageUrl, widget.heroImageUrl, widget.heroImageUrl];

    _pageController = PageController(initialPage: 0);

    Future.delayed(Duration.zero, _startAutoSlide);
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentPage =
              _currentPage < slideshowImages.length - 1 ? _currentPage + 1 : 0;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description = cityDescriptions[widget.cityName] ??
        'Explore the beautiful city of ${widget.cityName}, ${widget.country}. Discover its unique culture, history, and attractions.';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image with slideshow
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: slideshowImages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        slideshowImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          slideshowImages.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentPage
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 26, top: 10, bottom: 10),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cityName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black87)]),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(widget.country,
                          style: const TextStyle(fontSize: 10, color: Colors.white70))
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
            backgroundColor: const Color.fromARGB(255, 78, 0, 85),
          ),

          // City Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About ${widget.cityName}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900)),
                  const SizedBox(height: 12),
                  Text(description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      )),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.grey.shade300, thickness: 1),
            ),
          ),

          // Category buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CategoryButton(
                    icon: Icons.attractions,
                    label: "Attractions",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttractionListScreen(
                            category: "Attractions",
                            cityName: widget.cityName,
                          ),
                        ),
                      );
                    },
                  ),
                  _CategoryButton(
                    icon: Icons.restaurant,
                    label: "Dining",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttractionListScreen(
                            category: "Dining",
                            cityName: widget.cityName,
                          ),
                        ),
                      );
                    },
                  ),
                  _CategoryButton(
                    icon: Icons.hotel,
                    label: "Hotels",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttractionListScreen(
                            category: "Hotels",
                            cityName: widget.cityName,
                          ),
                        ),
                      );
                    },
                  ),
                  _CategoryButton(
                    icon: Icons.event,
                    label: "Events",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttractionListScreen(
                            category: "Events",
                            cityName: widget.cityName,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Popular Now
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Popular Now",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.purple.shade600),
                    child: const Text(
                      "See All",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Example PopularCard
                PopularCard(
                  title: "The High Line",
                  imageUrl:
                      "https://upload.wikimedia.org/wikipedia/commons/5/5a/High_Line_Park%2C_Section_1a.jpg",
                  description:
                      "Elevated linear park on the west side with stunning city views.",
                  category: "Attraction",
                  location: "West Side",
                  distance: "1.2 mi",
                  phone: "+1 212-555-1234",
                  website: "thehighline.org",
                  openingHours: "Mon–Sun 07:00–22:00",
                  rating: 4.8,
                  action: "Explore",
                  isOpen: true,
                ),
                const SizedBox(height: 16),
                // Add more PopularCard items here...
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple.shade700,
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }
}

// --------------------------- CATEGORY BUTTON ---------------------------
class _CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _CategoryButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 251, 251, 251),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.purple.shade700, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

// --------------------------- POPULAR CARD ---------------------------
class PopularCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String category;
  final String location;
  final String distance;
  final String phone;
  final String website;
  final String openingHours;
  final double rating;
  final String action;
  final bool isOpen;

  const PopularCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.location,
    required this.distance,
    required this.phone,
    required this.website,
    required this.openingHours,
    required this.rating,
    required this.action,
    required this.isOpen,
  });

  @override
  State<PopularCard> createState() => _PopularCardState();
}

class _PopularCardState extends State<PopularCard> {
  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  widget.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isFavorited = !isFavorited;
                    });
                  },
                  child: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 14),
                    const SizedBox(width: 4),
                    Text(widget.rating.toString(), style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Text(widget.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
