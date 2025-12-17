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
    // Longer delay for comparison questions to allow reading the metadata
    final isComparison =
        question!.type == QuestionType.populationComparison ||
        question!.type == QuestionType.sizeComparison;
    final delayMilliseconds = isComparison ? 2500 : 600;

    Future.delayed(Duration(milliseconds: delayMilliseconds), () {
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

  String _getQuestionText(Question question) {
    switch (question.type) {
      case QuestionType.flag:
        return 'Which country\'s flag is this?';
      case QuestionType.shape:
        return 'What country is this?';
      case QuestionType.capital:
        final hint = question.hint ?? 'this country';
        return "What's the capital of $hint?";
      case QuestionType.capitalReverse:
        return 'This is the capital of which country?';
      case QuestionType.populationComparison:
        return 'Which is the most populous?';
      case QuestionType.sizeComparison:
        return 'Which is the biggest?';
    }
  }

  IconData _getQuestionIcon(Question question) {
    switch (question.type) {
      case QuestionType.flag:
        return Icons.flag;
      case QuestionType.shape:
        return Icons.public;
      case QuestionType.capital:
        return Icons.location_city;
      case QuestionType.capitalReverse:
        return Icons.apartment;
      case QuestionType.populationComparison:
        return Icons.people;
      case QuestionType.sizeComparison:
        return Icons.straighten;
    }
  }

  Color _getQuestionColor(Question question) {
    switch (question.type) {
      case QuestionType.flag:
        return Colors.blue;
      case QuestionType.shape:
        return Colors.green;
      case QuestionType.capital:
        return Colors.orange;
      case QuestionType.capitalReverse:
        return Colors.purple;
      case QuestionType.populationComparison:
        return Colors.red;
      case QuestionType.sizeComparison:
        return Colors.teal;
    }
  }

  Widget _getCenterContent(Question question) {
    // For reverse capital questions, show the capital name
    if (question.type == QuestionType.capitalReverse) {
      return Text(
        question.hint ?? '',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: _getQuestionColor(question),
        ),
        textAlign: TextAlign.center,
      );
    }

    // For comparison questions, show an icon
    if (question.type == QuestionType.populationComparison ||
        question.type == QuestionType.sizeComparison) {
      return Icon(
        _getQuestionIcon(question),
        size: 120,
        color: _getQuestionColor(question).withValues(alpha: 0.3),
      );
    }

    // Default: empty
    return const SizedBox.shrink();
  }

  Widget _buildAlternativeContent(String alternativeKey, Color? buttonColor) {
    final isComparison =
        question!.type == QuestionType.populationComparison ||
        question!.type == QuestionType.sizeComparison;

    // Show metadata only after answer is selected for comparison questions
    String? metadata;
    if (answerSelected &&
        isComparison &&
        question!.alternativesMetadata != null) {
      metadata = question!.alternativesMetadata![alternativeKey];
    }

    if (metadata != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            alternativeKey,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: buttonColor,
              fontWeight: buttonColor != null
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            metadata,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: buttonColor ?? Colors.grey.shade600,
              fontSize: 9,
              fontWeight: FontWeight.w400,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    // Default: just the country name
    return Text(
      alternativeKey,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: buttonColor,
        fontWeight: buttonColor != null ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 25,
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
                  // Question text based on type with icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(
                          _getQuestionIcon(question!),
                          color: _getQuestionColor(question!),
                          size: 28,
                        ),
                        Flexible(
                          child: Text(
                            _getQuestionText(question!),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getQuestionColor(question!),
                                ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                        Icon(
                          _getQuestionIcon(question!),
                          color: _getQuestionColor(question!),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                  // Show image or text for text-based questions
                  question!.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
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
                        )
                      : Container(
                          height: 200,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _getCenterContent(question!),
                        ),
                  Column(
                    spacing: 8,
                    children: [
                      ...question!.alternatives.entries.map((alternative) {
                        final buttonColor = _getButtonColor(alternative.key);
                        final borderColor = _getButtonBorderColor(
                          alternative.key,
                        );

                        return Container(
                          width: 280,
                          constraints: const BoxConstraints(minHeight: 60),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: borderColor!,
                                width: buttonColor != null ? 3 : 1,
                              ),
                              backgroundColor: buttonColor?.withValues(
                                alpha: 0.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: answerSelected
                                ? null
                                : () => _handleAnswerSelection(
                                    alternative.key,
                                    alternative.value,
                                  ),
                            child: _buildAlternativeContent(
                              alternative.key,
                              buttonColor,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
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
