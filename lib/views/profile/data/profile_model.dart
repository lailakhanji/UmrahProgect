class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String phone;
  final String? userCategory;
  final String? passportNumber;
  final DateTime? passportExpiryDate;
  final String? nationality;
  final DateTime? dateOfBirth;
  final String? gender;

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phone,
    this.userCategory,
    this.passportNumber,
    this.passportExpiryDate,
    this.nationality,
    this.dateOfBirth,
    this.gender,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString().trim() ?? '',
      lastName: json['lastName']?.toString().trim() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '',
      userCategory: json['userCategory']?.toString(),
      passportNumber: json['passportNumber']?.toString(),
      passportExpiryDate: json['passportExpiryDate'] != null
          ? DateTime.tryParse(json['passportExpiryDate'].toString())
          : null,
      nationality: json['nationality']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      gender: json['gender']?.toString(),
    );
  }
}
