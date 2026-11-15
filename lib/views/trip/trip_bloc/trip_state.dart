part of 'trip_bloc.dart';


 class TripState {}

final class TripInitial extends TripState {}
class InitTripState extends TripState{}
class LoadingTripState extends TripState{}
class FailedTripState extends TripState{
  final String errorMessage;

  FailedTripState({required this.errorMessage});
}
class SuccessTripState extends TripState{
  final List<TripModel> trips;

  SuccessTripState({required this.trips});
}

