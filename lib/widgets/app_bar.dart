import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme.provider.dart';

AppBar getAppBar(BuildContext context, String title, WidgetRef ref) {
  final brightness = Theme.of(context).brightness;

  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    title: Text(title),
    actions: [
      IconButton(
        onPressed: () {
          ref.read(appThemeProvider.notifier).toggleTheme();
        },
        icon: brightness == Brightness.light
            ? const Icon(Icons.light_mode)
            : const Icon(Icons.dark_mode),
      ),
    ],
  );
}
