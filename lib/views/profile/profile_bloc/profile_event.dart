part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdatePassportEvent extends ProfileEvent {
  final String passportNumber;
  final DateTime passportExpiryDate;

  UpdatePassportEvent({
    required this.passportNumber,
    required this.passportExpiryDate,
  });
}
class LogoutEvent extends ProfileEvent {}
