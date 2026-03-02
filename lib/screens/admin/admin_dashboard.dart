import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/navigation/admin_stats_card.dart';
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

          // REAL-TIME ACTIVITY STREAM
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activities')
                .orderBy('createdAt', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
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
        return Colors.deepPurple;
      case 'review':
        return Colors.amber;
      case 'system':
        return Colors.blue;
      default:
        return Colors.grey;
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

