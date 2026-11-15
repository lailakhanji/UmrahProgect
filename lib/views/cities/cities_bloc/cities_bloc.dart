import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/cities_api_service.dart';
import '../data/cities_model.dart';

part 'cities_event.dart';

part 'cities_state.dart';

class CitiesBloc extends Bloc<CitiesEvent, CitiesState> {
  final CitiesApiService api;

  CitiesBloc(this.api) : super(CitiesInitial()) {
    on<GetCitiesEvent>((event, emit) async {
      emit(CitiesLoading());

      try {
        final cities = await api.getCities();

        emit(CitiesSuccess(cities));
      } catch (e) {
        emit(CitiesFailed(e.toString()));
      }
    });
  }
}
