class FamilyMemberDetailsModel {
  final String name;
  final int age;
  final String gender;
  final String relationship;

  FamilyMemberDetailsModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.relationship,
  });

  factory FamilyMemberDetailsModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberDetailsModel(
      name: json['name']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
    );
  }
}
