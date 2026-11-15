part of 'auth_bloc.dart';

abstract class AuthState {}

// =========================================================
// INITIAL
// =========================================================

final class AuthInitial extends AuthState {}

// =========================================================
// LOADING
// =========================================================

final class AuthLoading extends AuthState {}

// =========================================================
// SUCCESS
// =========================================================

final class AuthSuccess extends AuthState {}

// =========================================================
// FAILED
// =========================================================

final class AuthFailed extends AuthState {
  final String? message;

  AuthFailed({this.message});
}
