import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game.dart';
import 'home.dart';
import '../widgets/app_bar.dart';
import '../providers/highest_score.provider.dart';
import '../providers/highest_streak.provider.dart';
import '../providers/country_data.provider.dart';

class EndGameScreen extends ConsumerStatefulWidget {
  const EndGameScreen({
    super.key,
    required this.title,
    required this.score,
    required this.currentGameHighestStreak,
  });

  final String title;
  final int score;
  final int currentGameHighestStreak;

  @override
  ConsumerState<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends ConsumerState<EndGameScreen> {
  bool _hasUpdatedProviders = false;
  bool? _isNewHighestScore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateProviders();
    });
  }

  Future<void> _updateProviders() async {
    if (_hasUpdatedProviders) return;
    _hasUpdatedProviders = true;

    final highestScoreAsync = ref.read(highestScoreProvider);
    final currentHighestScore = highestScoreAsync.value ?? 0;

    // Check before updating
    _isNewHighestScore = widget.score > currentHighestScore;

    // Update providers
    await ref
        .read(highestScoreProvider.notifier)
        .updateHighestScore(widget.score);
    await ref
        .read(highestStreakProvider.notifier)
        .updateHighestStreak(widget.currentGameHighestStreak);
  }

  @override
  Widget build(BuildContext context) {
    // Reset game state
    GameScreen.streak = 0;
    GameScreen.currentGameHighestStreak = 0;
    GameScreen.score = 0;
    GameScreen.errors = [false, false, false];
    GameScreen.errorsCount = 0;
    GameScreen.questionNumber = 1;

    final highestScoreAsync = ref.watch(highestScoreProvider);
    final currentHighestScore = highestScoreAsync.value ?? 0;

    // Use stored value if available, otherwise check current provider state
    final isNewHighestScore =
        _isNewHighestScore ?? (widget.score > currentHighestScore);

    return Scaffold(
      appBar: getAppBar(context, widget.title, ref),
      body: _buildUI(isNewHighestScore),
    );
  }

  LottieBuilder _getEndGameAnimation(bool isNewHighestScore) {
    if (isNewHighestScore) {
      return Lottie.asset('assets/animations/confetti.json', repeat: false);
    } else {
      return Lottie.asset(
        'assets/animations/skull.json',
        repeat: true,
        width: 200,
      );
    }
  }

  Widget _buildUI(bool isNewHighestScore) {
    return Stack(
      alignment: isNewHighestScore
          ? AlignmentDirectional.center
          : AlignmentDirectional.topCenter,
      children: [
        _getEndGameAnimation(isNewHighestScore),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 40,
            children: [
              Text(
                'Thank you for playing!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.score.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.currentGameHighestStreak.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Icon(
                        Icons.local_fire_department,
                        color: GameScreen.getStreakIconColor(
                          widget.currentGameHighestStreak,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                spacing: 20,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to GameScreen
                      final countryDataAsync = ref.read(countryDataProvider);
                      countryDataAsync.whenData((data) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => GameScreen()),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      fixedSize: Size(200, 50),
                    ),
                    child: Text(
                      'Play Again',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Navigate back to home page
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(
                            title: 'Geo Masters',
                            lastHighestStreak: widget.currentGameHighestStreak,
                            lastScore: widget.score,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    style: Theme.of(context).outlinedButtonTheme.style,
                    child: Text(
                      'Go Home',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
