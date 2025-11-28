import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'highest_score.provider.g.dart';

@riverpod
class HighestScore extends _$HighestScore {
  static const String _key = 'highest_score';

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> updateHighestScore(int newScore) async {
    // Ensure we have the latest value from storage
    final prefs = await SharedPreferences.getInstance();
    final storedScore = prefs.getInt(_key) ?? 0;
    final currentScore = state.value ?? 0;

    // Get the maximum of stored and current state
    final maxScore = storedScore > currentScore ? storedScore : currentScore;

    // Only update if new score is higher
    if (newScore > maxScore) {
      await prefs.setInt(_key, newScore);
      state = AsyncValue.data(newScore);
    } else if (storedScore > currentScore) {
      // Update state if stored value is higher than current state
      state = AsyncValue.data(storedScore);
    }
  }
}
