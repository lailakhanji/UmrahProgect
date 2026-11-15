part of 'transport_bloc.dart';

class TransportState {}

final class TransportInitial extends TransportState {}

class InitTransportState extends TransportState{}
class LoadingTransportState extends TransportState{}
class FailedTransportState extends TransportState{
  final String errorMessage;

  FailedTransportState({required this.errorMessage});
}
class SuccessTransportState extends TransportState{
  final List<TransportModel> Transports;

  SuccessTransportState({required this.Transports});
}