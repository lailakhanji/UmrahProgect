class FamilyMemberModel {
  final String bookingId;
  final String name;
  final String passportNumber;
  final String passportExpiryDate;
  final int age;
  final String? gender;
  final String? relationship;

  FamilyMemberModel({
    required this.bookingId,
    required this.name,
    required this.passportNumber,
    required this.passportExpiryDate,
    required this.age,
    this.gender,
    this.relationship,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'name': name,
      'passportNumber': passportNumber,
      'passportExpiryDate': passportExpiryDate,
      'age': age,
      'gender': gender,
      'relationship': relationship,
    };
  }
}