// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../widgets/navigation/admin_stats_card.dart';
// import 'admin_notification_screen.dart';
// import '../../utils/theme.dart';
// import '../../utils/helpers.dart';

// class DashboardHome extends StatelessWidget {
//   const DashboardHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // PERFORMANCE HEADER
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'PERFORMANCE',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text('Last 24h'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // STATS CARDS - HORIZONTAL SCROLL
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             clipBehavior: Clip.none,
//             child: Row(
//               children: [
//                 const StatsCard(
//                   title: 'Total Users',
//                   value: '12,548',
//                   icon: Icons.people,
//                   color: Color(0xFF2E5BFF),
//                   trend: 5.2,
//                   isLarge: true,
//                   progress: 0.65,
//                   gradient: [Color(0xFF2E5BFF), Color(0xFF1637C5)],
//                 ),
//                 const SizedBox(width: 16),
//                 const StatsCard(
//                   title: 'Total Listings',
//                   value: '1,420',
//                   icon: Icons.place,
//                   color: Color(0xFF833CF6),
//                   trend: 1.8,
//                   isLarge: true,
//                   progress: 0.45,
//                   gradient: [Color(0xFF833CF6), Color(0xFF6B25D4)],
//                 ),
//                 const SizedBox(width: 16),
//                 StatsCard(
//                   title: 'Pending Approvals',
//                   value: '48.2k',
//                   icon: Icons.visibility,
//                   color: const Color(0xFF00B4DB),
//                   isLarge: true,
//                   progress: 0.8,
//                   gradient: const [
//                     Color(0xFF00B4DB),
//                     Color(0xFF0083B0)
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 StatsCard(
//                   title: 'Total Reviews',
//                   value: '124',
//                   icon: Icons.verified,
//                   color: const Color(0xFF00F260),
//                   isLarge: true,
//                   progress: 0.3,
//                   gradient: const [
//                     Color(0xFF00F260),
//                     Color(0xFF0575E6)
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 40),

//           // RECENT ACTIVITY HEADER
//           Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//     TextButton(
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const AdminNotificationsScreen(),
//           ),
//         );
//       },
//       child: const Text('View All'),
//     ),
//   ],
// ),
//           const SizedBox(height: 16),

//           // REAL-TIME ACTIVITY STREAM
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('activities')
//                 .orderBy('createdAt', descending: true)
//                 .limit(5)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(
//                     child: Text('Error: ${snapshot.error}'));
//               }

//               if (snapshot.connectionState ==
//                   ConnectionState.waiting) {
//                 return const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               }

//               final docs = snapshot.data?.docs ?? [];

//               if (docs.isEmpty) {
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Text(
//                       'No recent activities yet.',
//                       style: TextStyle(color: Colors.grey[500]),
//                     ),
//                   ),
//                 );
//               }

//               return Column(
//                 children: docs.map((doc) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final timestamp = data['createdAt'] as Timestamp?;
//                   final timeText = timestamp != null
//                       ? Helper.formatDateTime(timestamp.toDate())
//                       : 'Recently';

//                   return _buildActivityItem(
//                     context,
//                     icon: _getIconForCategory(data['type']),
//                     iconColor: _getColorForCategory(data['type']),
//                     title: data['title'] ?? 'Activity',
//                     subtitle: data['body'] ?? '',
//                     time: timeText,
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//    // ================= ICON + COLOR =================

//   IconData _getIconForCategory(String? category) {
//     switch (category) {
//       case 'auth':
//         return Icons.person_add_rounded;
//       case 'review':
//         return Icons.star_rounded;
//       case 'system':
//         return Icons.system_update_rounded;
//       default:
//         return Icons.notifications_rounded;
//     }
//   }

//   Color _getColorForCategory(String? category) {
//     switch (category) {
//       case 'auth':
//         return Colors.blue;
//       case 'review':
//         return Colors.amber;
//       case 'system':
//         return Colors.blue;
//       default:
//         return Colors.redAccent;
//     }
//   }


//   Widget _buildActivityItem(
//     BuildContext context, {
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required String time,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.grey[100]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: iconColor, size: 24),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   time,
//                   style: TextStyle(
//                     color: Colors.grey[400],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/navigation/admin_stats_card.dart';
import 'admin_notification_screen.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PERFORMANCE HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERFORMANCE',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Last 24h'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // STATS CARDS WITH REAL DATA
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                // Total Users Card
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int userCount = 0;
                    if (snapshot.hasData) {
                      userCount = snapshot.data!.docs.length;
                    }
                    
                    return StatsCard(
                      title: 'Total Users',
                      value: Helper.formatNumber(userCount),
                      icon: Icons.people,
                      color: const Color(0xFF2E5BFF),
                      trend: 5.2,
                      isLarge: true,
                      progress: userCount > 0 ? (userCount / 100).clamp(0.0, 1.0) : 0,
                      gradient: const [Color(0xFF2E5BFF), Color(0xFF1637C5)],
                    );
                  },
                ),
                const SizedBox(width: 16),

                // Total Listings Card (combining all listing types)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collectionGroup('attractions')
                      .snapshots(),
                  builder: (context, attractionsSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collectionGroup('dining')
                          .snapshots(),
                      builder: (context, diningSnapshot) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collectionGroup('hotels')
                              .snapshots(),
                          builder: (context, hotelsSnapshot) {
                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collectionGroup('events')
                                  .snapshots(),
                              builder: (context, eventsSnapshot) {
                                int totalListings = 0;
                                
                                if (attractionsSnapshot.hasData) {
                                  totalListings += attractionsSnapshot.data!.docs.length;
                                }
                                if (diningSnapshot.hasData) {
                                  totalListings += diningSnapshot.data!.docs.length;
                                }
                                if (hotelsSnapshot.hasData) {
                                  totalListings += hotelsSnapshot.data!.docs.length;
                                }
                                if (eventsSnapshot.hasData) {
                                  totalListings += eventsSnapshot.data!.docs.length;
                                }

                                return StatsCard(
                                  title: 'Total Listings',
                                  value: Helper.formatNumber(totalListings),
                                  icon: Icons.place,
                                  color: const Color(0xFF833CF6),
                                  trend: 1.8,
                                  isLarge: true,
                                  progress: totalListings > 0 ? (totalListings / 700).clamp(0.0, 1.0) : 0,
                                  gradient: const [Color(0xFF833CF6), Color(0xFF6B25D4)],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 16),

                // Pending Approvals Card (reviews pending approval)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int pendingCount = 0;
                    if (snapshot.hasData) {
                      pendingCount = snapshot.data!.docs.length;
                    }

                    return StatsCard(
                      title: 'Pending Approvals',
                      value: Helper.formatNumber(pendingCount),
                      icon: Icons.visibility,
                      color: const Color(0xFF00B4DB),
                      isLarge: true,
                      progress: pendingCount > 0 ? (pendingCount / 200).clamp(0.0, 1.0) : 0,
                      gradient: const [
                        Color(0xFF00B4DB),
                        Color(0xFF0083B0)
                      ],
                    );
                  },
                ),
                const SizedBox(width: 16),

                // Total Reviews Card
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int reviewCount = 0;
                    if (snapshot.hasData) {
                      reviewCount = snapshot.data!.docs.length;
                    }

                    return StatsCard(
                      title: 'Total Reviews',
                      value: Helper.formatNumber(reviewCount),
                      icon: Icons.verified,
                      color: const Color(0xFF00F260),
                      isLarge: true,
                      progress: reviewCount > 0 ? (reviewCount / 500).clamp(0.0, 1.0) : 0,
                      gradient: const [
                        Color(0xFF00F260),
                        Color(0xFF0575E6)
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // RECENT ACTIVITY HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminNotificationsScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // REAL-TIME ACTIVITY STREAM
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activities')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No recent activities yet.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['createdAt'] as Timestamp?;
                  final timeText = timestamp != null
                      ? Helper.formatDateTime(timestamp.toDate())
                      : 'Recently';

                  return _buildActivityItem(
                    context,
                    icon: _getIconForCategory(data['type']),
                    iconColor: _getColorForCategory(data['type']),
                    title: data['title'] ?? 'Activity',
                    subtitle: data['body'] ?? '',
                    time: timeText,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= ICON + COLOR =================

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'auth':
        return Icons.person_add_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'system':
        return Icons.system_update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForCategory(String? category) {
    switch (category) {
      case 'auth':
        return Colors.blue;
      case 'review':
        return Colors.amber;
      case 'system':
        return Colors.blue;
      default:
        return Colors.redAccent;
    }
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
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