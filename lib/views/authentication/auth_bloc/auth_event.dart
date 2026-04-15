part of 'auth_bloc.dart';
 abstract class AuthEvent {

}
class LoginEvent extends AuthEvent{
final String email;
final String password;

  LoginEvent(this.email, this.password);
}
class RegisterEvent extends AuthEvent{
final String email;
final String password;
final String confirmPassword;
final String number;
final String firstname;
final String lastname;

  RegisterEvent(this.email, this.password, this.confirmPassword, this.number, this.firstname, this.lastname);
}