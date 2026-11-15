import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/duaa_request_api_service.dart';
import '../data/models/duaa_request_model.dart';
import 'duaa_request_event.dart';
import 'duaa_request_state.dart';

class DuaaRequestBloc extends Bloc<DuaaRequestEvent, DuaaRequestState> {
  DuaaRequestBloc() : super(DuaaRequestInitial()) {
    on<GetDuaaRequests>(_getDuaaRequests);

    on<CreateDuaaRequest>(_createDuaaRequest);

    on<MarkDuaaRequestAsCompleted>(_markAsCompleted);
  }

  // =========================
  // GET
  // =========================

  Future<void> _getDuaaRequests(
    GetDuaaRequests event,
    Emitter<DuaaRequestState> emit,
  ) async {
    emit(DuaaRequestLoading());

    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        emit(DuaaRequestError('لم يتم العثور على المستخدم'));
        return;
      }

      final result = await DuaaRequestApi.getDuaaRequests(userId);

      emit(DuaaRequestLoaded(result));
    } catch (e) {
      print('Get Duaa Requests Error: $e');

      emit(DuaaRequestError('حدث خطأ أثناء جلب الملاحظات'));
    }
  }

  // =========================
  // CREATE
  // =========================
  Future<void> _createDuaaRequest(
    CreateDuaaRequest event,
    Emitter<DuaaRequestState> emit,
  ) async {
    emit(DuaaRequestLoading());

    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        emit(DuaaRequestError('لم يتم العثور على المستخدم'));
        return;
      }

      final request = DuaaRequestModel(
        userId: userId,
        personName: event.request.personName,
        message: event.request.message,
        type: event.request.type,
        isCompleted: false,
      );

      await DuaaRequestApi.createDuaaRequest(request);

      emit(DuaaRequestCreated());

      add(GetDuaaRequests());
    } catch (e) {
      print('Create Duaa Request Error: $e');

      emit(DuaaRequestError('حدث خطأ أثناء حفظ الملاحظة'));
    }
  }

  // =========================
  // MARK AS COMPLETED
  // =========================

  Future<void> _markAsCompleted(
    MarkDuaaRequestAsCompleted event,
    Emitter<DuaaRequestState> emit,
  ) async {
    try {
      await DuaaRequestApi.markAsCompleted(event.id);

      // إعادة تحميل القائمة
      add(GetDuaaRequests());
    } catch (e) {
      print('Mark As Completed Error: $e');

      emit(DuaaRequestError('حدث خطأ أثناء تحديث الملاحظة'));
    }
  }
}
