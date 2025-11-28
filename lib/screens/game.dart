import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/question.service.dart';
import 'end_game.dart';
import '../widgets/app_bar.dart';
import '../models/question.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.data});
  final List<dynamic> data;

  static int questionNumber = 1;
  static int streak = 0;
  static int currentGameHighestStreak = 0;
  static int score = 0;
  static List<bool> errors = [false, false, false];
  static int errorsCount = 0;

  static Color getStreakIconColor(int streak) {
    if (streak < 10) {
      return Colors.grey;
    } else if (streak < 20) {
      return Colors.yellow;
    } else if (streak < 30) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Question question;
  String? selectedAlternative;
  bool answerSelected = false;
  String? correctAlternative;

  bool _hasPreloaded = false;

  @override
  void initState() {
    super.initState();
    question = createRandomQuestion(widget.data);
    // Find the correct alternative key
    correctAlternative = question.alternatives.entries
        .firstWhere((entry) => entry.value == true)
        .key;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload upcoming questions (only once, after context is available)
    if (!_hasPreloaded) {
      _hasPreloaded = true;
      preloadUpcomingQuestions(widget.data, context);
    }
  }

  int getPoints(int streak) {
    if (streak < 10) {
      return 1;
    } else if (streak < 20) {
      return 2;
    } else if (streak < 30) {
      return 3;
    } else {
      return 4;
    }
  }

  void _handleAnswerSelection(String alternativeKey, bool isCorrect) {
    if (answerSelected) return; // Prevent multiple selections

    setState(() {
      selectedAlternative = alternativeKey;
      answerSelected = true;
    });

    if (isCorrect) {
      setState(() {
        GameScreen.streak++;
        if (GameScreen.streak > GameScreen.currentGameHighestStreak) {
          GameScreen.currentGameHighestStreak = GameScreen.streak;
        }
        GameScreen.score += getPoints(GameScreen.streak);
      });
    } else {
      setState(() {
        GameScreen.errorsCount++;
        GameScreen.errors[GameScreen.errorsCount - 1] = true;
        GameScreen.streak = 0;
      });
    }

    // Wait a moment to show the color feedback, then move to next question
    Future.delayed(Duration(milliseconds: 600), () {
      if (!mounted) return;

      if (GameScreen.errorsCount == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EndGameScreen(
              title: 'Game Over',
              score: GameScreen.score,
              currentGameHighestStreak: GameScreen.currentGameHighestStreak,
              data: widget.data,
            ),
          ),
        );
      } else {
        // Move to next question
        GameScreen.questionNumber++;
        // Reset state for new question - use preloaded question
        setState(() {
          question = getNextQuestion(widget.data);
          selectedAlternative = null;
          answerSelected = false;
          correctAlternative = question.alternatives.entries
              .firstWhere((entry) => entry.value == true)
              .key;
        });

        // Preload more questions to keep the queue filled
        preloadUpcomingQuestions(widget.data, context);
      }
    });
  }

  Color? _getButtonColor(String alternativeKey) {
    if (!answerSelected) {
      return null; // Default color
    }

    if (alternativeKey == correctAlternative) {
      return Colors.green; // Correct answer always green
    }

    if (alternativeKey == selectedAlternative) {
      return Colors.red; // Selected wrong answer is red
    }

    return null; // Other alternatives stay default
  }

  Color? _getButtonBorderColor(String alternativeKey) {
    final color = _getButtonColor(alternativeKey);
    if (color != null) {
      return color;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, 'Question ${GameScreen.questionNumber}'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 40,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        GameScreen.streak.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Icon(
                        Icons.local_fire_department,
                        color: GameScreen.getStreakIconColor(GameScreen.streak),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ...GameScreen.errors.map(
                        (err) => Icon(
                          Icons.close,
                          color: err ? Colors.red : Colors.grey,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(GameScreen.score.toString()),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
                ],
              ),
            ),
            CachedNetworkImage(
              imageUrl: question.imageUrl,
              height: 200,
              placeholder: (context, url) => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const SizedBox(
                height: 200,
                child: Center(child: Icon(Icons.error, size: 50)),
              ),
            ),
            Column(
              spacing: 10,
              children: [
                ...question.alternatives.entries.map((alternative) {
                  final buttonColor = _getButtonColor(alternative.key);
                  final borderColor = _getButtonBorderColor(alternative.key);

                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: borderColor!,
                        width: buttonColor != null ? 3 : 1,
                      ),
                      backgroundColor: buttonColor?.withOpacity(0.2),
                      fixedSize: Size(200, 50),
                    ),
                    onPressed: answerSelected
                        ? null
                        : () => _handleAnswerSelection(
                            alternative.key,
                            alternative.value,
                          ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        alternative.key,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: buttonColor,
                          fontWeight: buttonColor != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
