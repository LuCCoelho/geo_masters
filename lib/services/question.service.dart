import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';

// Queue of pre-generated questions for preloading
final List<Question> upcomingQuestions = [];
const int preloadCount = 3;

Question createRandomQuestion(List<dynamic> data) {
  List<int> randomIndexes = [];
  while (randomIndexes.length < 4) {
    final randomIndex = Random().nextInt(data.length);
    if (!randomIndexes.contains(randomIndex)) {
      randomIndexes.add(randomIndex);
    }
  }

  final country = data[randomIndexes[0]];

  final alternativesMap = {
    '${country['en']}': true,
    '${data[randomIndexes[1]]['en']}': false,
    '${data[randomIndexes[2]]['en']}': false,
    '${data[randomIndexes[3]]['en']}': false,
  };

  final alternativesList = alternativesMap.entries.toList();
  alternativesList.shuffle(Random());
  final shuffledAlternatives = Map<String, bool>.fromEntries(alternativesList);

  // Randomly select between flag (1) and shape (2)
  final questionType = Random().nextBool()
      ? QuestionType.flag
      : QuestionType.shape;

  return Question(
    type: questionType,
    imageUrl:
        '${dotenv.env['SUPABASE_IMAGES_BASE_URL']}/${questionType.pathName}/${country['code'].toLowerCase()}.png',
    alternatives: shuffledAlternatives,
  );
}

/// Generates upcoming questions and preloads their images
void preloadUpcomingQuestions(List<dynamic> data, BuildContext context) {
  // Generate questions to fill the queue
  while (upcomingQuestions.length < preloadCount) {
    final nextQuestion = createRandomQuestion(data);
    upcomingQuestions.add(nextQuestion);

    // Preload the image in the background
    _precacheImageUrl(nextQuestion.imageUrl, context);
  }
}

/// Precaches an image URL using CachedNetworkImageProvider
void _precacheImageUrl(String imageUrl, BuildContext context) {
  precacheImage(CachedNetworkImageProvider(imageUrl), context).catchError((
    error,
  ) {
    // Silently handle errors for missing images
    debugPrint('Failed to preload: $imageUrl');
  });
}

/// Gets the next question from the queue (or creates a new one)
Question getNextQuestion(List<dynamic> data) {
  if (upcomingQuestions.isNotEmpty) {
    return upcomingQuestions.removeAt(0);
  }
  return createRandomQuestion(data);
}
