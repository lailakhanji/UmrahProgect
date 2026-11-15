import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/shared_preferances_service.dart';
import 'data/my_bookings_api_service.dart';
import 'data/models/booking_details_model.dart';
import 'my_bookings_bloc/my_bookings_bloc.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MyBookingsBloc(MyBookingsApiService())
            ..add(GetBookingDetailsEvent(bookingId: bookingId)),
      child: _BookingDetailsView(bookingId: bookingId),
    );
  }
}

class _BookingDetailsView extends StatelessWidget {
  final String bookingId;

  const _BookingDetailsView({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyBookingsBloc, MyBookingsState>(
      listener: (context, state) {
        if (state is BookingCancelled) {
          Navigator.pop(context, true);
        }

        if (state is MyBookingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<MyBookingsBloc, MyBookingsState>(
            builder: (context, state) {
              if (state is BookingDetailsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xff0D9B5C)),
                );
              }

              if (state is MyBookingsError) {
                return _buildError(context, state.message);
              }

              if (state is BookingDetailsLoaded) {
                return _buildContent(context, state.booking);
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  double _hotelPrice(BookingDetailsModel booking) {
    if (booking.hotel == null) {
      return 0;
    }

    return booking.hotel!.pricePerNight;
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(BuildContext context, BookingDetailsModel booking) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  _buildTripInfo(booking),

                  const SizedBox(height: 14),

                  _buildDetailsList(context, booking),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
      child: const Align(
        alignment: Alignment.center,
        child: Text(
          'تفاصيل الحجز',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xff186442),
          ),
        ),
      ),
    );
  }

  Widget _buildTripInfo(BookingDetailsModel booking) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: double.infinity,
            height: 143,
            child: Image.asset(
              'assets/images/booking_details.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          booking.bookingNumber,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 5),

        Text(
          _buildCities(booking),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '${_formatDate(booking.tripStartDate)} - '
          '${_formatDate(booking.tripEndDate)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
        ),

        SizedBox(height: 24),
      ],
    );
  }

  // ============================================================
  // DETAILS LIST
  // ============================================================

  Widget _buildDetailsList(BuildContext context, BookingDetailsModel booking) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffE4E8E6)),
      ),
      child: Column(
        children: [
          // ----------------------------------------------------
          // المسافرون
          // ----------------------------------------------------
          _buildDetailItem(
            title: 'المسافرون',
            onTap: () {
              _showTravelers(context, booking);
            },
          ),

          _buildDivider(),

          // ----------------------------------------------------
          // الفنادق
          // ----------------------------------------------------
          _buildDetailItem(
            title: 'فندق مكة',
            onTap: () {
              _showHotels(context, booking);
            },
          ),

          _buildDivider(),

          // ----------------------------------------------------
          // الفاتورة
          // ----------------------------------------------------
          _buildDetailItem(
            title: 'الفاتورة',
            onTap: () {
              _showInvoice(context, booking);
            },
          ),

          _buildDivider(),

          // ----------------------------------------------------
          // التقييم
          // ----------------------------------------------------
          _buildDetailItem(
            title: 'التقييم',
            onTap: () {
              _showRatingBottomSheet(context, booking);
            },
          ),

          // ----------------------------------------------------
          // إلغاء الحجز
          // ----------------------------------------------------
          if (booking.status.toLowerCase() == 'pending') ...[
            _buildDivider(),

            _buildDetailItem(
              title: 'إلغاء الحجز',
              titleColor: Colors.red.shade600,
              iconColor: Colors.red.shade600,
              onTap: () {
                _showCancelDialog(context, booking);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: titleColor ?? const Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
              ),

              if (trailing != null)
                trailing
              else if (onTap != null)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.chevron_left,
                    size: 24,
                    color: iconColor ?? const Color(0xff777777),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 10,
      endIndent: 10,
      color: Color(0xffEEEEEE),
    );
  }

  // ============================================================
  // PAYMENT STATUS
  // ============================================================

  Widget _paymentStatus(String status) {
    final isPaid = status.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xffDDF7E9) : const Color(0xffFFF2D8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPaid ? 'مدفوع' : 'بانتظار الدفع',
        style: TextStyle(
          fontSize: 9,
          color: isPaid ? const Color(0xff168653) : const Color(0xffC58A16),
        ),
      ),
    );
  }

  // ============================================================
  // TRAVELERS BOTTOM SHEET
  // ============================================================

  void _showTravelers(BuildContext context, BookingDetailsModel booking) {
    final userName = SharedPreferancesService.name ?? 'صاحب الحجز';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSheetHandle(),

                  const SizedBox(height: 30),

                  const Text(
                    'المسافرون',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff222222),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffE4E8E6)),
                    ),
                    child: Column(
                      children: [
                        // ========================================
                        // صاحب الحجز
                        // ========================================
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/lets-icons_user-light.svg',
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    const Text(
                                      'صاحب الحجز',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color.fromRGBO(0, 0, 0, 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ========================================
                        // أفراد العائلة
                        // ========================================
                        ...booking.familyMembers.map((member) {
                          return Column(
                            children: [
                              const Divider(
                                height: 1,
                                color: Color(0xffEEEEEE),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/lets-icons_user-light.svg',
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                          const SizedBox(height: 3),

                                          Text(
                                            member.age < 18 ? 'طفل' : 'بالغ',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.5,
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
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildCloseButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HOTELS BOTTOM SHEET
  // ============================================================

  void _showHotels(BuildContext context, BookingDetailsModel booking) {
    final hotel = booking.hotel;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSheetHandle(),

                  const SizedBox(height: 30),

                  const Text(
                    'فندق مكة ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff222222),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (hotel == null)
                    _buildEmptySheet('لا توجد معلومات عن الفندق')
                  else
                    _buildHotelCard(hotel),

                  const SizedBox(height: 18),

                  _buildCloseButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotelCard(dynamic hotel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffE4E8E6)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  width: 107,
                  height: 90,
                  child: hotel.imageUrl.isNotEmpty
                      ? Image.network(
                          hotel.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Image.asset(
                              'assets/images/booking_details.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/booking_details.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: List.generate(
                        hotel.starsRating,
                        (_) => const Icon(
                          Icons.star,
                          size: 20,
                          color: Color(0xffF6C343),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'يبعد ${hotel.distanceFromHaram} متر عن الحرم',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInvoice(BuildContext context, BookingDetailsModel booking) {
    // صاحب الحجز + أفراد العائلة
    final int travelersCount = booking.familyMembers.length + 1;

    // الـ API يعيد basePrice كسعر الشخص الواحد
    final double pricePerPerson = booking.basePrice;

    // السعر الأساسي قبل الحسم
    final double beforeDiscount = pricePerPerson * travelersCount;

    // الإجمالي الحقيقي النهائي القادم من الـ API
    final double totalAfterDiscount = booking.totalAmount;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSheetHandle(),

                  const SizedBox(height: 30),

                  const Text(
                    'الفاتورة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff222222),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffE4E8E6)),
                    ),
                    child: Column(
                      children: [
                        // ==================================
                        // سعر الشخص الواحد
                        // ==================================
                        _buildInvoiceRow(
                          title: 'سعر الباقة',
                          subtitle: '(للشخص الواحد)',
                          value: '${pricePerPerson.toStringAsFixed(0)} \$',
                        ),

                        const SizedBox(height: 16),

                        // ==================================
                        // سعر الباقة حسب عدد المسافرين
                        // ==================================
                        _buildInvoiceRow(
                          title: 'إجمالي الباقة',
                          subtitle: '($travelersCount مسافرين)',
                          value: '${beforeDiscount.toStringAsFixed(0)} \$',
                        ),

                        const SizedBox(height: 16),

                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xffEEEEEE),
                        ),

                        const SizedBox(height: 14),

                        // ==================================
                        // الإجمالي النهائي
                        // ==================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'السعر بعد الحسم',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff222222),
                              ),
                            ),

                            Text(
                              '${totalAfterDiscount.toStringAsFixed(0)} \$',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff087443),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildCloseButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceRow({
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xff777777),
              ),
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),
            ],
          ],
        ),

        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM SHEET HELPERS
  // ============================================================

  Widget _buildSheetHandle() {
    return Container(
      width: 28,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xffD7D7D7),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff186442),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: const Text(
          'إغلاق',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildEmptySheet(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffE4E8E6)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: Color(0xff777777)),
      ),
    );
  }

  // ============================================================
  // RATING
  // ============================================================
  void _showRatingBottomSheet(
    BuildContext context,
    BookingDetailsModel booking,
  ) {
    int selectedRating = 0;
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // يضمن عدم اختفاء الشيت خلف لوحة المفاتيح
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.only(
                  top: 12,
                  left: 24,
                  right: 24,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      24, // للتعامل مع لوحة المفاتيح
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // المؤشر العلوي الرمادي الصغير للشيت
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // العنوان
                    const Text(
                      'تقييم الرحلة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // النص الفرعي
                    Text(
                      'شارك رأيك لمساعدتنا على التحسين',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // صف النجوم مع النص الجانبي (تقييم)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Text(
                            'تقييم',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRating = index + 1;
                                  });
                                },
                                child: index < selectedRating
                                    ? SvgPicture.asset(
                                        'assets/icons/noto_star (1).svg',
                                        width: 32,
                                        // تحديد الحجم المناسب للـ SVG بدلاً من size الخاص بالـ Icon
                                        height: 32,
                                      )
                                    : const Icon(
                                        Icons.star_outline,
                                        color: Color.fromRGBO(244, 180, 0, 1),
                                        size: 32,
                                      ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // عنوان حقل الملاحظات
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: const Text(
                        'ملاحظتك (اختياري)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // حقل إدخال النص مع العداد الداخلي
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      maxLength: 300,
                      onChanged: (text) {
                        setState(() {}); // لتحديث عداد الحروف الحالي (0/300)
                      },
                      decoration: InputDecoration(
                        hintText: 'اكتب ملاحظتك هنا...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        // تخصيص العداد ليطابق التصميم بدقة
                        counterText: '${commentController.text.length}/300',
                        counterStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF145334),
                          ), // لون أخضر داكن عند التركيز
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // زر إرسال (يأخذ العرض الكامل واللون الأخضر للتصميم)
                    ElevatedButton(
                      onPressed: selectedRating == 0
                          ? null
                          : () async {
                              final userId =
                                  await SharedPreferancesService.userId;

                              if (userId == null || userId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تعذر تحديد المستخدم'),
                                  ),
                                );
                                return;
                              }

                              try {
                                final apiService = MyBookingsApiService();

                                await apiService.addReview(
                                  tripId: booking.tripId,
                                  rating: selectedRating,
                                  comment: commentController.text.trim(),
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم إرسال تقييمك بنجاح'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint(
                                  '================ REVIEW ERROR ================',
                                );
                                debugPrint('$e');
                                debugPrint('TRIP ID: ${booking.tripId}');
                                debugPrint(
                                  'USER ID: ${SharedPreferancesService.userId}',
                                );
                                debugPrint('RATING: $selectedRating');
                                debugPrint(
                                  'COMMENT: ${commentController.text.trim()}',
                                );
                                debugPrint(
                                  '==============================================',
                                );

                                String message = 'تعذر إرسال التقييم';
                                bool alreadyReviewed = false;

                                if (e is DioException) {
                                  final data = e.response?.data;

                                  if (data is Map) {
                                    final serverMessage =
                                        data['message']?.toString() ??
                                        data['title']?.toString() ??
                                        data['detail']?.toString() ??
                                        '';

                                    if (e.response?.statusCode == 409 ||
                                        serverMessage.contains(
                                          'التقييم موجود بالفعل',
                                        )) {
                                      alreadyReviewed = true;
                                    } else if (serverMessage.isNotEmpty) {
                                      message = serverMessage;
                                    }
                                  }
                                }

                                if (context.mounted) {
                                  if (alreadyReviewed) {
                                    Navigator.pop(context);

                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                  24,
                                                  24,
                                                  24,
                                                  16,
                                                ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 64,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xffE1F5E9,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.star_rounded,
                                                    color: Color(0xff0D985A),
                                                    size: 38,
                                                  ),
                                                ),

                                                const SizedBox(height: 18),

                                                const Text(
                                                  'تم تقييم الرحلة مسبقًا',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xff222222),
                                                  ),
                                                ),

                                                const SizedBox(height: 10),

                                                const Text(
                                                  'لقد قمت بإرسال تقييم لهذه الرحلة من قبل، ولا يمكنك تقييم الرحلة مرة أخرى.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    height: 1.5,
                                                    color: Color.fromRGBO(
                                                      0,
                                                      0,
                                                      0,
                                                      0.55,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 22),

                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 44,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                        dialogContext,
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xff186442,
                                                          ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'حسنًا',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF145334),
                        // نفس درجة اللون الأخضر في الصورة
                        disabledBackgroundColor: const Color(
                          0xFF145334,
                        ).withOpacity(0.5),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'إرسال',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  void _showCancelDialog(BuildContext context, BookingDetailsModel booking) {
    showDialog(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Center(
              child: const Text(
                'إلغاء الحجز',
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            content: const Text(
              'هل أنت متأكد من أنك تريد إلغاء هذا الحجز؟',
              style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(207, 35, 42, 1),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);

                  context.read<MyBookingsBloc>().add(
                    CancelBookingEvent(bookingId: booking.id),
                  );
                },
                child: const Text('إلغاء الحجز'),
              ),
              SizedBox(width: 60),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'عودة',
                  style: TextStyle(color: Color.fromRGBO(207, 35, 42, 1)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _buildCities(BookingDetailsModel booking) {
    if (booking.departureCity != null && booking.arrivalCity != null) {
      return '${booking.departureCity} - '
          '${booking.arrivalCity}';
    }

    return booking.tripTitle;
  }

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

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 45),

          const SizedBox(height: 10),

          const Text(
            'حدث خطأ أثناء تحميل تفاصيل الحجز',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(message, textAlign: TextAlign.center),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: () {
              context.read<MyBookingsBloc>().add(
                GetBookingDetailsEvent(bookingId: bookingId),
              );
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
