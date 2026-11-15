import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferancesService {
  static late final SharedPreferences _sharedPreferances;

  static Future<void> init() async {
    _sharedPreferances = await SharedPreferences.getInstance();
  }

  static const String isTheOnBoardingScreenSeenKey =
      'isTheOnBoardingScreenSeen';

  static const String tokenKey = 'token';
  static const String nameKey = 'name';
  static const String userIdKey = 'userId';

  static bool get isTheOnBoardingScreenSeen =>
      _sharedPreferances.getBool(isTheOnBoardingScreenSeenKey) ?? false;

  static set isTheOnBoardingScreenSeen(bool value) =>
      _sharedPreferances.setBool(isTheOnBoardingScreenSeenKey, value);

  static String? get token {
    final token = _sharedPreferances.getString(tokenKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    return token;
  }

  static set token(String? value) =>
      _sharedPreferances.setString(tokenKey, value ?? '');

  static set name(String value) => _sharedPreferances.setString(nameKey, value);

  static String? get name => _sharedPreferances.getString(nameKey);

  // =========================
  // User ID
  // =========================

  static String? get userId => _sharedPreferances.getString(userIdKey);

  static set userId(String? value) =>
      _sharedPreferances.setString(userIdKey, value ?? '');
}
