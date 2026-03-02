import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            .collection('notifications') // your notifications collection
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(data['title'] ?? 'No title'),
                  subtitle: Text(data['message'] ?? 'No message'),
                  trailing: Text(
                    data['timestamp'] != null
                        ? (data['timestamp'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString()
                        : '',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}