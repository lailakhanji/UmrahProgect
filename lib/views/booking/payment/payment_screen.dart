import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../bookings/data/models/booking_details_model.dart';
import '../../bookings/my_bookings_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingDetailsModel booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  static const Color primaryGreen = Color(0xff186442);

  // ===========================================================
  // إرسال الدفع
  // ===========================================================

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });


    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

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
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'تم إرسال طلب الدفع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'تم إرسال طلب الدفع بنجاح.\n\n'
                'سيتم مراجعة عملية الدفع وتحديث حالة الحجز.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'موافق',
                  style: TextStyle(
                    color: Color(0xff0D9B5C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    // ==========================================================
    // العودة إلى حجوزاتي
    // ==========================================================

    Navigator.pop(context, true);
  }

  // ===========================================================
  // التاريخ
  // ===========================================================

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return months[month];
  }

  // ===========================================================
  // المسافرون
  // ===========================================================

  String _getTravelersText() {
    final adults =
        1 +
        widget.booking.familyMembers.where((member) => member.age >= 18).length;

    final children = widget.booking.familyMembers
        .where((member) => member.age < 18)
        .length;

    final parts = <String>[];

    if (adults > 0) {
      parts.add('$adults بالغ${adults > 1 ? 'ين' : ''}');
    }

    if (children > 0) {
      parts.add('$children طفل${children > 1 ? 'ان' : ''}');
    }

    return parts.join(' و ');
  }

  // ===========================================================
  // Build
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'المراجعة والدفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff186442),
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =================================================
              // ملخص الرحلة
              // =================================================
              const Text(
                'ملخص الرحلة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(40),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _summaryRow(
                      icon: SvgPicture.asset('assets/icons/mdi_location.svg'),
                      title: 'الوجهة',
                      value: booking.arrivalCity ?? '----',
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      icon: SvgPicture.asset('assets/icons/flight.svg'),
                      title: 'عدد الأيام',
                      value:
                          '${booking.tripEndDate.difference(booking.tripStartDate).inDays + 1} يوم',
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      icon: SvgPicture.asset(
                        'assets/icons/akar-icons_calendar.svg',
                      ),
                      title: 'تاريخ الانطلاق',
                      value: _formatDate(booking.tripStartDate),
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      icon: SvgPicture.asset(
                        'assets/icons/griddy-icons_time.svg',
                      ),
                      title: 'ساعة الانطلاق',
                      value: _formatTime(booking.tripStartDate),
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      icon: SvgPicture.asset('assets/icons/group.svg'),
                      title: 'عدد المسافرون',
                      value: _getTravelersText(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // المبلغ الإجمالي
              // =================================================
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 248, 238, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المبلغ الإجمالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${booking.totalAmount.toStringAsFixed(0)}\$',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff0D9B5C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // طريقة الدفع
              // =================================================
              const Text(
                'طريقة الدفع',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(40),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xff0D9B5C),
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Text(
                            'الدفع بواسطة Sham Cash',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.check_circle,
                          color: Color(0xff0D9B5C),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'امسح رمز QR أدناه باستخدام تطبيق Sham Cash لإتمام عملية الدفع.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/Qr.jpg',
                        height: 150,
                        width: 150,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // زر الدفع
              // =================================================
              ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'تم الدفع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // الوقت
  // ===========================================================

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ===========================================================
  // Summary Row
  // ===========================================================

  Widget _summaryRow({
    required Widget icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(width: 24, height: 24, child: icon),

        const SizedBox(width: 20),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),

              const Spacer(),

              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
