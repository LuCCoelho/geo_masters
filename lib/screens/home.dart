import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_bar.dart';
import '../providers/highest_score.provider.dart';
import '../providers/highest_streak.provider.dart';
import '../providers/auth_provider.dart';
import '../screens/game.dart';
import '../screens/login.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.lastHighestStreak,
    required this.lastScore,
  });

  final String title;
  final int lastHighestStreak;
  final int lastScore;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final highestScoreAsync = ref.watch(highestScoreProvider);
    final highestStreakAsync = ref.watch(highestStreakProvider);

    final highestScore = highestScoreAsync.value ?? 0;
    final highestStreak = highestStreakAsync.value ?? 0;

    return Scaffold(
      appBar: getAppBar(context, widget.title, ref),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 60,
          children: [
            Column(
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Highest Score',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          highestScore.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Highest Streak',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          highestStreak.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Last Score',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          widget.lastScore.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Last Streak',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          widget.lastHighestStreak.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                fixedSize: Size(200, 50),
              ),
              child: Text('Play', style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}
