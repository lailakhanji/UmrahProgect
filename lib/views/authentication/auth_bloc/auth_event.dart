part of 'auth_bloc.dart';

abstract class AuthEvent {}

// =========================================================
// LOGIN
// =========================================================

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}

// =========================================================
// REGISTER
// =========================================================

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;

  final String firstName;
  final String lastName;
  final String phone;

  final String passportNumber;
  final String passportExpiryDate;
  final String dateOfBirth;

  RegisterEvent({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.passportNumber,
    required this.passportExpiryDate,
    required this.dateOfBirth,
  });
}

// =========================================================
// CLEAR ERROR
// =========================================================

class ClearAuthErrorEvent extends AuthEvent {}
