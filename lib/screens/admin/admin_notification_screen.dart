import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/helpers.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities') 
            .orderBy('createdAt', descending: true)
            .snapshots(), 
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final timestamp = data['createdAt'] as Timestamp?;

              final timeText = timestamp != null
                  ? Helper.formatDateTime(timestamp.toDate())
                  : 'Recently';

              return _buildNotificationItem(
                icon: _getIconForCategory(data['type']),
                iconColor: _getColorForCategory(data['type']),
                title: data['title'] ?? 'Activity',
                subtitle: data['body'] ?? '',
                time: timeText,
              );
            },
          );
        },
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
        return Colors.blue;
      case 'review':
        return Colors.amber;
      case 'system':
        return Colors.blue;
      default:
        return Colors.redAccent;
    }
  }

  Widget _buildNotificationItem({
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