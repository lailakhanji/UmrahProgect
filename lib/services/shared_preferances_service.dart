import 'package:shared_preferences/shared_preferences.dart';
class SharedPreferancesService {
  static late  final SharedPreferences _sharedPreferances;
static void init() async{
_sharedPreferances=await SharedPreferences.getInstance();
}
  static final String isTheOnBoardingScreenSeenKey='isTheOnBoardingScreenSeen';
  static final String tokenKey='token';
  static const String nameKey = 'name';
 static bool get isTheOnBoardingScreenSeen=>_sharedPreferances.getBool(isTheOnBoardingScreenSeenKey)??false;
  static set isTheOnboardingScreenSeen(bool value)=>_sharedPreferances.setBool(isTheOnBoardingScreenSeenKey, value);
  static String? get token=>_sharedPreferances.getString(tokenKey);
  static set token(String? value)=>_sharedPreferances.setString(tokenKey, value??'');
  static set name(String value) =>
      _sharedPreferances.setString(nameKey, value);

  static String? get name =>
      _sharedPreferances.getString(nameKey);
}
