part of 'hotel_bloc.dart';


 class HotelState {}

class InitHotelState extends HotelState{}
class LoadingHotelState extends HotelState{}
class FailedHotelState extends HotelState{
  final String errorMessage;

  FailedHotelState({required this.errorMessage});
}
class SuccessHotelState extends HotelState{
  final List<HotelModel> data;

  SuccessHotelState({required this.data});
}

