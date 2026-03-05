import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/review_service.dart';
import '../../models/review_model.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen>
    with SingleTickerProviderStateMixin {
  final ReviewService _reviewService = ReviewService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ================= GLASS CONTAINER =================

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(24),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Review Moderation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewStream('pending'),
          _buildReviewStream('approved'),
          _buildReviewStream('rejected'),
        ],
      ),
    );
  }

  Widget _buildReviewStream(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }

        final reviews = snapshot.data!.docs;

        if (reviews.isEmpty) {
          return Center(
            child: Text(
              'No ${status.toUpperCase()} reviews',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = ReviewModel.fromMap(
              reviews[index].id,
              reviews[index].data() as Map<String, dynamic>,
            );
            return _buildReviewCard(review, status);
          },
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewModel review, String status) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _reviewService.getListingDetails(
        cityId: review.cityId,
        listingId: review.listingId,
        listingType: review.listingType,
      ),
      builder: (context, snapshot) {
        final listingName =
            snapshot.data?['name'] ?? 'Unknown Listing';

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: _glassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // ===== Header =====

                  Row(
                    children: [
                      _buildStatusChip(status),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          listingName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== User Info =====

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            Colors.blue.withOpacity(0.1),
                        child: Text(
                          review.userName[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600),
                            ),
                            Text(
                              _formatDate(
                                  review.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children:
                            List.generate(5, (i) {
                          return Icon(
                            i < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== Review Text =====

                  Container(
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue
                          .withOpacity(0.04),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Text(
                      review.reviewText,
                      style: const TextStyle(
                          height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== Actions =====

                  if (status == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed: () =>
                                _approveReview(
                                    review),
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                                  Colors.blue,
                              foregroundColor:
                                  Colors.white,
                            ),
                            child:
                                const Text('Approve'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                              OutlinedButton(
                            onPressed: () =>
                                _rejectReview(
                                    review.id!),
                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  Colors.red,
                              side: const BorderSide(
                                  color:
                                      Colors.red),
                            ),
                            child:
                                const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;

    if (status == 'pending') {
      bg = Colors.blue.withOpacity(0.1);
      text = Colors.blue;
    } else if (status == 'approved') {
      bg = Colors.blue.withOpacity(0.1);
      text = Colors.blue;
    } else {
      bg = Colors.red.withOpacity(0.1);
      text = Colors.red;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
              horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _approveReview(
      ReviewModel review) async {
    await _reviewService.approveReview(
      review.id!,
      review.rating,
      cityId: review.cityId,
      listingId: review.listingId,
      listingType: review.listingType,
    );
  }

  Future<void> _rejectReview(
      String reviewId) async {
    await _reviewService.rejectReview(
        reviewId);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    final diff =
        DateTime.now().difference(date);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7)
      return '${diff.inDays} days ago';
    if (diff.inDays < 30)
      return '${diff.inDays ~/ 7} weeks ago';
    if (diff.inDays < 365)
      return '${diff.inDays ~/ 30} months ago';
    return '${diff.inDays ~/ 365} years ago';
  }
}
