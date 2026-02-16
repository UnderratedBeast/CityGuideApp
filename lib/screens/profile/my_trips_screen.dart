import 'package:flutter/material.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example trip list – in a real app this would come from a provider
    final trips = [
      {'title': 'Summer in Tokyo', 'details': 'July 2024 • 12 Sights'},
      {'title': 'Paris Weekend', 'details': 'May 2024 • 5 Days'},
      {'title': 'Barcelona Getaway', 'details': 'March 2024 • 8 Sights'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (ctx, index) {
          final trip = trips[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.purple.shade100,
                child: const Icon(Icons.photo_camera, color: Colors.purple),
              ),
              title: Text(trip['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(trip['details']!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to trip detail screen (future)
              },
            ),
          );
        },
      ),
    );
  }
}