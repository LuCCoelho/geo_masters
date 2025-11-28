import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/theme.provider.dart';
import 'providers/highest_score.provider.dart';
import 'providers/highest_streak.provider.dart';
import 'screens/open.dart';

List<dynamic> data = [];

void main() async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  data = await Supabase.instance.client.from('countries').select();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HighestScoreProvider()),
        ChangeNotifierProvider(create: (_) => HighestStreakProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Geo Masters',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Colors.blue[200],
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black),
                  fixedSize: Size(200, 50),
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                bodyMedium: TextStyle(color: Colors.black, fontSize: 20),
                bodySmall: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color.fromARGB(255, 19, 44, 81),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  fixedSize: Size(200, 50),
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                bodyMedium: TextStyle(color: Colors.white, fontSize: 20),
                bodySmall: TextStyle(color: Colors.white),
              ),
            ),
              home: OpenScreen(data: data),
          );
        },
      ),
    );
  }
}
