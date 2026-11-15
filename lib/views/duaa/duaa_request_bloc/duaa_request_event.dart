import '../data/models/duaa_request_model.dart';

abstract class DuaaRequestEvent {}

class GetDuaaRequests extends DuaaRequestEvent {}

class CreateDuaaRequest extends DuaaRequestEvent {
  final DuaaRequestModel request;

  CreateDuaaRequest(this.request);
}

class MarkDuaaRequestAsCompleted extends DuaaRequestEvent {
  final String id;

  MarkDuaaRequestAsCompleted(this.id);
}
