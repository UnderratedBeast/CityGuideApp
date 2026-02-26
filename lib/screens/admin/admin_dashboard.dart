// import 'package:flutter/material.dart';
// import '../../widgets/navigation/admin_stats_card.dart';

// class DashboardHome extends StatelessWidget {
//   const DashboardHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
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
//                   title: 'Active Attractions',
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
//                   title: 'Page Views',
//                   value: '48.2k',
//                   icon: Icons.visibility,
//                   color: Colors.blue.shade100,
//                 ),
//                 const SizedBox(width: 16),
//                 StatsCard(
//                   title: 'Verifications',
//                   value: '124',
//                   icon: Icons.verified,
//                   color: Colors.green.shade100,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 40),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'RECENT ACTIVITY',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text('View All'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildActivityItem(
//             context,
//             icon: Icons.add_location_alt_rounded,
//             iconColor: Colors.blue,
//             title: 'New attraction added',
//             subtitle:
//                 'Skyline Observatory was added by @alex_travels',
//             time: '2 mins ago',
//           ),
//           _buildActivityItem(
//             context,
//             icon: Icons.report_problem_rounded,
//             iconColor: Colors.red,
//             title: 'Reported review resolved',
//             subtitle:
//                 "Flagged review on 'Central Park' has been manually hidden",
//             time: '1 hour ago',
//           ),
//           _buildActivityItem(
//             context,
//             icon: Icons.system_update_rounded,
//             iconColor: Colors.orange,
//             title: 'System update: v2.4',
//             subtitle:
//                 'Core engine successfully updated to the latest stable build',
//             time: '4 hours ago',
//           ),
//           _buildActivityItem(
//             context,
//             icon: Icons.person_add_rounded,
//             iconColor: Colors.deepPurple,
//             title: 'New Editor Role',
//             subtitle:
//                 '@maria_design has been promoted to City Editor',
//             time: 'Yesterday',
//           ),
//         ],
//       ),
//     );
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
//             color: Colors.black.withValues(alpha: 0.02),
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
//               color: iconColor.withValues(alpha: 0.1),
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
import '../../widgets/navigation/admin_stats_card.dart';
import '../../utils/theme.dart';

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

          // STATS CARDS - HORIZONTAL SCROLL
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                const StatsCard(
                  title: 'Total Users',
                  value: '12,548',
                  icon: Icons.people,
                  color: Color(0xFF2E5BFF),
                  trend: 5.2,
                  isLarge: true,
                  progress: 0.65,
                  gradient: [Color(0xFF2E5BFF), Color(0xFF1637C5)],
                ),
                const SizedBox(width: 16),
                const StatsCard(
                  title: 'Active Attractions',
                  value: '1,420',
                  icon: Icons.place,
                  color: Color(0xFF833CF6),
                  trend: 1.8,
                  isLarge: true,
                  progress: 0.45,
                  gradient: [Color(0xFF833CF6), Color(0xFF6B25D4)],
                ),
                const SizedBox(width: 16),
                StatsCard(
                  title: 'Page Views',
                  value: '48.2k',
                  icon: Icons.visibility,
                  color: const Color(0xFF00B4DB),
                  isLarge: true,
                  progress: 0.8,
                  gradient: const [
                    Color(0xFF00B4DB),
                    Color(0xFF0083B0)
                  ],
                ),
                const SizedBox(width: 16),
                StatsCard(
                  title: 'Verifications',
                  value: '124',
                  icon: Icons.verified,
                  color: const Color(0xFF00F260),
                  isLarge: true,
                  progress: 0.3,
                  gradient: const [
                    Color(0xFF00F260),
                    Color(0xFF0575E6)
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // RECENT ACTIVITY HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT ACTIVITY',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ACTIVITY ITEMS
          _buildActivityItem(
            context,
            icon: Icons.add_location_alt_rounded,
            iconColor: Colors.blue,
            title: 'New attraction added',
            subtitle:
                'Skyline Observatory was added by @alex_travels',
            time: '2 mins ago',
          ),
          _buildActivityItem(
            context,
            icon: Icons.report_problem_rounded,
            iconColor: Colors.red,
            title: 'Reported review resolved',
            subtitle:
                "Flagged review on 'Central Park' has been manually hidden",
            time: '1 hour ago',
          ),
          _buildActivityItem(
            context,
            icon: Icons.system_update_rounded,
            iconColor: Colors.orange,
            title: 'System update: v2.4',
            subtitle:
                'Core engine successfully updated to the latest stable build',
            time: '4 hours ago',
          ),
          _buildActivityItem(
            context,
            icon: Icons.person_add_rounded,
            iconColor: AppTheme.primaryBlue,
            title: 'New Editor Role',
            subtitle:
                '@maria_design has been promoted to City Editor',
            time: 'Yesterday',
          ),
        ],
      ),
    );
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
