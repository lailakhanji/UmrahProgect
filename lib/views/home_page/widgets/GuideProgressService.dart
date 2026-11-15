import 'package:shared_preferences/shared_preferences.dart';

class GuideProgressService {
  static const String _completedKey = 'completed_guide_ids';
  static const String _totalStepsKey = 'total_guide_steps';


  static Future<Set<String>> getCompletedGuideIds() async {
    final prefs = await SharedPreferences.getInstance();

    final ids = prefs.getStringList(_completedKey) ?? [];

    return ids.toSet();
  }


  static Future<void> markAsCompleted(String guideId) async {
    if (guideId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final ids = prefs.getStringList(_completedKey) ?? [];

    if (!ids.contains(guideId)) {
      ids.add(guideId);

      await prefs.setStringList(_completedKey, ids);
    }
  }


  static Future<void> saveTotalSteps(int totalSteps) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_totalStepsKey, totalSteps);
  }


  static Future<int> getTotalSteps() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_totalStepsKey) ?? 0;
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_completedKey);
  }
}
