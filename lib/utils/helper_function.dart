import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HelperFunction {
  static void navigateAndReplaceScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static Future<bool> hasInternetConnection() async {
    final List<ConnectivityResult> connectivityResault = await Connectivity()
        .checkConnectivity();
    return connectivityResault.first != ConnectivityResult.none;
  }
}
