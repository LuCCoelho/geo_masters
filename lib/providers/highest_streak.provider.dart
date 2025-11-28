import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'highest_streak.provider.g.dart';

@riverpod
class HighestStreak extends _$HighestStreak {
  static const String _key = 'highest_streak';

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> updateHighestStreak(int newStreak) async {
    // Ensure we have the latest value from storage
    final prefs = await SharedPreferences.getInstance();
    final storedStreak = prefs.getInt(_key) ?? 0;
    final currentStreak = state.value ?? 0;

    // Get the maximum of stored and current state
    final maxStreak = storedStreak > currentStreak
        ? storedStreak
        : currentStreak;

    // Only update if new streak is higher
    if (newStreak > maxStreak) {
      await prefs.setInt(_key, newStreak);
      state = AsyncValue.data(newStreak);
    } else if (storedStreak > currentStreak) {
      // Update state if stored value is higher than current state
      state = AsyncValue.data(storedStreak);
    }
  }
}
