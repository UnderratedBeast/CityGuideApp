import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_attraction_form_screen.dart';

class AdminAttractionListScreen extends StatefulWidget {
  const AdminAttractionListScreen({super.key});

  @override
  State<AdminAttractionListScreen> createState() => _AdminAttractionListScreenState();
}

class _AdminAttractionListScreenState extends State<AdminAttractionListScreen> {
  final CollectionReference attractionsRef = FirebaseFirestore.instance.collection('attractions');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: attractionsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No attractions found'));
          }

          final attractions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: attractions.length,
            itemBuilder: (context, index) {
              final doc = attractions[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Text(data['city'] ?? 'Unknown City'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminAttractionFormScreen(attractionId: doc.id, existingData: data),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await attractionsRef.doc(doc.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attraction deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAttractionFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
