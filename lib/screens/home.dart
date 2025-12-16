import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/app_bar.dart';
import '../providers/profile.provider.dart';
import '../screens/game.dart';
import '../screens/leadboard.dart';
import '../screens/friends_room.dart';

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
    final profileDataAsync = ref.watch(profileDataProvider);

    // Extract highest score from profile data
    final highestScore = profileDataAsync.value?['highest_score'] ?? 0;
    final highestStreak = profileDataAsync.value?['highest_streak'] ?? 0;

    return Scaffold(
      appBar: getAppBar(context, widget.title, ref, showDropdown: true),
      body: Stack(
        children: [
          // Centered content (statistics and Play button)
          Center(
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
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    fixedSize: Size(200, 50),
                  ),
                  child: Text(
                    'Play',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          // Trophy positioned in top right
          Positioned(
            top: 20,
            right: 10,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
              icon: Icon(FontAwesomeIcons.trophy, color: Colors.amber),
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendsRoomScreen(),
                  ),
                );
              },
              icon: Icon(
                FontAwesomeIcons.users,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
