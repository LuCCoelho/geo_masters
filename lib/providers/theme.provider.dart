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
    state = (state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}
