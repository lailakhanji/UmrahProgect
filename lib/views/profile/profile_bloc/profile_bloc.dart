import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/shared_preferances_service.dart';
import '../data/profile_api_service.dart';
import '../data/profile_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileApiService profileApiService;

  ProfileBloc(this.profileApiService) : super(ProfileInitial()) {
    on<GetProfileEvent>(_getProfile);
    on<UpdatePassportEvent>(_updatePassport);
    on<LogoutEvent>(_onLogout);
  }

  // =========================================================
  // GET PROFILE
  // =========================================================

  Future<void> _getProfile(
      GetProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    print('========================================');
    print('GET PROFILE EVENT START');
    print('========================================');

    emit(ProfileLoading());

    try {
      final userId = SharedPreferancesService.userId;

      print('PROFILE USER ID = $userId');

      if (userId == null || userId.isEmpty) {
        print('PROFILE ERROR: USER ID IS NULL OR EMPTY');

        emit(
          ProfileFailure(
            'لم يتم العثور على معرف المستخدم',
          ),
        );

        return;
      }

      print('CALLING GET PROFILE API...');

      final profile = await profileApiService.getProfile();

      print('========================================');
      print('GET PROFILE SUCCESS');
      print('FIRST NAME = ${profile.firstName}');
      print('LAST NAME = ${profile.lastName}');
      print('PHONE = ${profile.phone}');
      print('EMAIL = ${profile.email}');
      print('PASSPORT = ${profile.passportNumber}');
      print('DATE OF BIRTH = ${profile.dateOfBirth}');
      print('PASSPORT EXPIRY = ${profile.passportExpiryDate}');
      print('========================================');

      emit(
        ProfileLoaded(profile),
      );
    } catch (e, stackTrace) {
      print('========================================');
      print('GET PROFILE ERROR');
      print('ERROR = $e');
      print('STACK TRACE = $stackTrace');
      print('========================================');

      emit(
        ProfileFailure(
          e.toString(),
        ),
      );
    }
  }

  // =========================================================
  // UPDATE PASSPORT
  // =========================================================

  Future<void> _updatePassport(
      UpdatePassportEvent event,
      Emitter<ProfileState> emit,
      ) async {
    print('========================================');
    print('UPDATE PASSPORT START');
    print('========================================');

    emit(ProfileUpdating());

    try {
      print(
        'PASSPORT NUMBER = ${event.passportNumber}',
      );

      print(
        'PASSPORT EXPIRY = ${event.passportExpiryDate}',
      );

      await profileApiService.updatePassport(
        passportNumber: event.passportNumber,
        passportExpiryDate: event.passportExpiryDate,
      );

      print('UPDATE PASSPORT SUCCESS');

      emit(ProfileUpdateSuccess());

      // إعادة تحميل الملف الشخصي
      add(
        GetProfileEvent(),
      );
    } catch (e, stackTrace) {
      print('========================================');
      print('UPDATE PASSPORT ERROR');
      print('ERROR = $e');
      print('STACK TRACE = $stackTrace');
      print('========================================');

      emit(
        ProfileFailure(
          e.toString(),
        ),
      );
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<ProfileState> emit,
      ) async {
    print('========================================');
    print('LOGOUT START');
    print('========================================');

    try {
      SharedPreferancesService.token = null;
      SharedPreferancesService.userId = null;
      SharedPreferancesService.name = '';

      print('LOGOUT SUCCESS');

      emit(
        ProfileLogoutSuccess(),
      );
    } catch (e, stackTrace) {
      print('========================================');
      print('LOGOUT ERROR');
      print('ERROR = $e');
      print('STACK TRACE = $stackTrace');
      print('========================================');

      emit(
        ProfileFailure(
          e.toString(),
        ),
      );
    }
  }
}