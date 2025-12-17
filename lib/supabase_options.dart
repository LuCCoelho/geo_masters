import 'package:flutter_dotenv/flutter_dotenv.dart';

Map<Symbol, dynamic> supabaseOptions = {
  #url: dotenv.env['SUPABASE_URL'] ?? '',
  #anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
};
