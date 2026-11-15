import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:umrahapp/views/guid/guide_screen.dart';
import 'package:umrahapp/views/home_page/trip_planning_screen.dart';

import '../bookings/my_bookings_screen.dart';
import '../duaa/nots_screen.dart';
import 'home_screen.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationBarScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  late int currentIndex;

  String userName = "";
  bool isLoading = true;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  List<Widget> pages = [];

  static const Color primaryGreen = Color(0xff186442);

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('name') ?? "زائر";

      pages = [

        HomeScreen(key: _homeKey, name: userName, onNavigate: _onItemTapped),


        const TripPlanningScreen(),


        GuideScreen(
          onBack: () {
            _onItemTapped(0);
          },
        ),
        const NotesScreen(),

        const MyBookingsScreen(),
      ];

      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _homeKey.currentState?.refreshGuideProgress();
    }

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    return PopScope(
      canPop: currentIndex == 0,

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
        }
      },

      child: Scaffold(
        body: pages[currentIndex],

        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 60,
            decoration: const BoxDecoration(color: Colors.white),

            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _buildNavItem(
                  index: 0,
                  iconPath: 'assets/icons/home (1).svg',
                  label: 'الرئيسية',
                ),

                _buildNavItem(
                  index: 1,
                  iconPath: 'assets/icons/booking.svg',
                  label: 'الحجز',
                ),

                _buildNavItem(
                  index: 2,
                  iconPath: 'assets/icons/guide.svg',
                  label: 'الدليل',
                ),

                _buildNavItem(
                  index: 3,
                  iconPath: 'assets/icons/hugeicons_note-04 (1).svg',
                  label: 'ملاحظات',
                ),

                _buildNavItem(
                  index: 4,
                  iconPath: 'assets/icons/mynaui_calendar-check-solid.svg',
                  label: 'حجوزاتي',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),

        splashColor: primaryGreen.withOpacity(0.08),

        highlightColor: primaryGreen.withOpacity(0.04),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SvgPicture.asset(
              iconPath,

              width: 20,
              height: 20,

              colorFilter: ColorFilter.mode(
                isSelected ? primaryGreen : const Color(0xFF6F7378),
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,

              style: TextStyle(
                fontSize: 12,

                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,

                color: isSelected ? primaryGreen : const Color(0xFF6F7378),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
