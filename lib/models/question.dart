enum QuestionType {
  flag(1),
  shape(2);

  final int value;
  const QuestionType(this.value);

  String get pathName {
    switch (this) {
      case QuestionType.flag:
        return 'flags';
      case QuestionType.shape:
        return 'shape';
    }
  }
}

class Question {
  QuestionType type;
  String imageUrl;
  Map<String, bool> alternatives;

  Question({
    required this.imageUrl,
    required this.alternatives,
    required this.type,
  });
}