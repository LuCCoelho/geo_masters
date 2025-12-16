import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_provider.dart';
import 'supabase_provider.dart';

part 'profile.provider.g.dart';

@riverpod
Future<Map<String, dynamic>?> profileData(Ref ref) async {
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

    debugPrint('Profile provider: Existing profile found: ${response != null}');

    // If the user is not found, create a new row
    if (response == null) {
      debugPrint('Profile provider: Creating new profile for user: $userId');
      try {
        response = await supabase
            .from('profiles')
            .insert({'id': userId})
            .select()
            .single();
        debugPrint('Profile provider: Successfully created profile: $response');
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
