import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/hotel/hotel_selection_screen.dart';

import '../transport/data/transport_model.dart';
import '../transport/transport_bloc/transport_bloc.dart';

import 'data/trip_model.dart';
import 'trip_bloc/trip_bloc.dart';

class TripSelectionScreen extends StatefulWidget {
  const TripSelectionScreen({super.key});

  @override
  State<TripSelectionScreen> createState() => _TripSelectionScreenState();
}

class _TripSelectionScreenState extends State<TripSelectionScreen> {
  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xfffff3f3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_outlined,
                size: 36,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'حدث خطأ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff222222),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message.isNotEmpty
                  ? 'تأكد من اتصالك بالانترنت'
                  : 'تعذر تحميل البيانات، يرجى المحاولة مرة أخرى.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.6,
                color: Color.fromRGBO(0, 0, 0, 0.55),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: 150,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.white10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TripModel? selectedTrip;
  TransportModel? selectedTransport;

  static const Color primaryColor = Color(0xff087443);
  static const Color lightGreen = Color(0xffb8d8c9);
  static const Color priceColor = Color(0xff00a86b);

  @override
  void initState() {
    super.initState();

    context.read<TripBloc>().add(GetTripsEvent());
    context.read<TransportBloc>().add(GetTransportsEvent());
  }

  Future<void> _refreshData() async {
    context.read<TripBloc>().add(GetTripsEvent());
    context.read<TransportBloc>().add(GetTransportsEvent());

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                _buildHeader(),

                const SizedBox(height: 25),

                Expanded(
                  child: BlocBuilder<TripBloc, TripState>(
                    builder: (context, tripState) {
                      if (tripState is LoadingTripState) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }

                      if (tripState is FailedTripState) {
                        return _buildErrorState(
                          message: tripState.errorMessage,
                          onRetry: () {
                            context.read<TripBloc>().add(GetTripsEvent());
                          },
                        );
                      }

                      if (tripState is SuccessTripState) {
                        if (tripState.trips.isEmpty) {
                          return RefreshIndicator(
                            color: primaryColor,
                            onRefresh: _refreshData,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(
                                  child: Text(
                                    'لا توجد رحلات متاحة حالياً',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return BlocBuilder<TransportBloc, TransportState>(
                          builder: (context, transportState) {
                            if (transportState is LoadingTransportState) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              );
                            }

                            if (transportState is FailedTransportState) {
                              return _buildErrorState(
                                message: transportState.errorMessage,
                                onRetry: () {
                                  context.read<TransportBloc>().add(
                                    GetTransportsEvent(),
                                  );
                                },
                              );
                            }

                            if (transportState is SuccessTransportState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الرحلات القادمة',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Expanded(
                                    child: RefreshIndicator(
                                      color: primaryColor,
                                      onRefresh: _refreshData,
                                      child: ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        children: [
                                          // =========================
                                          // الرحلات
                                          // =========================
                                          ...tripState.trips.map(
                                            (trip) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: _buildTripCard(trip),
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          // =========================
                                          // وسيلة النقل
                                          // =========================
                                          const Text(
                                            'وسيلة النقل',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          if (selectedTrip == null)
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: const Color(0xfffafafa),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xffeeeeee,
                                                  ),
                                                ),
                                              ),
                                              child: const Text(
                                                'يرجى اختيار الرحلة أولاً',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          else
                                            ...transportState.Transports.map(
                                              (transport) =>
                                                  _buildTransportItem(
                                                    transport,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return const SizedBox();
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),

                const SizedBox(height: 15),

                _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, size: 25),
        ),

        const Spacer(),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              'تفاصيل الرحلة',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            SizedBox(height: 3),

            Text(
              'اختر الرحلة ووسيلة النقل',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(0, 0, 0, 0.65),
              ),
            ),
          ],
        ),

        const Spacer(),
      ],
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final bool isSelected = selectedTrip?.id == trip.id;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          selectedTrip = trip;
          selectedTransport = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xffdddddd),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.title ?? 'رحلة',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? primaryColor : Colors.grey,
                  size: 21,
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (trip.description != null && trip.description!.isNotEmpty)
              Text(
                trip.description!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.65),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 10),

            _buildInfoRow(Icons.subtitles_outlined, trip.title ?? 'الوجهة'),

            const SizedBox(height: 7),

            if (trip.startDate != null && trip.endDate != null)
              _buildInfoRow(
                Icons.calendar_today_outlined,
                '${_formatDate(trip.startDate!)} - ${_formatDate(trip.endDate!)}',
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Spacer(),

                const Text(
                  'السعر ',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color.fromRGBO(0, 0, 0, 0.65),
                  ),
                ),

                Text(
                  '${trip.pricePerPerson?.toStringAsFixed(0) ?? 0}\$',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: priceColor,
                  ),
                ),

                const Text(
                  ' /للشخص',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Color.fromRGBO(0, 0, 0, 0.65),
                  ),
                ),
              ],
            ),

            if (isSelected) ...[
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'تم اختيار هذه الرحلة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransportItem(TransportModel transport) {
    final bool isSelected = selectedTransport?.id == transport.id;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () {
          if (selectedTrip == null) {
            return;
          }

          setState(() {
            selectedTransport = transport;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.06)
                : const Color(0xfffafafa),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isSelected ? primaryColor : const Color(0xffeeeeee),
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? primaryColor : Colors.grey,
                size: 20,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transport.type ?? 'وسيلة نقل',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (transport.price != null)
                            Text(
                              '${transport.price!.toStringAsFixed(0)}\$',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: priceColor,
                              ),
                            ),

                          const Spacer(),

                          Flexible(
                            child: Text(
                              transport.departureCity ?? 'غير محدد',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Color.fromRGBO(0, 0, 0, 0.60),
                              ),
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.arrow_back,
                              size: 14,
                              color: primaryColor,
                            ),
                          ),

                          Flexible(
                            child: Text(
                              transport.arrivalCity ?? 'غير محدد',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Color.fromRGBO(0, 0, 0, 0.60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: primaryColor),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.0,
              letterSpacing: 0,
              color: Color.fromRGBO(0, 0, 0, 0.65),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final bool canContinue = selectedTrip != null && selectedTransport != null;

    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: !canContinue
            ? null
            : () {
                final tripId = selectedTrip!.id;
                final transportId = selectedTransport!.id;

                print('🔥 TRIP ID: $tripId');
                print('🔥 TRANSPORT ID: $transportId');

                HelperFunction.navigate(
                  context,
                  HotelSelectionScreen(
                    tripId: tripId ?? '',
                    transportId: transportId ?? '',
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: lightGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'متابعة',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      return intl.DateFormat('d MMMM', 'ar').format(parsedDate);
    } catch (_) {
      return date;
    }
  }
}
