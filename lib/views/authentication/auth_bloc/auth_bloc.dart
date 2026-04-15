import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:umrahapp/services/api_service.dart";

import "../../../services/shared_preferances_service.dart";

part 'auth_event.dart';
part 'auth_state.dart';
    class AuthBloc extends Bloc<AuthEvent,AuthState>{
      AuthBloc():super(AuthInitial()){
 on<AuthEvent>((event,emit){});
 on<LoginEvent>(_onLoaginEvent);
 on<RegisterEvent>(_onRegisterEvent);
}
    
  FutureOr<void> _onLoaginEvent(LoginEvent event, Emitter<AuthState> emit) async{
        emit(AuthLoading());
        await ApiService.postMethod(endPoint:'Auth/login',body: {
          'email':event.email,
          'password':event.password,
        }).then((response){
          SharedPreferancesService.token=response.data['token'];

          emit(AuthSuccess());
        }).catchError((error){
          debugPrint(error.toString());
          emit(AuthFailed(error.toString()));
        }).onError((error,stackTrace){
          debugPrint(error.toString());
          debugPrint(stackTrace.toString());
          emit(AuthFailed(error.toString()));
        });
  }

  FutureOr<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit)async {
    emit(AuthLoading());
    await ApiService.postMethod(endPoint:'Auth/register',body: {
      'email':event.email,
      'password':event.password,
      'firstName':event.firstname,
      'lastName':event.lastname,
      'phone':event.number,

    }).then((response){
      SharedPreferancesService.token=response.data['token'];
      SharedPreferancesService.name = response.data['firstName'];
      emit(AuthSuccess());
    }).catchError((error){
      debugPrint(error.response.toString());
      emit(AuthFailed(error.toString()));
    }).onError((error,stackTrace){
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      emit(AuthFailed(error.toString()));
    });
  }
}