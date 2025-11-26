import 'package:flutter/material.dart';
import 'theme.provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

//TODO: disable back button on end game screen

const mockAlternatives = [
  {'text': 'A', 'isCorrect': true},
  {'text': 'B', 'isCorrect': false},
  {'text': 'C', 'isCorrect': false},
  {'text': 'D', 'isCorrect': false},
];
int highestStreak = 0;
int highestScore = 0;

List<dynamic> data = [];

void main() async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  data = await Supabase.instance.client.from('countries').select();

  runApp(MyApp());
}

final ThemeProvider themeProvider = ThemeProvider();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to theme changes and rebuild when theme changes
    themeProvider.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Masters',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue[200],
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.black),
            fixedSize: Size(200, 50),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 20),
          bodySmall: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 19, 44, 81),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white),
            fixedSize: Size(200, 50),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 20),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
      home: const MyHomePage(
        title: 'Geo Masters',
        lastHighestStreak: 0,
        lastScore: 0,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.lastHighestStreak,
    required this.lastScore,
  });

  final String title;
  final int lastHighestStreak;
  final int lastScore;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: themeProvider.themeMode == ThemeMode.light
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 60,
          children: [
            Column(
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Highest Score',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          highestScore.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Highest Streak',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          highestStreak.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Last Score',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          widget.lastScore.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Last Streak',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          widget.lastHighestStreak.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                fixedSize: Size(200, 50),
              ),
              child: Text('Play', style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static int questionNumber = 1;
  static int streak = 0;
  static int currentGameHighestStreak = 0;
  static int score = 0;
  static List<bool> errors = [false, false, false];
  static int errorsCount = 0;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final question = createRandomQuestion();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Question ${GameScreen.questionNumber}'),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: themeProvider.themeMode == ThemeMode.light
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
          ),
        ],
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
                        color: getStreakIconColor(GameScreen.streak),
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
            Image(image: NetworkImage(question.imageUrl)),
            Column(
              spacing: 10,
              children: [
                ...question.alternatives.entries.map(
                  (alternative) => OutlinedButton(
                    style: Theme.of(context).outlinedButtonTheme.style,
                    onPressed: () {
                      if (alternative.value) {
                        setState(() {
                          GameScreen.streak++;
                          if (GameScreen.streak >
                              GameScreen.currentGameHighestStreak) {
                            GameScreen.currentGameHighestStreak =
                                GameScreen.streak;
                          }
                          GameScreen.score += getPoints(GameScreen.streak);
                        });
                      } else {
                        setState(() {
                          GameScreen.errorsCount++;
                          GameScreen.errors[GameScreen.errorsCount - 1] = true;
                          if (GameScreen.errorsCount == 3) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EndGameScreen(
                                  score: GameScreen.score,
                                  currentGameHighestStreak:
                                      GameScreen.currentGameHighestStreak,
                                ),
                              ),
                            );
                          }
                          GameScreen.streak = 0;
                        });
                      }
                      GameScreen.questionNumber++;
                    },
                    child: Text(
                      alternative.key,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EndGameScreen extends StatefulWidget {
  const EndGameScreen({
    super.key,
    required this.score,
    required this.currentGameHighestStreak,
  });

  final int score;
  final int currentGameHighestStreak;

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  @override
  Widget build(BuildContext context) {
    // Update highest streak and score
    if (widget.currentGameHighestStreak > highestStreak) {
      highestStreak = widget.currentGameHighestStreak;
    }
    if (widget.score > highestScore) {
      highestScore = widget.score;
    }

    // Reset game state
    GameScreen.streak = 0;
    GameScreen.currentGameHighestStreak = 0;
    GameScreen.score = 0;
    GameScreen.errors = [false, false, false];
    GameScreen.errorsCount = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Game Over'),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: themeProvider.themeMode == ThemeMode.light
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: Center(
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
                      color: getStreakIconColor(
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
                      MaterialPageRoute(builder: (context) => GameScreen()),
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
    );
  }
}

class Question {
  String imageUrl;
  Map<String, bool> alternatives;

  Question({required this.imageUrl, required this.alternatives});
}

Question createRandomQuestion() {
  final randomIndex = Random().nextInt(data.length);
  final country = data[randomIndex];
  final alternativesMap = {
    '${country['en']}': true,
    '${data[Random().nextInt(data.length)]['en']}': false,
    '${data[Random().nextInt(data.length)]['en']}': false,
    '${data[Random().nextInt(data.length)]['en']}': false,
  };

  final alternativesList = alternativesMap.entries.toList();
  alternativesList.shuffle(Random());
  final shuffledAlternatives = Map<String, bool>.fromEntries(alternativesList);

  return Question(
    imageUrl:
        '${dotenv.env['SUPABASE_IMAGES_BASE_URL']}/flags/${country['code'].toLowerCase()}.png',
    alternatives: shuffledAlternatives,
  );
}

Color getStreakIconColor(int streak) {
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
