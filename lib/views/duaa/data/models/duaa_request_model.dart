class DuaaRequestModel {
  final String? id;
  final String? userId;
  final String personName;
  final String message;
  final String type;
  final bool isCompleted;
  final DateTime? createdAt;

  DuaaRequestModel({
    this.id,
    this.userId,
    required this.personName,
    required this.message,
    required this.type,
    this.isCompleted = false,
    this.createdAt,
  });

  factory DuaaRequestModel.fromJson(Map<String, dynamic> json) {
    return DuaaRequestModel(
      id: json['id'],
      userId: json['userId'],
      personName: json['personName'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'personName': personName,
      'message': message,
      'type': type,
    };
  }
}