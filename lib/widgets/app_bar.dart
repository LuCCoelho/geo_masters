import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme.provider.dart';

AppBar getAppBar(BuildContext context, String title) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    title: Text(title),
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
  );
}
