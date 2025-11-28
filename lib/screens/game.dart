import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/question.service.dart';
import 'end_game.dart';
import '../widgets/app_bar.dart';
import '../models/question.dart';
import '../providers/country_data.provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

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
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Question? question;
  String? selectedAlternative;
  bool answerSelected = false;
  String? correctAlternative;
  String? _errorMessage;

  bool _hasPreloaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload upcoming questions (only once, after context is available)
    if (!_hasPreloaded) {
      _hasPreloaded = true;
      final countryDataAsync = ref.read(countryDataProvider);
      countryDataAsync.whenData((data) {
        if (mounted) {
          preloadUpcomingQuestions(data, context);
        }
      });
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
            ),
          ),
        );
      } else {
        // Move to next question
        GameScreen.questionNumber++;
        // Reset state for new question - use preloaded question
        final countryDataAsync = ref.read(countryDataProvider);
        countryDataAsync.whenData((data) {
          if (mounted) {
            setState(() {
              question = getNextQuestion(data);
              selectedAlternative = null;
              answerSelected = false;
              correctAlternative = question!.alternatives.entries
                  .firstWhere((entry) => entry.value == true)
                  .key;
            });

            // Preload more questions to keep the queue filled
            preloadUpcomingQuestions(data, context);
          }
        });
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
    final countryDataAsync = ref.watch(countryDataProvider);
    return countryDataAsync.when(
      data: (data) {
        // Validate data
        if (data.isEmpty) {
          return Scaffold(
            appBar: getAppBar(
              context,
              'Question ${GameScreen.questionNumber}',
              ref,
            ),
            body: const Center(
              child: Text(
                'No country data available. Please check your database.',
              ),
            ),
          );
        }

        // Check if data has required fields
        if (data.isNotEmpty && !data[0].containsKey('en')) {
          return Scaffold(
            appBar: getAppBar(
              context,
              'Question ${GameScreen.questionNumber}',
              ref,
            ),
            body: const Center(
              child: Text(
                'Country data is missing required fields (en, code).',
              ),
            ),
          );
        }

        // Show error if there was one
        if (_errorMessage != null) {
          return Scaffold(
            appBar: getAppBar(
              context,
              'Question ${GameScreen.questionNumber}',
              ref,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_errorMessage'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        question = null;
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Initialize question if not already set
        if (question == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                setState(() {
                  question = createRandomQuestion(data);
                  correctAlternative = question!.alternatives.entries
                      .firstWhere((entry) => entry.value == true)
                      .key;
                  _errorMessage = null;
                });
              } catch (e) {
                setState(() {
                  _errorMessage = 'Failed to create question: $e';
                });
              }
            }
          });
          return Scaffold(
            appBar: getAppBar(
              context,
              'Question ${GameScreen.questionNumber}',
              ref,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: getAppBar(
            context,
            'Question ${GameScreen.questionNumber}',
            ref,
          ),
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
                            color: GameScreen.getStreakIconColor(
                              GameScreen.streak,
                            ),
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
                  imageUrl: question!.imageUrl,
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
                    ...question!.alternatives.entries.map((alternative) {
                      final buttonColor = _getButtonColor(alternative.key);
                      final borderColor = _getButtonBorderColor(
                        alternative.key,
                      );

                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: borderColor!,
                            width: buttonColor != null ? 3 : 1,
                          ),
                          backgroundColor: buttonColor?.withValues(alpha: 0.2),
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
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
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
      },
      loading: () => Scaffold(
        appBar: getAppBar(
          context,
          'Question ${GameScreen.questionNumber}',
          ref,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: getAppBar(
          context,
          'Question ${GameScreen.questionNumber}',
          ref,
        ),
        body: Center(child: Text('Error loading data: $error')),
      ),
    );
  }
}
