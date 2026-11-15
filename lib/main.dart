import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:umrahapp/final_project_application.dart';

import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';

import 'package:umrahapp/views/booking/booking_bloc/booking_bloc.dart';
import 'package:umrahapp/views/booking/data/booking_api_service.dart';
import 'package:umrahapp/views/booking/data/booking_price_api_service.dart';
import 'package:umrahapp/views/bookings/data/my_bookings_api_service.dart';
import 'package:umrahapp/views/bookings/my_bookings_bloc/my_bookings_bloc.dart';

import 'package:umrahapp/views/cities/cities_bloc/cities_bloc.dart';
import 'package:umrahapp/views/cities/data/cities_api_service.dart';
import 'package:umrahapp/views/duaa/duaa_request_bloc/duaa_request_bloc.dart';
import 'package:umrahapp/views/duaa/duaa_request_bloc/duaa_request_event.dart';

import 'package:umrahapp/views/home_page/home_bloc/home_bloc.dart';

import 'package:umrahapp/views/hotel/data/hotel_api_service.dart';
import 'package:umrahapp/views/hotel/hotel_bloc/hotel_bloc.dart';
import 'package:umrahapp/views/notifications/data/notification_api_service.dart';
import 'package:umrahapp/views/notifications/notification_bloc/notification_bloc.dart';
import 'package:umrahapp/views/profile/data/profile_api_service.dart';
import 'package:umrahapp/views/profile/profile_bloc/profile_bloc.dart';

import 'package:umrahapp/views/transport/data/transport_api_service.dart';
import 'package:umrahapp/views/transport/transport_bloc/transport_bloc.dart';

import 'package:umrahapp/views/trip/data/trip_api_service.dart';
import 'package:umrahapp/views/trip/trip_bloc/trip_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferancesService.init();

  ApiService.token = SharedPreferancesService.token;

  await ApiService.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),

        BlocProvider(
          create: (_) => HotelBloc(HotelApiService())..add(GetHotelsEvent()),
        ),

        BlocProvider(
          create: (_) => TripBloc(TripApiService())..add(GetTripsEvent()),
        ),
        BlocProvider(create: (_) => MyBookingsBloc(MyBookingsApiService())),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(ProfileApiService()),
        ),
        BlocProvider(
          create: (_) =>
              TransportBloc(TransportApiService())..add(GetTransportsEvent()),
        ),

        BlocProvider(
          create: (_) => CitiesBloc(CitiesApiService())..add(GetCitiesEvent()),
        ),

        // Booking
        BlocProvider(
          create: (_) => BookingBloc(
            BookingApiService(),
            bookingPriceApiService: BookingPriceApiService(),
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => NotificationBloc(NotificationApiService())
            ..add(GetNotificationsEvent())
            ..add(StartNotificationPollingEvent()),
        ),
        BlocProvider<DuaaRequestBloc>(
          create: (_) => DuaaRequestBloc()..add(GetDuaaRequests()),
        ),
      ],

      child: const FinalProjectApplication(),
    ),
  );
}
