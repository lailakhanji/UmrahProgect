part of 'cities_bloc.dart';

class CitiesState {}

final class CitiesInitial extends CitiesState {}

class CitiesLoading extends CitiesState {}

class CitiesSuccess extends CitiesState {
  final List<CitiesModel> cities;

  CitiesSuccess(this.cities);
}

class CitiesFailed extends CitiesState {
  final String message;

  CitiesFailed(this.message);
}
