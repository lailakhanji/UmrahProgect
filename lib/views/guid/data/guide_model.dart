class GuideModel {
  final String id;
  final String title;
  final String description;
  final String? audioUrl;
  final String? imageUrl;
  final String category;
  final bool isForWomenOnly;
  final int orderIndex;

  GuideModel({
    required this.id,
    required this.title,
    required this.description,
    this.audioUrl,
    this.imageUrl,
    required this.category,
    required this.isForWomenOnly,
    required this.orderIndex,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      category: json['category'] ?? '',
      isForWomenOnly: json['isForWomenOnly'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}
