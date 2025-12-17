import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.provider.g.dart';

@riverpod
class AppTheme extends _$AppTheme {
  @override
  ThemeMode build() {
    return ThemeMode.system; // Initial theme mode
  }

  void toggleTheme() {
    if (state == ThemeMode.system) {
      // When starting from system mode, switch to dark mode
      state = ThemeMode.dark;
    } else if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }
}
