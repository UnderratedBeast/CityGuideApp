// import 'package:flutter/material.dart';
// import '../../models/admin_review_model.dart';

// class ReviewListScreen extends StatefulWidget {
//   const ReviewListScreen({super.key});

//   @override
//   State<ReviewListScreen> createState() => _ReviewListScreenState();
// }

// class _ReviewListScreenState extends State<ReviewListScreen> {
//   // Mock data
//   final List<Review> _reviews = [
//     Review(
//       id: '1',
//       attractionId: '1',
//       attractionName: 'Central Park',
//       userId: 'u1',
//       userName: 'Alice Johnson',
//       rating: 5,
//       comment: 'Absolutely beautiful! A must-visit.',
//       date: DateTime.now().subtract(const Duration(hours: 2)),
//       status: ReviewStatus.pending,
//     ),
//     Review(
//       id: '2',
//       attractionId: '2',
//       attractionName: 'The local Museum',
//       userId: 'u2',
//       userName: 'Bob Smith',
//       rating: 3,
//       comment: 'It was okay, but a bit crowded.',
//       date: DateTime.now().subtract(const Duration(days: 1)),
//       status: ReviewStatus.pending,
//     ),
//     Review(
//       id: '3',
//       attractionId: '3',
//       attractionName: 'Skyline Observatory',
//       userId: 'u3',
//       userName: 'Charlie Brown',
//       rating: 1,
//       comment: 'Too expensive for what it is.',
//       date: DateTime.now().subtract(const Duration(days: 2)),
//       status: ReviewStatus.pending,
//     ),
//   ];

//   void _updateStatus(String id, ReviewStatus newStatus) {
//     setState(() {
//       final index = _reviews.indexWhere((r) => r.id == id);
//       if (index != -1) {
//         // In a real app, you would make an API call here
//         // For now, we'll just remove it from the pending list or update it
//         // Depending on requirements, we might want to keep showing it but with new status
//         // Let's assume this list shows PENDING reviews primarily for moderation
//         _reviews[index] = _reviews[index].copyWith(status: newStatus);

//         // Show snackbar
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Review ${newStatus.name}'),
//             duration: const Duration(seconds: 2),
//             action: SnackBarAction(
//               label: 'UNDO',
//               onPressed: () {
//                 // TODO: Implement undo
//               },
//             ),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Filter to show only pending reviews for moderation focus
//     final pendingReviews = _reviews
//         .where((r) => r.status == ReviewStatus.pending)
//         .toList();

//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Review Moderation',
//                 style: Theme.of(context).textTheme.headlineSmall
//                     ?.copyWith(fontWeight: FontWeight.bold),
//               ),
//               Chip(
//                 label: Text('${pendingReviews.length} Pending'),
//                 backgroundColor: const Color(
//                   0xFF6200EE,
//                 ).withValues(alpha: 0.1),
//                 labelStyle: const TextStyle(
//                   color: Color(0xFF6200EE),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           Expanded(
//             child: pendingReviews.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.check_circle_outline,
//                           size: 64,
//                           color: Colors.green[300],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'All caught up!',
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleLarge
//                               ?.copyWith(color: Colors.grey[600]),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text('No pending reviews to moderate.'),
//                       ],
//                     ),
//                   )
//                 : Card(
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: BorderSide(color: Colors.grey[200]!),
//                     ),
//                     child: ListView.separated(
//                       itemCount: pendingReviews.length,
//                       separatorBuilder: (context, index) =>
//                           const Divider(height: 1),
//                       itemBuilder: (context, index) {
//                         final review = pendingReviews[index];
//                         return Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       CircleAvatar(
//                                         backgroundColor:
//                                             Colors.grey[200],
//                                         child: Text(
//                                           review.userName[0]
//                                               .toUpperCase(),
//                                           style: TextStyle(
//                                             color: Colors.grey[700],
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             review.userName,
//                                             style: const TextStyle(
//                                               fontWeight:
//                                                   FontWeight.bold,
//                                             ),
//                                           ),
//                                           Text(
//                                             'on ${review.attractionName}',
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodySmall
//                                                 ?.copyWith(
//                                                   color: Colors
//                                                       .grey[600],
//                                                 ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     '${review.date.day}/${review.date.month}',
//                                     style: Theme.of(
//                                       context,
//                                     ).textTheme.bodySmall,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Row(
//                                 children: List.generate(
//                                   5,
//                                   (index) => Icon(
//                                     index < review.rating
//                                         ? Icons.star
//                                         : Icons.star_border,
//                                     size: 16,
//                                     color: Colors.amber,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(review.comment),
//                               const SizedBox(height: 16),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.end,
//                                 children: [
//                                   OutlinedButton.icon(
//                                     onPressed: () => _updateStatus(
//                                       review.id,
//                                       ReviewStatus.rejected,
//                                     ),
//                                     icon: const Icon(
//                                       Icons.close,
//                                       size: 18,
//                                     ),
//                                     label: const Text('Reject'),
//                                     style: OutlinedButton.styleFrom(
//                                       foregroundColor: Colors.red,
//                                       side: const BorderSide(
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   ElevatedButton.icon(
//                                     onPressed: () => _updateStatus(
//                                       review.id,
//                                       ReviewStatus.approved,
//                                     ),
//                                     icon: const Icon(
//                                       Icons.check,
//                                       size: 18,
//                                     ),
//                                     label: const Text('Approve'),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.green,
//                                       foregroundColor: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  final CollectionReference reviewsRef = FirebaseFirestore.instance.collection('reviews');

  Future<void> _updateStatus(String id, String status) async {
    await reviewsRef.doc(id).update({'status': status});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review marked as $status')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: reviewsRef.where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending reviews'));
        }

        final reviews = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final doc = reviews[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(data['userName'] ?? 'Anonymous'),
                subtitle: Text('${data['comment'] ?? ''}\non ${data['attractionName'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateStatus(doc.id, 'rejected'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateStatus(doc.id, 'approved'),
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
}
