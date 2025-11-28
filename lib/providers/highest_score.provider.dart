import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighestScoreProvider with ChangeNotifier {
  int _highestScore = 0;
  static const String _key = 'highest_score';

  int get highestScore => _highestScore;

  HighestScoreProvider() {
    _loadHighestScore();
  }

  Future<void> _loadHighestScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highestScore = prefs.getInt(_key) ?? 0;
    notifyListeners();
  }

  Future<void> updateHighestScore(int newScore) async {
    // Ensure we have the latest value from storage
    final prefs = await SharedPreferences.getInstance();
    final storedScore = prefs.getInt(_key) ?? 0;
    if (storedScore > _highestScore) {
      _highestScore = storedScore;
    }

    // Only update if new score is higher
    if (newScore > _highestScore) {
      _highestScore = newScore;
      await prefs.setInt(_key, _highestScore);
      notifyListeners();
    }
  }
}
