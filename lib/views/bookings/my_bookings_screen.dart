import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:umrahapp/views/bookings/widget/booking_card.dart';

import '../booking/payment/payment_screen.dart';
import '../notifications/data/notification_api_service.dart';
import '../notifications/notification_bloc/notification_bloc.dart';
import '../notifications/notification_screen.dart';
import 'data/my_bookings_api_service.dart';
import 'data/models/booking_model.dart';
import 'my_bookings_bloc/my_bookings_bloc.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              MyBookingsBloc(MyBookingsApiService())..add(GetMyBookingsEvent()),
        ),

        BlocProvider<NotificationBloc>(
          lazy: false,
          create: (_) => NotificationBloc(NotificationApiService())
            ..add(GetNotificationsEvent())
            ..add(StartNotificationPollingEvent()),
        ),
      ],
      child: const _MyBookingsView(),
    );
  }
}

class _MyBookingsView extends StatefulWidget {
  const _MyBookingsView();

  @override
  State<_MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<_MyBookingsView> {
  int selectedTab = 0;

  final Set<String> _pendingPaymentBookings = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                _buildHeader(),
                _buildTabs(),
                const SizedBox(height: 12),

                Expanded(
                  child: BlocListener<MyBookingsBloc, MyBookingsState>(
                    listener: (context, state) async {
                      if (!mounted) return;

                      if (state is BookingDetailsLoaded) {
                        final booking = state.booking;

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(booking: booking),
                          ),
                        );

                        if (!mounted) return;


                        if (result == true) {
                          setState(() {
                            _pendingPaymentBookings.add(booking.id);
                          });

                          context.read<MyBookingsBloc>().add(
                            GetMyBookingsEvent(),
                          );
                        }
                      }

                      if (state is MyBookingsError) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },

                    child: BlocBuilder<MyBookingsBloc, MyBookingsState>(
                      builder: (context, state) {
                        if (state is MyBookingsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff186442),
                            ),
                          );
                        }

                        if (state is MyBookingsError) {
                          return _buildError(state.message);
                        }

                        if (state is MyBookingsLoaded) {
                          final bookings = _filterBookings(state.bookings);

                          if (bookings.isEmpty) {
                            return _buildEmptyState();
                          }

                          return RefreshIndicator(
                            color: const Color(0xff186442),
                            onRefresh: () async {
                              context.read<MyBookingsBloc>().add(
                                GetMyBookingsEvent(),
                              );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: bookings.length,
                              itemBuilder: (context, index) {
                                final booking = bookings[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: BookingCard(
                                    booking: booking,

                                    isPaymentPending: _pendingPaymentBookings
                                        .contains(booking.id),

                                    onPayNow: () {
                                      context.read<MyBookingsBloc>().add(
                                        GetBookingDetailsEvent(
                                          bookingId: booking.id,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        children: [
          // ===============================
          // NOTIFICATION BELL
          // ===============================
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int notificationCount = 0;

              if (state is SuccessNotificationState) {
                notificationCount = state.unreadCount;
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () async {
                      final notificationBloc = context.read<NotificationBloc>();

                      notificationBloc.add(ClearNotificationBadgeEvent());

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: notificationBloc,
                            child: const NotificationScreen(),
                          ),
                        ),
                      );

                      if (!mounted) return;

                      notificationBloc.add(GetNotificationsEvent());
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/iconamoon_notification-light.svg',
                      width: 25,
                      height: 25,
                    ),
                  ),

                  // ===============================
                  // RED BADGE
                  // ===============================
                  if (notificationCount > 0)
                    Positioned(
                      right: 4,
                      top: 2,
                      child: Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          notificationCount > 9 ? '9+' : '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const Spacer(),

          const Text(
            'حجوزاتي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff186442),
            ),
          ),

          const Spacer(),


          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTab(title: 'الملغاة', index: 2)),

          Expanded(child: _buildTab(title: 'المكتملة', index: 1)),

          Expanded(child: _buildTab(title: 'القائمة', index: 0)),
        ],
      ),
    );
  }

  Widget _buildTab({required String title, required int index}) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? const Color(0xff0D9B5C)
                    : const Color(0xff000000),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xff0D9B5C)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    // القائمة
    if (selectedTab == 0) {
      return bookings.where((booking) {
        final status = booking.status.toLowerCase();

        return status != 'completed' && status != 'cancelled';
      }).toList();
    }

    // المكتملة فقط
    if (selectedTab == 1) {
      return bookings.where((booking) {
        final status = booking.status.toLowerCase();

        return status == 'completed';
      }).toList();
    }

    // الملغاة فقط
    return bookings.where((booking) {
      final status = booking.status.toLowerCase();

      return status == 'cancelled';
    }).toList();
  }

  Widget _buildEmptyState() {
    String emptyMessage;

    if (selectedTab == 0) {
      emptyMessage = 'لا يوجد حجوزات قائمة';
    } else if (selectedTab == 1) {
      emptyMessage = 'لا يوجد حجوزات مكتملة';
    } else {
      emptyMessage = 'لا يوجد حجوزات ملغاة';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.luggage_outlined, size: 65, color: Colors.grey.shade300),

          const SizedBox(height: 15),

          Text(
            emptyMessage,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 45, color: Colors.grey.shade400),

            const SizedBox(height: 12),

            const Text(
              'تعذر تحميل البيانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                context.read<MyBookingsBloc>().add(GetMyBookingsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
