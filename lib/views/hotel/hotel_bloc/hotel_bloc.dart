import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hotel_api_service.dart';
import '../data/hotel_model.dart';

part 'hotel_event.dart';
part 'hotel_state.dart';


class HotelBloc extends Bloc<HotelEvent, HotelState> {


  final HotelApiService hotelApiService;


  HotelBloc(this.hotelApiService)
      : super(InitHotelState()) {


    on<GetHotelsEvent>(getHotels);


  }



  Future<void> getHotels(
      GetHotelsEvent event,
      Emitter<HotelState> emit,
      ) async {


    emit(LoadingHotelState());


    final result = await hotelApiService.getHotels();



    result.fold(

          (error) {

        emit(
          FailedHotelState(
            errorMessage: error,
          ),
        );

      },


          (hotels) {

        emit(
          SuccessHotelState(
            data: hotels,
          ),
        );

      },


    );


  }


}