import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/trip/trip_bottom_sheet.dart';

import '../booking/booking_bloc/booking_bloc.dart';
import '../booking/connecting_information_pages/traveler_screen.dart';
import '../bookings/data/my_bookings_api_service.dart';
import '../bookings/data/models/booking_details_model.dart';
import '../hotel/hotel_bottom_sheet.dart';
import '../hotel/widget/package_info_card.dart';
import '../transport/transport_bloc/transport_bloc.dart';
import '../transport/transport_bottom_sheet.dart';

import 'bottom_navigation_bar_screen.dart';
import 'data/category_model.dart';

class PackageDetailScreen extends StatefulWidget {
  final CategoryModel package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  double? totalPrice;

  bool addingFamilyMembers = false;

  bool shouldCreateBookingAfterPrice = false;

  bool checkingPreviousBooking = false;

  // ===========================================================
  // فحص إذا كان المستخدم حاجز نفس الرحلة مسبقاً
  // ===========================================================

  Future<bool> _hasAlreadyBookedThisTrip() async {
    try {
      final apiService = MyBookingsApiService();

      // جلب جميع حجوزات المستخدم
      final response = await apiService.getUserBookings();

      final List data = response.data;

      if (data.isEmpty) {
        return false;
      }

      final String currentTripId = widget.package.tripId?.toString() ?? '';

      if (currentTripId.isEmpty) {
        return false;
      }

      // فحص تفاصيل كل حجز
      for (final item in data) {
        try {
          final bookingId = item['id']?.toString() ?? '';

          if (bookingId.isEmpty) {
            continue;
          }

          final detailsResponse = await apiService.getBookingDetails(
            bookingId: bookingId,
          );

          final bookingDetails = BookingDetailsModel.fromJson(
            detailsResponse.data,
          );

          // نفس الرحلة
          if (bookingDetails.tripId == currentTripId) {
            // إذا كان الحجز ملغى لا نمنع المستخدم
            final status = bookingDetails.status.toLowerCase();

            if (status != 'cancelled') {
              return true;
            }
          }
        } catch (e) {
          debugPrint('Error checking booking details: $e');
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking previous bookings: $e');

      return false;
    }
  }

  // ===========================================================
  // التحقق قبل تنفيذ الحجز
  // ===========================================================

  Future<bool> _checkBeforeBooking() async {
    if (checkingPreviousBooking) {
      return false;
    }

    setState(() {
      checkingPreviousBooking = true;
    });

    final alreadyBooked = await _hasAlreadyBookedThisTrip();

    if (!mounted) {
      return false;
    }

    setState(() {
      checkingPreviousBooking = false;
    });

    if (alreadyBooked) {
      _showAlreadyBookedMessage();
      return false;
    }

    return true;
  }

  // ===========================================================
  // رسالة نجاح إنشاء الحجز
  // ===========================================================

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
                  backgroundColor: const Color(0xff186442),
                  foregroundColor: Colors.white,
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

  // ===========================================================
  // رسالة الحجز المسبق
  // ===========================================================

  void _showAlreadyBookedMessage() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'تنبيه',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'لقد قمت بحجز هذه الرحلة مسبقاً.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          centerTitle: true,
          title: Text(
            'تفاصيل الباقة',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 25,
            ),
          ),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) async {
            // =================================================
            // حساب السعر
            // =================================================

            if (state is BookingPriceSuccess) {
              setState(() {
                totalPrice = state.price.totalPrice;
              });

              if (shouldCreateBookingAfterPrice) {
                shouldCreateBookingAfterPrice = false;

                context.read<BookingBloc>().add(
                  CreatePackageBookingEvent(packageId: widget.package.id ?? ''),
                );
              }
            }

            // =================================================
            // إنشاء الحجز بنجاح
            // =================================================

            if (state is BookingSuccess) {
              if (!mounted) return;

              if (addingFamilyMembers) {
                HelperFunction.navigate(
                  context,
                  TravelersScreen(
                    packageId: widget.package.id ?? '',
                    bookingId: state.bookingId,
                  ),
                );

                return;
              }

              await _showBookingCreatedMessage();
            }

            // =================================================
            // فشل إنشاء الحجز
            // =================================================

            if (state is BookingFailure) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            // =================================================
            // فشل حساب السعر
            // =================================================

            if (state is BookingPriceFailure) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading =
                state is BookingLoading || checkingPreviousBooking;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // =================================================
                    // صورة الباقة
                    // =================================================
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        widget.package.imageUrl ?? '',
                        height: 190,
                        width: MediaQuery.sizeOf(context).width,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // معلومات الباقة
                    // =================================================
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.package.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${((widget.package.numberOfNights ?? 0) * 0.7).ceil()} ليالي بمكة',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${((widget.package.numberOfNights ?? 0) * 0.3).floor()} ليالي بالمدينة',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Text(
                                  'فندق ${widget.package.hotelName}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '  بسعر',
                                style: TextStyle(fontSize: 14),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '\$ ${widget.package.totalPrice?.toInt() ?? 0}',
                                    style: const TextStyle(
                                      color: Color(0xff0D9B5C),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'للشخص',
                                    style: TextStyle(
                                      color: Color(0xff0D9B5C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'مع وجود حسومات',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // معلومات الرحلة
                    // =================================================
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (_) {
                                  return TripBottomSheet(
                                    packageId: widget.package.tripId ?? '',
                                  );
                                },
                              );
                            },
                            child: const PackageInfoCard(
                              title: 'الرحلة',
                              subtitle: 'إلى مكة و المدينة المنورة',
                              icon: 'assets/icons/mdi_flight.svg',
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (_) {
                                  return HotelBottomSheet(
                                    hotelName: widget.package.hotelName ?? '',
                                    packageType: widget.package.name ?? '',
                                  );
                                },
                              );
                            },
                            child: const PackageInfoCard(
                              title: 'الإقامة',
                              subtitle: 'فندق في مكة، فندق في المدينة',
                              icon: 'assets/icons/mingcute_hotel-fill.svg',
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (modalContext) => BlocProvider.value(
                                  value: context.read<TransportBloc>(),
                                  child: TransportBottomSheet(
                                    transportId: widget.package.id ?? '',
                                  ),
                                ),
                              );
                            },
                            child: const PackageInfoCard(
                              title: 'المواصلات',
                              subtitle: 'النقل من وإلى المطار',
                              icon: 'assets/icons/tabler_bus-filled.svg',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =================================================
                    // احجز الآن
                    // =================================================
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
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              final canBook = await _checkBeforeBooking();

                              if (!canBook || !mounted) {
                                return;
                              }

                              setState(() {
                                addingFamilyMembers = false;

                                shouldCreateBookingAfterPrice = true;
                              });

                              debugPrint('Package ID: ${widget.package.id}');

                              debugPrint('Trip ID: ${widget.package.tripId}');

                              context.read<BookingBloc>().add(
                                CalculateBookingPriceEvent(
                                  packageId: widget.package.id ?? '',
                                  adults: 1,
                                  children: 0,
                                ),
                              );
                            },
                      child: checkingPreviousBooking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'احجز الآن',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // إضافة أفراد
                    // =================================================
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.sizeOf(context).width - 50,
                          36,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xff186442),
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              final canBook = await _checkBeforeBooking();

                              if (!canBook || !mounted) {
                                return;
                              }

                              setState(() {
                                addingFamilyMembers = true;

                                shouldCreateBookingAfterPrice = false;
                              });

                              context.read<BookingBloc>().add(
                                CreatePackageBookingEvent(
                                  packageId: widget.package.id ?? '',
                                ),
                              );
                            },
                      child: checkingPreviousBooking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xff186442),
                              ),
                            )
                          : const Text(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
