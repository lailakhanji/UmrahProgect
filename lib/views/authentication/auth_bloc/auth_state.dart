part of 'auth_bloc.dart';
class AuthState {}
final class AuthInitial extends AuthState{}
final class AuthLoading extends AuthState{}//قيد التنفيذ
final class AuthFailed extends AuthState{
  final String message;

  AuthFailed(this.message);
}//مشكلة
class AuthSuccess extends AuthState{}