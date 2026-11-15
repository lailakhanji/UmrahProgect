import 'package:shared_preferences/shared_preferences.dart';

class PaidTripsService {
  static const String _key = 'paid_trip_ids';

  static Future<List<String>> getPaidTripIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<bool> hasPaidTrip(String tripId) async {
    if (tripId.isEmpty) return false;

    final ids = await getPaidTripIds();
    return ids.contains(tripId);
  }

  static Future<void> savePaidTrip(String tripId) async {
    if (tripId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final ids = prefs.getStringList(_key) ?? [];

    if (!ids.contains(tripId)) {
      ids.add(tripId);
      await prefs.setStringList(_key, ids);
    }
  }
}
