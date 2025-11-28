import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'game.dart';
import 'home.dart';
import '../widgets/app_bar.dart';
import '../providers/highest_score.provider.dart';
import '../providers/highest_streak.provider.dart';

class EndGameScreen extends StatefulWidget {
  const EndGameScreen({
    super.key,
    required this.title,
    required this.score,
    required this.currentGameHighestStreak,
    required this.data,
  });

  final String title;
  final int score;
  final int currentGameHighestStreak;
  final List<dynamic> data;

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
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

    final highestScoreProvider = Provider.of<HighestScoreProvider>(
      context,
      listen: false,
    );
    final highestStreakProvider = Provider.of<HighestStreakProvider>(
      context,
      listen: false,
    );

    // Check before updating
    _isNewHighestScore = widget.score > highestScoreProvider.highestScore;

    // Update providers
    await highestScoreProvider.updateHighestScore(widget.score);
    await highestStreakProvider.updateHighestStreak(
      widget.currentGameHighestStreak,
    );
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

    final highestScoreProvider = Provider.of<HighestScoreProvider>(context);
    final highestStreakProvider = Provider.of<HighestStreakProvider>(context);

    // Use stored value if available, otherwise check current provider state
    final isNewHighestScore =
        _isNewHighestScore ??
        (widget.score > highestScoreProvider.highestScore);

    return Scaffold(
      appBar: getAppBar(context, widget.title),
      body: _buildUI(
        highestScoreProvider,
        highestStreakProvider,
        isNewHighestScore,
      ),
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

  Widget _buildUI(
    HighestScoreProvider highestScoreProvider,
    HighestStreakProvider highestStreakProvider,
    bool isNewHighestScore,
  ) {
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
                      Navigator.pushReplacement(
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
                            data: widget.data,
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
