import 'package:flutter/material.dart';
import 'package:geo_masters/screens/login.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/country_data.provider.dart';

class OpenScreen extends ConsumerStatefulWidget {
  const OpenScreen({super.key});

  @override
  ConsumerState<OpenScreen> createState() => _OpenScreenState();
}

class _OpenScreenState extends ConsumerState<OpenScreen> {
  @override
  void initState() {
    super.initState();
    // Prefetch the data
    ref.read(countryDataProvider);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
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
