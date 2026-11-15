import '../data/models/duaa_request_model.dart';

abstract class DuaaRequestState {}

class DuaaRequestInitial extends DuaaRequestState {}

class DuaaRequestLoading extends DuaaRequestState {}

class DuaaRequestLoaded extends DuaaRequestState {
  final List<DuaaRequestModel> requests;

  DuaaRequestLoaded(this.requests);
}

class DuaaRequestCreated extends DuaaRequestState {}

class DuaaRequestError extends DuaaRequestState {
  final String message;

  DuaaRequestError(this.message);
}
