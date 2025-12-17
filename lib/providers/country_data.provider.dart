import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'supabase_provider.dart';

part 'country_data.provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> countryData(Ref ref) async {
  final supabase = ref.watch(supabaseProvider);

  // Fetch country data from Supabase
  final response = await supabase.from('countries_v2').select();

  return List<Map<String, dynamic>>.from(response);
}
