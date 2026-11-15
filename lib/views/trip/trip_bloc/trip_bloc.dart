import 'package:bloc/bloc.dart';
import '../data/trip_api_service.dart';
import '../data/trip_model.dart';

part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripApiService tripApiService;

  TripBloc(this.tripApiService) : super(InitTripState()) {
    on<GetTripsEvent>(getTrips);
  }

  Future<void> getTrips(
      GetTripsEvent event,
      Emitter<TripState> emit,
      ) async {
    emit(LoadingTripState());

    final result = await tripApiService.getTrip();

    result.fold(
          (error) {
        emit(
          FailedTripState(
            errorMessage: error,
          ),
        );
      },
          (trips) {
        emit(
          SuccessTripState(
            trips: trips,
          ),
        );
      },
    );
  }
}