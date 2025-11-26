import 'package:flutter/material.dart';
import 'theme.provider.dart';

const mockAlternatives = [
  {'text': 'A', 'isCorrect': true},
  {'text': 'B', 'isCorrect': false},
  {'text': 'C', 'isCorrect': false},
  {'text': 'D', 'isCorrect': false},
];

void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(title: 'Geo Masters'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
                          '100',
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
                          '53',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Last Score',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text('90', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(quesionNumber: 1),
                  ),
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
  const GameScreen({super.key, required this.quesionNumber});

  final int quesionNumber;
  static int streak = 0;
  static int score = 0;
  static List<bool> errors = [false, false, false];
  static int errorsCount = 0;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Question ${widget.quesionNumber}'),
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
                        color: getStreaColor(GameScreen.streak),
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
            Image(image: AssetImage('assets/images/question_1.png')),
            Column(
              spacing: 10,
              children: [
                ...mockAlternatives.map(
                  (alternative) => OutlinedButton(
                    style: Theme.of(context).outlinedButtonTheme.style,
                    onPressed: () {
                      if (alternative['isCorrect'] as bool) {
                        setState(() {
                          GameScreen.streak++;
                          GameScreen.score += getPoints(GameScreen.streak);
                        });
                      } else {
                        setState(() {
                          GameScreen.errorsCount++;
                          GameScreen.errors[GameScreen.errorsCount - 1] = true;
                          if (GameScreen.errorsCount == 3) {
                            //push to end of game screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EndGameScreen(),
                              ),
                            );
                          }
                          GameScreen.streak = 0;
                        });
                      }
                    },
                    child: Text(
                      alternative['text'] as String,
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
  const EndGameScreen({super.key});

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  @override
  Widget build(BuildContext context) {
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
            Column(
              spacing: 20,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Reset game state
                    GameScreen.streak = 0;
                    GameScreen.score = 0;
                    GameScreen.errors = [false, false, false];
                    GameScreen.errorsCount = 0;
                    // Navigate to GameScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(quesionNumber: 1),
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
                    // Reset game state
                    GameScreen.streak = 0;
                    GameScreen.score = 0;
                    GameScreen.errors = [false, false, false];
                    GameScreen.errorsCount = 0;
                    // Navigate back to home page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(title: 'Geo Masters'),
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

Color getStreaColor(int streak) {
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
