import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighestStreakProvider with ChangeNotifier {
  int _highestStreak = 0;
  static const String _key = 'highest_streak';

  int get highestStreak => _highestStreak;

  HighestStreakProvider() {
    _loadHighestStreak();
  }

  Future<void> _loadHighestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _highestStreak = prefs.getInt(_key) ?? 0;
    notifyListeners();
  }

  Future<void> updateHighestStreak(int newStreak) async {
    // Ensure we have the latest value from storage
    final prefs = await SharedPreferences.getInstance();
    final storedStreak = prefs.getInt(_key) ?? 0;
    if (storedStreak > _highestStreak) {
      _highestStreak = storedStreak;
    }

    // Only update if new streak is higher
    if (newStreak > _highestStreak) {
      _highestStreak = newStreak;
      await prefs.setInt(_key, _highestStreak);
      notifyListeners();
    }
  }
}
