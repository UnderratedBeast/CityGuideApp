import 'dart:ui';
import 'package:city_guide_app/screens/admin/admin_listings_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_listings_form_screen.dart'; // Changed from 'admin_listings_form_screen.dart' to 'admin_listing_form_screen.dart'

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

  // ================= DELETE =================

  Future<void> _deleteListing(
      String collectionName, String listingId) async {
    final subCollection = FirebaseFirestore.instance
        .collection('cities')
        .doc(widget.cityId)
        .collection(collectionName);

    try {
      await subCollection.doc(listingId).delete();

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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

  // ================= MODERN GLASS CARD =================

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blue.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ================= LIST =================

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
          return const Center(
              child: CircularProgressIndicator(color: Colors.blue));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No listings found'));
        }

        final listings = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final doc = listings[index];
            final data = doc.data() as Map<String, dynamic>;

            String? imageUrl = data['imageUrl'];
            if ((imageUrl == null || imageUrl.isEmpty) &&
                data['extraImages'] != null) {
              final extraImages = List.from(data['extraImages']);
              if (extraImages.isNotEmpty) imageUrl = extraImages[0];
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: _glassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: imageUrl != null && imageUrl.isNotEmpty
    ? ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20)),
        child: Image.network(
          imageUrl,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 140,
              color: Colors.grey.withOpacity(0.08),
              child: const Icon(
                Icons.broken_image,
                size: 40,
                color: Colors.grey,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 140,
              color: Colors.blue.withOpacity(0.08),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      )
    : Container(
        height: 140,
        color: Colors.blue.withOpacity(0.08),
        child: const Icon(
          Icons.image,
          size: 40,
          color: Colors.blue,
        ),
      ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['details'] ??
                                      data['description'] ??
                                      '',
                                  style: TextStyle(
                                    color:
                                        Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 3,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminListingFormScreen(
                                    cityId: widget.cityId,
                                    collectionName:
                                        collectionName,
                                    listingId: doc.id,
                                    existingData: data,
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                      vertical: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight:
                                            FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _confirmDelete(
                                collectionName, doc.id),
                            child: const Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                      vertical: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight:
                                            FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= BUILD =================

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,

    body: Column(
      children: [
        TabBar(
          controller: _tabController,
          // isScrollable: true, // makes "Attractions" fully visible
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: categories
              .map((e) =>
                  Tab(text: e[0].toUpperCase() + e.substring(1)))
              .toList(),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:
                categories.map((c) => _buildListingList(c)).toList(),
          ),
        ),
      ],
    ),

    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
      onPressed: () {
        final currentCategory =
            categories[_tabController.index];

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
    ),
  );
}
    }