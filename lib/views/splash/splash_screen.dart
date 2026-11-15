import 'package:flutter/material.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/authentication/auth_screen.dart';
import 'package:umrahapp/views/home_page/bottom_navigation_bar_screen.dart';
import 'package:umrahapp/views/home_page/home_screen.dart';
import 'package:umrahapp/views/on_boarding/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      bool onBoardingScreenSeen =
          SharedPreferancesService.isTheOnBoardingScreenSeen;
      String? token = SharedPreferancesService.token;
      HelperFunction.navigateAndReplaceScreen(
        context,
        onBoardingScreenSeen
            ? token != null
                  ? BottomNavigationBarScreen()
                  : AuthScreen(isForLogin: true)
            : OnBoardingScreen(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(239, 250, 243, 1),
        child: Center(child: Image.asset('assets/images/logo.png')),
      ),
    );
  }
}
