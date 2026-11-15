import 'package:bloc/bloc.dart';

import '../data/transport_api_service.dart';
import '../data/transport_model.dart';


part 'transport_event.dart';
part 'transport_state.dart';

class TransportBloc extends Bloc<TransportEvent, TransportState> {
  final TransportApiService transportApiService;

  TransportBloc(this.transportApiService) : super(InitTransportState()) {
    on<GetTransportsEvent>(getTransports);
  }

  Future<void> getTransports(
      GetTransportsEvent event,
      Emitter<TransportState> emit,
      ) async {
    emit(LoadingTransportState());

    final result = await transportApiService.getTransport();

    result.fold(
          (error) {
        emit(
          FailedTransportState(
            errorMessage: error,
          ),
        );
      },
          (Transports) {
        emit(
          SuccessTransportState(
            Transports: Transports,
          ),
        );
      },
    );
  }
}
