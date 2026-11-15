class ReviewModel {
  final String tripId;
  final String userId;
  final int rating;
  final String comment;

  ReviewModel({
    required this.tripId,
    required this.userId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
    };
  }
}