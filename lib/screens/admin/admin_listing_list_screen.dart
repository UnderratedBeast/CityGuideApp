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

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'admin_listings_form_screen.dart';

// class AdminListingListScreen extends StatefulWidget {
//   final String cityId;
//   final String collectionName;

//   const AdminListingListScreen({
//     super.key,
//     required this.cityId,
//     required this.collectionName,
//   });

//   @override
//   State<AdminListingListScreen> createState() => _AdminListingListScreenState();
// }

// class _AdminListingListScreenState extends State<AdminListingListScreen> {
//   late final CollectionReference listingsRef;

//   @override
//   void initState() {
//     super.initState();
//     listingsRef = FirebaseFirestore.instance
//     .collection('cities')
//     .doc(widget.cityId)
//     .collection(widget.collectionName);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.collectionName[0].toUpperCase() +
//               widget.collectionName.substring(1),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: listingsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No listings found'));
//           }

//           final listings = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: listings.length,
//             itemBuilder: (context, index) {
//               final doc = listings[index];
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
//                               builder: (_) => AdminListingFormScreen(
//   cityId: widget.cityId,
//   collectionName: widget.collectionName,
//   listingId: doc.id,
//   existingData: data,
// ),
//                             ),
//                           );
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () async {
//                           final confirm = await showDialog<bool>(
//                             context: context,
//                             builder: (ctx) => AlertDialog(
//                               title: const Text('Confirm Delete'),
//                               content: const Text(
//                                   'Are you sure you want to delete this listing?'),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(ctx, false),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(ctx, true),
//                                   child: const Text('Delete'),
//                                 ),
//                               ],
//                             ),
//                           );

//                           if (confirm == true) {
//                             await listingsRef.doc(doc.id).delete();
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Listing deleted')),
//                             );
//                           }
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
//             MaterialPageRoute(
//               builder: (_) => AdminListingFormScreen(
//                 cityId: widget.cityId,
//                 collectionName: widget.collectionName,
//               ),
//             ),
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

class AdminListingTabbedScreen extends StatefulWidget {
  final String cityId;

  const AdminListingTabbedScreen({super.key, required this.cityId});

  @override
  State<AdminListingTabbedScreen> createState() =>
      _AdminListingTabbedScreenState();
}

class _AdminListingTabbedScreenState
    extends State<AdminListingTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = [
    'attractions',
    'events',
    'dining',
    'hotels'
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: categories.length, vsync: this);
  }

  Future<void> _deleteListing(
      String collectionName, String listingId) async {
    final subCollection = FirebaseFirestore.instance
        .collection('cities')
        .doc(widget.cityId)
        .collection(collectionName);

    try {
      await subCollection.doc(listingId).delete();

      // Optional: delete related notifications
      final notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('listingId', isEqualTo: listingId)
          .get();

      for (var doc in notifications.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _confirmDelete(String collectionName, String listingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text(
            'Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteListing(collectionName, listingId);
    }
  }

  Widget _buildListingList(String collectionName) {
    final subCollection = FirebaseFirestore.instance
        .collection('cities')
        .doc(widget.cityId)
        .collection(collectionName);

    return StreamBuilder<QuerySnapshot>(
      stream: subCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No listings found'));
        }

        final listings = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final doc = listings[index];
            final data = doc.data() as Map<String, dynamic>;

            // Get imageUrl or fallback to first image in extraImages list
            String? imageUrl = data['imageUrl'];
            if ((imageUrl == null || imageUrl.isEmpty) &&
                data['extraImages'] != null) {
              final extraImages = List.from(data['extraImages']);
              if (extraImages.isNotEmpty) imageUrl = extraImages[0];
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    // IMAGE AND TEXT ROW (50/50)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          // 50% IMAGE
                          Expanded(
                            flex: 1,
                            child: imageUrl != null &&
                                    imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          size: 40),
                                    ),
                                  )
                                : Container(
                                    color: Colors.blue[50],
                                    child: const Icon(Icons.image,
                                        size: 40, color: Colors.blue),
                                  ),
                          ),
                          // 50% TEXT
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    data['name'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['details'] ??
                                        data['description'] ??
                                        '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // BUTTONS ROW (50/50)
                    Row(
                      children: [
                        // EDIT BUTTON
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminListingFormScreen(
                                    cityId: widget.cityId,
                                    collectionName: collectionName,
                                    listingId: doc.id,
                                    existingData: data,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: Colors.grey[200]!),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit,
                                      size: 18, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // DELETE BUTTON
                        Expanded(
                          child: InkWell(
                            onTap: () => _confirmDelete(
                                collectionName, doc.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Listings - ${widget.cityId}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: categories
              .map((e) =>
                  Tab(text: e[0].toUpperCase() + e.substring(1)))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            categories.map((c) => _buildListingList(c)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentCategory = categories[_tabController.index];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminListingFormScreen(
                cityId: widget.cityId,
                collectionName: currentCategory,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
