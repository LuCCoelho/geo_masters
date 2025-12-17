import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_provider.dart';
import 'supabase_provider.dart';

part 'profile.provider.g.dart';

@riverpod
class ProfileData extends _$ProfileData {
  @override
  Future<Map<String, dynamic>?> build() async {
    // Watch auth state to automatically refresh when user signs in/out
    // This ensures the provider rebuilds when auth state changes
    final authStateAsync = ref.watch(authStateProvider);
    authStateAsync.whenData((_) {}); // Ensure we're subscribed to auth changes

    final supabase = ref.watch(supabaseProvider);

    // Get the current user ID
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint('Profile provider: No user ID found');
      return null;
    }

    debugPrint('Profile provider: Fetching profile for user: $userId');

    try {
      // Fetch provider data for the current user
      var response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      debugPrint(
        'Profile provider: Existing profile found: ${response != null}',
      );

      // If the user is not found, create a new row
      if (response == null) {
        debugPrint('Profile provider: Creating new profile for user: $userId');
        try {
          response = await supabase
              .from('profiles')
              .insert({'id': userId, 'highest_score': 0, 'highest_streak': 0})
              .select()
              .single();
          debugPrint(
            'Profile provider: Successfully created profile: $response',
          );
        } catch (e) {
          debugPrint('Profile provider: Error creating profile: $e');
          rethrow;
        }
      }

      return response;
    } catch (e) {
      debugPrint('Profile provider: Error fetching/creating profile: $e');
      rethrow;
    }
  }

  Future<void> updateHighestScore(int newScore) async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint('Profile provider: Cannot update score - no user ID');
      return;
    }

    final currentData = state.value;
    final currentScore = currentData?['highest_score'] as int? ?? 0;

    if (newScore > currentScore) {
      try {
        final updated = await supabase
            .from('profiles')
            .update({'highest_score': newScore})
            .eq('id', userId)
            .select()
            .single();

        state = AsyncValue.data(updated);
        debugPrint('Profile provider: Updated highest score to $newScore');
        debugPrint('Profile provider: Updated data: $updated');
      } catch (e) {
        debugPrint('Profile provider: Error updating highest score: $e');
        ref.invalidateSelf();
        rethrow;
      }
    }
  }

  Future<void> updateHighestStreak(int newStreak) async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint('Profile provider: Cannot update streak - no user ID');
      return;
    }

    final currentData = state.value;
    final currentStreak = currentData?['highest_streak'] as int? ?? 0;

    if (newStreak > currentStreak) {
      try {
        final updated = await supabase
            .from('profiles')
            .update({'highest_streak': newStreak})
            .eq('id', userId)
            .select()
            .single();

        state = AsyncValue.data(updated);
        debugPrint('Profile provider: Updated highest streak to $newStreak');
        debugPrint('Profile provider: Updated data: $updated');
      } catch (e) {
        debugPrint('Profile provider: Error updating highest streak: $e');
        ref.invalidateSelf();
        rethrow;
      }
    }
  }
}
