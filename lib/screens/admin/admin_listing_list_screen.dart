// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'admin_listings_form_screen.dart';

// class AdminAttractionListScreen extends StatefulWidget {
//   const AdminAttractionListScreen({super.key});

//   @override
//   State<AdminAttractionListScreen> createState() => _AdminAttractionListScreenState();
// }

// class _AdminAttractionListScreenState extends State<AdminAttractionListScreen> {
//   final CollectionReference attractionsRef = FirebaseFirestore.instance.collection('attractions');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<QuerySnapshot>(
//         stream: attractionsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No attractions found'));
//           }

//           final attractions = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: attractions.length,
//             itemBuilder: (context, index) {
//               final doc = attractions[index];
//               final data = doc.data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.all(12),
//                 child: ListTile(
//                   title: Text(data['name'] ?? 'No Name'),
//                   subtitle: Text(data['city'] ?? 'Unknown City'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.blue),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => AdminAttractionListScreen(attractionId: doc.id, existingData: data),
//                             ),
//                           );
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () async {
//                           await attractionsRef.doc(doc.id).delete();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Attraction deleted')),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AdminAttractionListScreen()),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_listings_form_screen.dart';

class AdminListingListScreen extends StatefulWidget {
  final String collectionName; // attractions, hotels, dining, events

  const AdminListingListScreen({super.key, required this.collectionName});

  @override
  State<AdminListingListScreen> createState() => _AdminListingListScreenState();
}

class _AdminListingListScreenState extends State<AdminListingListScreen> {
  late final CollectionReference listingsRef;

  @override
  void initState() {
    super.initState();
    listingsRef = FirebaseFirestore.instance.collection(widget.collectionName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collectionName[0].toUpperCase() +
              widget.collectionName.substring(1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No listings found'));
          }

          final listings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final doc = listings[index];
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
                              builder: (_) => AdminListingFormScreen(
                                collectionName: widget.collectionName,
                                listingId: doc.id,
                                existingData: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this listing?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await listingsRef.doc(doc.id).delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Listing deleted')),
                            );
                          }
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
            MaterialPageRoute(
              builder: (_) => AdminListingFormScreen(
                collectionName: widget.collectionName,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
