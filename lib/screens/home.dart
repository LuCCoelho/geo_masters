import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game.dart';
import '../widgets/app_bar.dart';
import '../providers/highest_score.provider.dart';
import '../providers/highest_streak.provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.lastHighestStreak,
    required this.lastScore,
    required this.data,
  });

  final String title;
  final int lastHighestStreak;
  final int lastScore;
  final List<dynamic> data;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final highestScoreProvider = Provider.of<HighestScoreProvider>(context);
    final highestStreakProvider = Provider.of<HighestStreakProvider>(context);

    return Scaffold(
      appBar: getAppBar(context, widget.title),
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
                          highestScoreProvider.highestScore.toString(),
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
                          highestStreakProvider.highestStreak.toString(),
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
                  MaterialPageRoute(
                    builder: (context) => GameScreen(data: widget.data),
                  ),
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
