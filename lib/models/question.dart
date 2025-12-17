enum QuestionType {
  flag(1),
  shape(2),
  capital(3),
  capitalReverse(4),
  populationComparison(5),
  sizeComparison(6);

  final int value;
  const QuestionType(this.value);

  String get pathName {
    switch (this) {
      case QuestionType.flag:
        return 'flags';
      case QuestionType.shape:
        return 'shape';
      case QuestionType.capital:
        return 'flags'; // Show flag as hint for capital questions
      case QuestionType.capitalReverse:
        return 'flags'; // Show flag as visual hint
      case QuestionType.populationComparison:
        return ''; // No image for comparison questions
      case QuestionType.sizeComparison:
        return ''; // No image for comparison questions
    }
  }
}

class Question {
  QuestionType type;
  String imageUrl;
  Map<String, bool> alternatives;
  String? hint; // For additional context (e.g., country name for capital questions)
  Map<String, String>? alternativesMetadata; // For showing extra info (e.g., population/size values)

  Question({
    required this.imageUrl,
    required this.alternatives,
    required this.type,
    this.hint,
    this.alternativesMetadata,
  });
}