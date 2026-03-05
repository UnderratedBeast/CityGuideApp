// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../utils/theme.dart'; // adjust path if needed

// class AdminFloatingBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const AdminFloatingBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       {'icon': Icons.dashboard_outlined, 'label': 'Home'},
//       {'icon': Icons.place_outlined, 'label': 'Listings'},
//       {'icon': Icons.reviews_outlined, 'label': 'Reviews'},
//       {'icon': Icons.settings_outlined, 'label': 'Settings'},
//     ];

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(35),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             height: 70,
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(72, 0, 0, 0),
//               borderRadius: BorderRadius.circular(35),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 20,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: List.generate(items.length, (index) {
//                 final isSelected = index == currentIndex;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => onTap(index),
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 6, vertical: 8),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             items[index]['icon'] as IconData,
//                             color: isSelected
//                                 ? AppTheme.primaryBlue
//                                 : Colors.white,
//                             size: 26,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             items[index]['label'] as String,
//                             style: TextStyle(
//                               color: isSelected
//                                   ? AppTheme.primaryBlue
//                                   : Colors.white,
//                               fontSize: 12,
//                               fontWeight: isSelected
//                                   ? FontWeight.w600
//                                   : FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }