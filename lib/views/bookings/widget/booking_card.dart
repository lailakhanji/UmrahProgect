import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bookings_details_screen.dart';
import '../data/models/booking_model.dart';
import '../my_bookings_bloc/my_bookings_bloc.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onPayNow;
  final bool isPaymentPending;

  const BookingCard({
    super.key,
    required this.booking,
    this.onPayNow,
    this.isPaymentPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final String status = booking.status.toLowerCase();
    final String paymentStatus = booking.paymentStatus.toLowerCase();

    final bool isPaid = paymentStatus == 'paid';

    final bool shouldShowPayButton =
        status == 'confirmed' && !isPaid && !isPaymentPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffE1E8E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatus(),
              Text(
                'CP-2026-${booking.id.length >= 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                booking.bookingType == 'Package' ? 'حجز باقة' : 'حجز مخصص',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatDate(booking.bookingDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${booking.familyMembersCount + 1} : عدد المسافرين',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),
            ],
          ),

          const Divider(height: 22, color: Color(0xffEEEEEE)),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$ ${booking.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailsScreen(bookingId: booking.id),
                      ),
                    );

                    if (result == true && context.mounted) {
                      context.read<MyBookingsBloc>().add(GetMyBookingsEvent());
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Text(
                          'عرض التفاصيل',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff0D9B5C),
                          ),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 12,
                            color: Color(0xff0D9B5C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (shouldShowPayButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onPayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff186442),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ادفع الآن',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],

          if (isPaymentPending && !isPaid) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffBDBDBD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'بانتظار تأكيد الدفع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          if (isPaid) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xff0D9B5C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'تم الدفع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatus() {
    final status = booking.status.toLowerCase();

    String text;
    Color background;
    Color foreground;

    if (status == 'pending') {
      text = 'قيد الانتظار';
      background = const Color.fromRGBO(253, 238, 215, 0.8);
      foreground = const Color(0xffBC8123);
    } else if (status == 'confirmed') {
      text = 'مؤكد';
      background = const Color(0xffE1F5E9);
      foreground = const Color(0xff0D985A);
    } else if (status == 'completed') {
      text = 'مكتمل';
      background = const Color.fromRGBO(202, 248, 219, 0.8);
      foreground = const Color(0xff0D985A);
    } else if (status == 'cancelled') {
      text = 'ملغي';
      background = const Color(0xffffe4e4);
      foreground = const Color(0xffCF232A);
    } else {
      text = booking.status;
      background = const Color(0xffEAF0ED);
      foreground = const Color(0xff555555);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
