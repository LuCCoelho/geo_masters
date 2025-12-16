import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'supabase_provider.dart';
part 'leaderboard.provider.g.dart';

@riverpod
class LeaderboardData extends _$LeaderboardData {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final supabase = ref.watch(supabaseProvider);
    try {
      final profiles = await supabase
          .from('profiles')
          .select()
          .order('highest_score', ascending: false);

      final List<Map<String, dynamic>> leaderboardData = [];

      for (var profile in profiles) {

        final userId = profile['id'] as String?;

        if (userId != null) {
          final res = await supabase.auth.admin.getUserById(userId);
          final user = res.user;

          leaderboardData.add({
            'id': userId,
            'email': user?.email as String,
            'highest_score': profile['highest_score'] as int,
            'highest_streak': profile['highest_streak'] as int,
          });
        }
      }

      return leaderboardData;
    } catch (e) {
      // Fallback: return profiles with user ID as identifier
      final profiles = await supabase
          .from('profiles')
          .select()
          .order('highest_score', ascending: false);

      return profiles.map((profile) {
        final userId = profile['id'] as String? ?? '';
        return {
          'id': userId,
          'email': userId.isNotEmpty
              ? 'User ${userId.substring(0, 8)}...'
              : 'Unknown',
          'highest_score': profile['highest_score'] as int? ?? 0,
          'highest_streak': profile['highest_streak'] as int? ?? 0,
        };
      }).toList();
    }
  }
}
