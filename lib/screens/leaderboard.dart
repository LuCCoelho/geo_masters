import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_bar.dart';
import '../providers/leaderboard.provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardDataProvider);

    return Scaffold(
      appBar: getAppBar(context, 'Leaderboard', ref, showDropdown: true),
      body: Stack(
        children: [
          leaderboardAsync.when(
            data: (leaderboardData) {
              if (leaderboardData.isEmpty) {
                return Center(
                  child: Text(
                    'No players yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: leaderboardData.length,
                itemBuilder: (context, index) {
                  final entry = leaderboardData[index];
                  final rank = index + 1;
                  final email = entry['email'] as String? ?? 'Unknown';
                  final highestScore = entry['highest_score'] as int? ?? 0;
                  final highestStreak = entry['highest_streak'] as int? ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          rank.toString(),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        email,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Highest Score: ${highestScore.toString()}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Highest Streak: ${highestStreak.toString()}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      trailing: rank <= 3
                          ? Icon(
                              rank == 1
                                  ? Icons.emoji_events
                                  : rank == 2
                                  ? Icons.workspace_premium
                                  : Icons.military_tech,
                              color: rank == 1
                                  ? Colors.amber
                                  : rank == 2
                                  ? Colors.grey
                                  : Colors.brown,
                            )
                          : null,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading leaderboard',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).cardColor,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
