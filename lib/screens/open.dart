import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'home.dart';

class OpenScreen extends StatefulWidget {
  const OpenScreen({super.key, required this.data});

  final List<dynamic> data;

  @override
  State<OpenScreen> createState() => _OpenScreenState();
}

class _OpenScreenState extends State<OpenScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: 'Geo Masters',
            lastHighestStreak: 0,
            lastScore: 0,
            data: widget.data,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/globe.json', repeat: false),
            Text('Geo Masters', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
