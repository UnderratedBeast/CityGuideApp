enum ReviewStatus { pending, approved, rejected }

class Review {
  final String id;
  final String attractionId;
  final String attractionName;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final DateTime date;
  final ReviewStatus status;

  const Review({
    required this.id,
    required this.attractionId,
    required this.attractionName,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.date,
    this.status = ReviewStatus.pending,
  });

  Review copyWith({
    String? id,
    String? attractionId,
    String? attractionName,
    String? userId,
    String? userName,
    String? userImageUrl,
    double? rating,
    String? comment,
    DateTime? date,
    ReviewStatus? status,
  }) {
    return Review(
      id: id ?? this.id,
      attractionId: attractionId ?? this.attractionId,
      attractionName: attractionName ?? this.attractionName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
