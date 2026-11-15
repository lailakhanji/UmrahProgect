import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:umrahapp/views/hotel/widget/hotel_selection_card.dart';
import 'package:umrahapp/views/hotel/widget/madinah_hotel_selection_card.dart';
import 'package:umrahapp/views/hotel/widget/madinah_hotel_type.dart';

import '../../services/shared_preferances_service.dart';

import '../booking/booking_bloc/booking_bloc.dart';
import '../booking/connecting_information_pages/traveler_screen.dart';
import '../booking/data/create_booking_request_model.dart';
import '../bookings/my_bookings_screen.dart';

import '../home_page/bottom_navigation_bar_screen.dart';
import 'data/hotel_model.dart';
import 'hotel_bloc/hotel_bloc.dart';

class HotelSelectionScreen extends StatefulWidget {
  final String tripId;
  final String transportId;

  const HotelSelectionScreen({
    super.key,
    required this.tripId,
    required this.transportId,
  });

  @override
  State<HotelSelectionScreen> createState() => _HotelSelectionScreenState();
}

class _HotelSelectionScreenState extends State<HotelSelectionScreen> {
  bool noMakkahHotel = false;
  bool noMadinahHotel = false;

  HotelModel? selectedMakkahHotel;
  MadinahHotelOption? selectedMadinahHotel;

  bool _isCreatingBooking = false;

  static const Color primaryColor = Color(0xff087443);

  // ============================================================
  // Refresh
  // ============================================================

  Future<void> _refreshHotels() async {
    context.read<HotelBloc>().add(GetHotelsEvent());

    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ============================================================
  // رسالة النجاح
  // ============================================================

  Future<void> _showBookingCreatedMessage() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 8),
                Text(
                  'تم إنشاء الحجز',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'تم إنشاء الحجز بنجاح.\n\n'
              'سيتم مراجعة الحجز من قبل الإدارة، '
              'وبعد تأكيد الحجز سيظهر لك خيار الدفع في "حجوزاتي".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const BottomNavigationBarScreen(initialIndex: 4),
      ),
    );
  }

  // ============================================================
  // رسالة الخطأ
  // ============================================================

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
              decoration: const BoxDecoration(
                color: Color(0xfffff3f3),
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
                    side: const BorderSide(color: Color(0xffeeeeee), width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // إنشاء الحجز
  // ============================================================

  Future<void> _createBooking({required bool goToTravelers}) async {
    if (_isCreatingBooking) return;

    if ((!noMakkahHotel && selectedMakkahHotel == null) ||
        (!noMadinahHotel && selectedMadinahHotel == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار الفندق أو اختيار "لا أريد حجز فندق"'),
        ),
      );

      return;
    }

    final userId = SharedPreferancesService.userId;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على بيانات المستخدم')),
      );

      return;
    }

    setState(() {
      _isCreatingBooking = true;
    });

    final request = CreateBookingRequestModel(
      userId: userId,
      tripId: widget.tripId,
      hotelId: noMakkahHotel ? null : selectedMakkahHotel?.id,
      transportId: widget.transportId,
    );

    debugPrint('====================================');
    debugPrint('🔥 CREATE CUSTOM BOOKING');
    debugPrint('🔥 USER ID: $userId');
    debugPrint('🔥 TRIP ID: ${widget.tripId}');
    debugPrint('🔥 HOTEL ID: ${selectedMakkahHotel?.id ?? 'NO HOTEL'}');
    debugPrint('🔥 MADINAH HOTEL: ${selectedMadinahHotel?.type ?? 'NO HOTEL'}');
    debugPrint('🔥 NO MAKKAH HOTEL: $noMakkahHotel');
    debugPrint('🔥 NO MADINAH HOTEL: $noMadinahHotel');
    debugPrint('🔥 TRANSPORT ID: ${widget.transportId}');
    debugPrint('====================================');

    context.read<BookingBloc>().add(CreateCustomBookingEvent(request: request));

    final bookingState = await context.read<BookingBloc>().stream.firstWhere(
      (state) => state is CreateBookingSuccess || state is CreateBookingFailure,
    );

    if (!mounted) return;

    setState(() {
      _isCreatingBooking = false;
    });

    if (bookingState is CreateBookingFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingState.message),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (bookingState is CreateBookingSuccess) {
      final bookingId = bookingState.bookingId;

      debugPrint('====================================');
      debugPrint('🔥 BOOKING CREATED SUCCESSFULLY');
      debugPrint('🔥 BOOKING ID: $bookingId');
      debugPrint('====================================');

      if (goToTravelers) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TravelersScreen(
              packageId: '',
              bookingId: bookingId,
              tripId: widget.tripId,
              hotelId: noMakkahHotel ? null : selectedMakkahHotel?.id,
              transportId: widget.transportId,
            ),
          ),
        );

        return;
      }

      await _showBookingCreatedMessage();
    }
  }

  // ============================================================
  // إضافة أفراد
  // ============================================================

  void _addFamilyMembers() {
    _createBooking(goToTravelers: true);
  }

  // ============================================================
  // احجز الآن
  // ============================================================

  void _bookNow() {
    _createBooking(goToTravelers: false);
  }

  @override
  void initState() {
    super.initState();

    context.read<HotelBloc>().add(GetHotelsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الإقامة',
            style: TextStyle(
              color: Color(0xff126B48),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        body: BlocBuilder<HotelBloc, HotelState>(
          builder: (context, state) {
            if (state is LoadingHotelState) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff126B48)),
              );
            }

            if (state is FailedHotelState) {
              return _buildErrorState(
                message: state.errorMessage,
                onRetry: () {
                  context.read<HotelBloc>().add(GetHotelsEvent());
                },
              );
            }

            if (state is SuccessHotelState) {
              final hotels = state.data;

              final makkahHotels = hotels.toList();

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: _refreshHotels,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    const Text(
                      'اختر فندق مكة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          noMakkahHotel = !noMakkahHotel;

                          if (noMakkahHotel) {
                            selectedMakkahHotel = null;
                          }
                        });
                      },
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: noMakkahHotel
                                ? const Color(0xffEAF5EF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: noMakkahHotel
                                  ? primaryColor
                                  : const Color(0xffE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                noMakkahHotel
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: noMakkahHotel
                                    ? primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Text(
                                  'لا أريد حجز فندق في مكة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (makkahHotels.isEmpty)
                      const _EmptyHotelsWidget(
                        message: 'لا توجد فنادق متاحة في مكة',
                      ),

                    ...makkahHotels.map(
                      (hotel) => HotelSelectionCard(
                        hotel: hotel,
                        isSelected: selectedMakkahHotel?.id == hotel.id,
                        onTap: () {
                          setState(() {
                            selectedMakkahHotel = hotel;
                            noMakkahHotel = false;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'اختر مستوى فندق المدينة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'اختر النسق المناسب لك',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          noMadinahHotel = !noMadinahHotel;

                          if (noMadinahHotel) {
                            selectedMadinahHotel = null;
                          }
                        });
                      },
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: noMadinahHotel
                                ? const Color(0xffEAF5EF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: noMadinahHotel
                                  ? primaryColor
                                  : const Color(0xffE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                noMadinahHotel
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: noMadinahHotel
                                    ? primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Text(
                                  'لا أريد حجز فندق في المدينة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...madinahHotelOptions.map(
                      (option) => MadinahHotelSelectionCard(
                        option: option,
                        isSelected: selectedMadinahHotel?.type == option.type,
                        onTap: () {
                          setState(() {
                            selectedMadinahHotel = option;
                            noMadinahHotel = false;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: Size(
                          MediaQuery.sizeOf(context).width - 50,
                          48,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          (noMakkahHotel || selectedMakkahHotel != null) &&
                              (noMadinahHotel ||
                                  selectedMadinahHotel != null) &&
                              !_isCreatingBooking
                          ? _bookNow
                          : null,
                      child: Text(
                        'احجز الآن',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(
                          MediaQuery.sizeOf(context).width - 50,
                          36,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xff186442),
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed:
                          (noMakkahHotel || selectedMakkahHotel != null) &&
                              (noMadinahHotel ||
                                  selectedMadinahHotel != null) &&
                              !_isCreatingBooking
                          ? _addFamilyMembers
                          : null,
                      child: const Text(
                        'إضافة أفراد     +',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff186442),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _EmptyHotelsWidget extends StatelessWidget {
  final String message;

  const _EmptyHotelsWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
