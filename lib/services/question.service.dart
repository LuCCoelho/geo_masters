import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';

// Queue of pre-generated questions for preloading
final List<Question> upcomingQuestions = [];
const int preloadCount = 2; // Reduced to prevent stack overflow
const int maxPreloadedImages = 5; // Maximum number of images to keep in cache
int _currentPreloadedImageCount = 0;

Question createRandomQuestion(List<dynamic> data) {
  if (data.isEmpty) {
    throw Exception('Country data is empty');
  }

  if (data.length < 4) {
    throw Exception(
      'Not enough countries in data (need at least 4, got ${data.length})',
    );
  }

  final baseUrl = dotenv.env['SUPABASE_IMAGES_BASE_URL'];
  if (baseUrl == null || baseUrl.isEmpty) {
    throw Exception('SUPABASE_IMAGES_BASE_URL is not set in .env file');
  }

  List<int> randomIndexes = [];
  while (randomIndexes.length < 4) {
    final randomIndex = Random().nextInt(data.length);
    if (!randomIndexes.contains(randomIndex)) {
      randomIndexes.add(randomIndex);
    }
  }

  final country = data[randomIndexes[0]];

  // Validate required fields
  if (!country.containsKey('en') || country['en'] == null) {
    throw Exception('Country data is missing required field: en');
  }
  if (!country.containsKey('code') || country['code'] == null) {
    throw Exception('Country data is missing required field: code');
  }

  // Randomly select between all question types
  final randomValue = Random().nextInt(6);
  final questionType = randomValue == 0
      ? QuestionType.flag
      : randomValue == 1
          ? QuestionType.shape
          : randomValue == 2
              ? QuestionType.capital
              : randomValue == 3
                  ? QuestionType.capitalReverse
                  : randomValue == 4
                      ? QuestionType.populationComparison
                      : QuestionType.sizeComparison;

  // Build alternatives based on question type
  final Map<String, bool> alternativesMap;
  Map<String, String>? metadata; // For comparison questions
  
  if (questionType == QuestionType.capital) {
    // For capital questions, use capital names as alternatives
    // Validate that countries have capital field
    if (!country.containsKey('capital') || country['capital'] == null) {
      throw Exception('Country data is missing required field: capital');
    }
    
    alternativesMap = {
      '${country['capital']}': true,
      '${data[randomIndexes[1]]['capital']}': false,
      '${data[randomIndexes[2]]['capital']}': false,
      '${data[randomIndexes[3]]['capital']}': false,
    };
  } else if (questionType == QuestionType.capitalReverse) {
    // For reverse capital questions, show country names with emoji as alternatives
    // Validate that countries have capital field
    if (!country.containsKey('capital') || country['capital'] == null) {
      throw Exception('Country data is missing required field: capital');
    }
    
    alternativesMap = {
      _getCountryDisplayName(country): true,
      _getCountryDisplayName(data[randomIndexes[1]]): false,
      _getCountryDisplayName(data[randomIndexes[2]]): false,
      _getCountryDisplayName(data[randomIndexes[3]]): false,
    };
  } else if (questionType == QuestionType.populationComparison) {
    // For population comparison, find the most populous country
    final countries = randomIndexes.map((i) => data[i]).toList();
    
    // Validate population field exists
    for (var c in countries) {
      if (!c.containsKey('population') || c['population'] == null) {
        throw Exception('Country data is missing required field: population');
      }
    }
    
    // Sort by population (descending) - index 0 will be the most populous
    countries.sort((a, b) => (b['population'] as num).compareTo(a['population'] as num));
    
    // Build alternatives with the first (most populous) as correct answer
    alternativesMap = {
      _getCountryDisplayName(countries[0]): true,
      _getCountryDisplayName(countries[1]): false,
      _getCountryDisplayName(countries[2]): false,
      _getCountryDisplayName(countries[3]): false,
    };
    
    // Store population metadata for each alternative
    metadata = {
      _getCountryDisplayName(countries[0]): _formatPopulation(countries[0]['population']),
      _getCountryDisplayName(countries[1]): _formatPopulation(countries[1]['population']),
      _getCountryDisplayName(countries[2]): _formatPopulation(countries[2]['population']),
      _getCountryDisplayName(countries[3]): _formatPopulation(countries[3]['population']),
    };
  } else if (questionType == QuestionType.sizeComparison) {
    // For size comparison, find the biggest country
    final countries = randomIndexes.map((i) => data[i]).toList();
    
    // Validate size field exists
    for (var c in countries) {
      if (!c.containsKey('size (km2)') || c['size (km2)'] == null) {
        throw Exception('Country data is missing required field: size (km2)');
      }
    }
    
    // Sort by size (descending) - index 0 will be the biggest
    countries.sort((a, b) => (b['size (km2)'] as num).compareTo(a['size (km2)'] as num));
    
    // Build alternatives with the first (biggest) as correct answer
    alternativesMap = {
      _getCountryDisplayName(countries[0]): true,
      _getCountryDisplayName(countries[1]): false,
      _getCountryDisplayName(countries[2]): false,
      _getCountryDisplayName(countries[3]): false,
    };
    
    // Store size metadata for each alternative
    metadata = {
      _getCountryDisplayName(countries[0]): _formatSize(countries[0]['size (km2)']),
      _getCountryDisplayName(countries[1]): _formatSize(countries[1]['size (km2)']),
      _getCountryDisplayName(countries[2]): _formatSize(countries[2]['size (km2)']),
      _getCountryDisplayName(countries[3]): _formatSize(countries[3]['size (km2)']),
    };
  } else if (questionType == QuestionType.shape) {
    // For shape questions, use country names with emoji as alternatives
    alternativesMap = {
      _getCountryDisplayName(country): true,
      _getCountryDisplayName(data[randomIndexes[1]]): false,
      _getCountryDisplayName(data[randomIndexes[2]]): false,
      _getCountryDisplayName(data[randomIndexes[3]]): false,
    };
  } else {
    // For flag questions, use country names as alternatives
    alternativesMap = {
      '${country['en']}': true,
      '${data[randomIndexes[1]]['en']}': false,
      '${data[randomIndexes[2]]['en']}': false,
      '${data[randomIndexes[3]]['en']}': false,
    };
  }

  final alternativesList = alternativesMap.entries.toList();
  alternativesList.shuffle(Random());
  final shuffledAlternatives = Map<String, bool>.fromEntries(alternativesList);

  return Question(
    type: questionType,
    imageUrl: questionType == QuestionType.capitalReverse ||
            questionType == QuestionType.populationComparison ||
            questionType == QuestionType.sizeComparison
        ? '' // No image for text-based questions
        : '$baseUrl/${questionType.pathName}/${country['code'].toLowerCase()}.png',
    alternatives: shuffledAlternatives,
    hint: questionType == QuestionType.capital
        ? _getCountryDisplayName(country)
        : questionType == QuestionType.capitalReverse
            ? country['capital']
            : null,
    alternativesMetadata: metadata,
  );
}

/// Generates upcoming questions and preloads their images
void preloadUpcomingQuestions(List<dynamic> data, BuildContext context) {
  // Generate questions to fill the queue
  while (upcomingQuestions.length < preloadCount) {
    final nextQuestion = createRandomQuestion(data);
    upcomingQuestions.add(nextQuestion);

    // Only preload images if we haven't exceeded the limit and the question has an image
    if (_currentPreloadedImageCount < maxPreloadedImages && 
        nextQuestion.imageUrl.isNotEmpty) {
      _precacheImageUrl(nextQuestion.imageUrl, context);
      _currentPreloadedImageCount++;
    }
  }
}

/// Precaches an image URL using CachedNetworkImageProvider
void _precacheImageUrl(String imageUrl, BuildContext context) {
  if (imageUrl.isEmpty) return; // Skip empty URLs
  
  precacheImage(CachedNetworkImageProvider(imageUrl), context).catchError((
    error,
  ) {
    // Silently handle errors for missing images
    debugPrint('Failed to preload: $imageUrl');
    // Decrement counter on failure so we can try to load another image
    if (_currentPreloadedImageCount > 0) {
      _currentPreloadedImageCount--;
    }
  });
}

/// Gets the next question from the queue (or creates a new one)
Question getNextQuestion(List<dynamic> data) {
  // Decrement preloaded image counter when consuming a question
  if (upcomingQuestions.isNotEmpty) {
    final question = upcomingQuestions.removeAt(0);
    if (question.imageUrl.isNotEmpty && _currentPreloadedImageCount > 0) {
      _currentPreloadedImageCount--;
    }
    return question;
  }
  return createRandomQuestion(data);
}

/// Helper function to get country display name with emoji
String _getCountryDisplayName(Map<String, dynamic> country) {
  final name = country['en'];
  final emoji = country['emoji'];
  
  if (emoji != null && emoji.toString().isNotEmpty) {
    return '$name $emoji';
  }
  return name.toString();
}

/// Format population for display (e.g., 331,900,000)
String _formatPopulation(dynamic population) {
  if (population == null) return 'Unknown';
  final num pop = population as num;
  return '${pop.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )} people';
}

/// Format size for display (e.g., 9,834,000 km²)
String _formatSize(dynamic size) {
  if (size == null) return 'Unknown';
  final num sizeNum = size as num;
  return '${sizeNum.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )} km²';
}
