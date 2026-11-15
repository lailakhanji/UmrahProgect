import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:umrahapp/views/booking/connecting_information_pages/widgets/custom_stepper.dart';
import 'package:umrahapp/views/booking/connecting_information_pages/widgets/passenger_card.dart';

import '../../bookings/my_bookings_bloc/my_bookings_bloc.dart';
import '../../home_page/bottom_navigation_bar_screen.dart';
import '../booking_bloc/booking_bloc.dart';
import '../data/travel_model.dart';
import '../payment/payment_screen.dart';

class PassengerDataScreen extends StatefulWidget {
  final int adultsCount;
  final int childrenCount;
  final String packageId;
  final String bookingId;
  final String? tripId;
  final String? hotelId;
  final String? transportId;

  const PassengerDataScreen({
    super.key,
    required this.adultsCount,
    required this.childrenCount,
    required this.packageId,
    required this.bookingId,
    this.tripId,
    this.hotelId,
    this.transportId,
  });

  @override
  State<PassengerDataScreen> createState() => _PassengerDataScreenState();
}

class _PassengerDataScreenState extends State<PassengerDataScreen> {
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
                  backgroundColor: const Color(0xff087443),
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const BottomNavigationBarScreen(initialIndex: 4),
      ),
      (route) => false,
    );
  }

  double? totalPrice;

  late final PageController pageController;

  int currentPassenger = 0;

  late int totalPassengers;

  late List<GlobalKey<PassengerCardState>> passengerKeys;

  bool isAddingMember = false;

  @override
  void initState() {
    super.initState();

    // الأطفال + البالغين الإضافيين
    totalPassengers = widget.adultsCount + widget.childrenCount;

    pageController = PageController();

    passengerKeys = List.generate(
      totalPassengers,
      (_) => GlobalKey<PassengerCardState>(),
    );

    // ============================================================
    // لا نحسب السعر من جديد هنا
    // ============================================================
    //
    // TravelersScreen قام بالفعل بحساب السعر.
    //
    // لذلك لا نرسل CalculateBookingPriceEvent هنا،
    // خصوصاً لأن Custom لا يملك packageId.
    //
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  String getOrdinal(int number) {
    switch (number) {
      case 1:
        return 'الأول';
      case 2:
        return 'الثاني';
      case 3:
        return 'الثالث';
      case 4:
        return 'الرابع';
      case 5:
        return 'الخامس';
      default:
        return number.toString();
    }
  }

  int calculateAge(String birthDate) {
    try {
      DateTime birth;

      if (birthDate.contains('/')) {
        final parts = birthDate.split('/');

        if (parts.length != 3) {
          throw Exception();
        }

        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        birth = DateTime(year, month, day);
      } else {
        birth = DateTime.parse(birthDate);
      }

      final today = DateTime.now();

      int age = today.year - birth.year;

      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }

      return age;
    } catch (e) {
      throw Exception('تاريخ الميلاد غير صحيح: $birthDate');
    }
  }

  String formatDateForApi(String date) {
    try {
      DateTime parsedDate;

      if (date.contains('/')) {
        final parts = date.split('/');

        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        parsedDate = DateTime.utc(year, month, day);
      } else {
        parsedDate = DateTime.parse(date);
      }

      return parsedDate.toIso8601String();
    } catch (_) {
      throw Exception('تاريخ انتهاء الجواز غير صحيح: $date');
    }
  }

  // ============================================================
  // إضافة المسافر الحالي
  // ============================================================
  void _addCurrentPassenger() {
    final passengerState = passengerKeys[currentPassenger].currentState;

    if (passengerState == null) return;

    final isValid = passengerState.validateForm();

    if (!isValid) return;
    final passenger = passengerState.getPassengerData();

    final bool isChild = currentPassenger < widget.childrenCount;

    final String? relationship = passenger['relationship']?.toString().trim();

    final String? birthDate = passenger['birthDate']?.toString().trim();

    if (birthDate == null || birthDate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال تاريخ الميلاد')));
      return;
    }

    final age = calculateAge(birthDate);

    final String? passportExpiryDate = passenger['passportExpiryDate']
        ?.toString()
        .trim();

    if (passportExpiryDate == null || passportExpiryDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال تاريخ انتهاء الجواز')),
      );
      return;
    }

    final gender = passenger['gender']?.toString().trim();

    if (gender == null || gender.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار الجنس')));
      return;
    }
    final member = FamilyMemberModel(
      bookingId: widget.bookingId,
      name: passenger['name']?.toString().trim() ?? '',
      passportNumber: passenger['passportNumber']?.toString().trim() ?? '',
      passportExpiryDate: formatDateForApi(passportExpiryDate),
      age: age,

      // الآن للطفل والبالغ
      gender: gender,

      relationship: relationship,
    );

    print('================================');
    print('🔥 ADD FAMILY MEMBER');
    print('🔥 BOOKING ID: ${member.bookingId}');
    print('🔥 DATA: ${member.toJson()}');
    print('================================');

    setState(() {
      isAddingMember = true;
    });

    context.read<BookingBloc>().add(
      AddFamilyMemberEvent(bookingId: widget.bookingId, member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyBookingsBloc, MyBookingsState>(
      listener: (context, myBookingsState) {
        // ======================================================
        // BOOKING DETAILS LOADED
        // ======================================================

        if (myBookingsState is BookingDetailsLoaded) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text(
                  'تنبيه',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'يرجى الانتباه، لا تقم بالدفع قبل تأكيد الحجز.\n\n'
                  'ستصلك رسالة عند تأكيد الحجز، وبعدها يمكنك إتمام الدفع.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.6),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentScreen(booking: myBookingsState.booking),
                        ),
                      );
                    },
                    child: const Text('فهمت، متابعة'),
                  ),
                ],
              );
            },
          );
        }
        // ======================================================
        // ERROR FROM GET BOOKING DETAILS
        // ======================================================

        if (myBookingsState is MyBookingsError) {
          setState(() {
            isAddingMember = false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(myBookingsState.message)));
        }
      },

      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) async {
          // ======================================================
          // PRICE SUCCESS
          // ======================================================

          if (state is BookingPriceSuccess) {
            setState(() {
              totalPrice = state.price.totalPrice;
            });

            print('🔥 TOTAL PRICE: $totalPrice');
          }

          // ======================================================
          // FAMILY MEMBER ADDED
          // ======================================================

          if (state is FamilyMemberAdded) {
            setState(() {
              isAddingMember = false;
            });

            print('✅ FAMILY MEMBER ADDED: ${state.familyMemberId}');

            // ==================================================
            // باقي المسافرين
            // ==================================================

            if (currentPassenger < totalPassengers - 1) {
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              // آخر مسافر
              // إظهار رسالة نجاح إنشاء الحجز
              await _showBookingCreatedMessage();
            }
          }

          // ======================================================
          // BOOKING ERROR
          // ======================================================

          if (state is BookingFailure) {
            setState(() {
              isAddingMember = false;
            });

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          // ======================================================
          // PRICE ERROR
          // ======================================================

          if (state is BookingPriceFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },

        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const CustomStepper(currentStep: 3),

                const SizedBox(height: 25),

                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalPassengers,

                    onPageChanged: (index) {
                      setState(() {
                        currentPassenger = index;
                      });
                    },

                    itemBuilder: (context, index) {
                      // =================================================
                      // الأطفال أولاً ثم البالغين
                      // =================================================

                      final bool isChild = index < widget.childrenCount;

                      // =================================================
                      // رقم المسافر داخل نوعه
                      // =================================================

                      final int number;

                      if (isChild) {
                        number = index + 1;
                      } else {
                        number = index - widget.childrenCount + 1;
                      }

                      return PassengerCard(
                        key: passengerKeys[index],

                        passengerNumber: getOrdinal(number),

                        isChild: isChild,

                        onBack: currentPassenger == 0
                            ? null
                            : () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // BUTTON
          // ======================================================
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isAddingMember ? null : _addCurrentPassenger,

                  child: isAddingMember
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          currentPassenger < totalPassengers - 1
                              ? 'المسافر التالي'
                              : 'متابعة',
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
