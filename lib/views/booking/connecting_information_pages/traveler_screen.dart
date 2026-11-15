import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/views/booking/connecting_information_pages/passenger_data_screen.dart';
import 'package:umrahapp/views/booking/connecting_information_pages/widgets/custom_stepper.dart';

import '../booking_bloc/booking_bloc.dart';
import '../data/booking_price_model.dart';

class TravelersScreen extends StatefulWidget {
  final String packageId;
  final String bookingId;

  final String? tripId;
  final String? hotelId;
  final String? transportId;

  const TravelersScreen({
    super.key,
    required this.packageId,
    required this.bookingId,
    this.tripId,
    this.hotelId,
    this.transportId,
  });

  @override
  State<TravelersScreen> createState() => _TravelersScreenState();
}

class _TravelersScreenState extends State<TravelersScreen> {
  int adultsCount = 1;
  int childrenCount = 0;

  final Color primaryColor = const Color(0xFF087443);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculatePrice();
    });
  }

  void increaseAdults() {
    if (adultsCount + childrenCount < 4) {
      setState(() {
        adultsCount++;
      });

      calculatePrice();
    }
  }

  void calculatePrice() {
    if (widget.packageId.isNotEmpty) {
      context.read<BookingBloc>().add(
        CalculateBookingPriceEvent(
          packageId: widget.packageId,
          adults: adultsCount,
          children: childrenCount,
        ),
      );
      return;
    }

    if (widget.tripId == null ||
        widget.hotelId == null ||
        widget.transportId == null) {
      debugPrint('❌ CUSTOM PRICE: missing trip/hotel/transport');
      return;
    }

    context.read<BookingBloc>().add(
      CalculateCustomPriceEvent(
        tripId: widget.tripId!,
        hotelId: widget.hotelId!,
        transportId: widget.transportId!,
        adults: adultsCount,
        children: childrenCount,
      ),
    );
  }

  void decreaseAdults() {
    if (adultsCount > 1) {
      setState(() {
        adultsCount--;
      });

      calculatePrice();
    }
  }

  void increaseChildren() {
    if (adultsCount + childrenCount < 4) {
      setState(() {
        childrenCount++;
      });

      calculatePrice();
    }
  }

  void decreaseChildren() {
    if (childrenCount > 0) {
      setState(() {
        childrenCount--;
      });

      calculatePrice();
    }
  }

  void continueNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerDataScreen(
          adultsCount: adultsCount,
          childrenCount: childrenCount,
          packageId: widget.packageId,
          bookingId: widget.bookingId,

          tripId: widget.tripId,
          hotelId: widget.hotelId,
          transportId: widget.transportId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                print('========== BOOKING PRICE STATE ==========');
                print(state.runtimeType);

                if (state is BookingPriceFailure) {
                  print('PRICE ERROR: ${state.message}');
                }

                if (state is BookingPriceSuccess) {
                  print('PRICE SUCCESS');
                  print('Total: ${state.price.totalPrice}');
                }
              },

              builder: (context, state) {
                return Column(
                  children: [
                    // =========================
                    // العنوان
                    // =========================
                    Row(
                      children: [
                        const Spacer(),

                        const Text(
                          'المسافرون',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF087443),
                          ),
                        ),

                        const Spacer(),

                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // =========================
                    // Stepper
                    // =========================
                    const CustomStepper(currentStep: 2),

                    const SizedBox(height: 15),

                    Container(
                      height: 2,
                      width: double.infinity,
                      color: const Color(0xFFE6F1EB),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // الوصف
                    // =========================
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'من فضلك قم بإدخال عدد المسافرون الإضافيون',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // البالغين
                    // =========================
                    TravelerCounter(
                      title: 'البالغين',
                      subtitle: 'من 12 سنة فما فوق',
                      icon: Icons.person,
                      count: adultsCount,
                      onIncrease: increaseAdults,
                      onDecrease: decreaseAdults,
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // الأطفال
                    // =========================
                    TravelerCounter(
                      title: 'الأطفال',
                      subtitle: 'من 2 - 11 سنة',
                      icon: Icons.child_care,
                      count: childrenCount,
                      onIncrease: increaseChildren,
                      onDecrease: decreaseChildren,
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // ملخص السعر
                    // =========================
                    if (state is BookingPriceLoading ||
                        state is CustomPriceLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )
                    else if (state is BookingPriceSuccess)
                      PriceSummaryCard(
                        price: state.price,
                        adultsCount: adultsCount,
                        childrenCount: childrenCount,
                      )
                    else if (state is CustomPriceSuccess)
                      PriceSummaryCard(
                        price: state.price,
                        adultsCount: adultsCount,
                        childrenCount: childrenCount,
                      ),
                    const Spacer(),

                    // =========================
                    // زر المتابعة
                    // =========================
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: continueNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: const Text(
                          'متابعة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// Stepper
// =====================================================

class SimpleStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SimpleStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        // =========================
        // الدائرة
        // =========================

        if (index.isEven) {
          final int step = index ~/ 2;

          final bool isActive = step == currentStep;

          return Container(
            width: 32,
            height: 32,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF087443) : Colors.white,

              border: Border.all(
                color: isActive
                    ? const Color(0xFF087443)
                    : const Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),

            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF777777),
                ),
              ),
            ),
          );
        }

        // =========================
        // الخط
        // =========================

        return Expanded(
          child: Container(height: 1.5, color: const Color(0xFFD9D9D9)),
        );
      }),
    );
  }
}

// =====================================================
// Counter
// =====================================================

class TravelerCounter extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int count;

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  final Color primaryColor;

  const TravelerCounter({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.onIncrease,
    required this.onDecrease,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border.all(color: const Color(0xFFE3E3E3)),

        borderRadius: BorderRadius.circular(7),
      ),

      padding: const EdgeInsets.symmetric(horizontal: 12),

      child: Row(
        children: [
          // =========================
          // أيقونة الشخص
          // =========================
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F0),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, size: 20, color: primaryColor),
          ),

          const SizedBox(width: 10),

          // =========================
          // النص
          // =========================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),

          // =========================
          // -
          // =========================
          IconButton(
            onPressed: onDecrease,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),

            icon: const Icon(Icons.remove, size: 18, color: Color(0xFF777777)),
          ),

          // =========================
          // العدد
          // =========================
          SizedBox(
            width: 25,
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // =========================
          // +
          // =========================
          IconButton(
            onPressed: onIncrease,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),

            icon: Icon(Icons.add, size: 18, color: primaryColor),
          ),
        ],
      ),
    );
  }
}

class PriceSummaryCard extends StatelessWidget {
  final BookingPriceModel price;
  final int adultsCount;
  final int childrenCount;

  const PriceSummaryCard({
    super.key,
    required this.price,
    required this.adultsCount,
    required this.childrenCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // العنوان
          // =========================
          const Text(
            'ملخص السعر',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          // =========================
          // سعر البالغين
          // =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سعر الباقة',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${adultsCount + 1} بالغين',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

              Text(
                '${price.adultsPrice.toStringAsFixed(0)} \$',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // =========================
          // الأطفال
          // =========================
          if (price.childrenPrice > 0) ...[
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سعر الأطفال',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '$childrenCount أطفال',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                Text(
                  '${price.childrenPrice.toStringAsFixed(0)} \$',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // =========================
          // الخصم
          // =========================
          if (price.discountAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الخصم',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'خصم ${price.discountPercent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                Text(
                  '- ${price.discountAmount.toStringAsFixed(0)} \$',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087443),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          // =========================
          // الخط
          // =========================
          const Divider(),

          const SizedBox(height: 10),

          // =========================
          // السعر النهائي
          // =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'السعر الإجمالي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              Text(
                '${price.totalPrice.toStringAsFixed(0)} \$',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF087443),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            'تم تطبيق جميع الخصومات',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
