import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme.provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login.dart';

AppBar getAppBar(
  BuildContext context,
  String title,
  WidgetRef ref, {
  bool showDropdown = false,
}) {
  // Watch the theme provider to ensure the icon updates when theme changes
  final themeMode = ref.watch(appThemeProvider);
  final brightness = Theme.of(context).brightness;

  // Determine the effective brightness based on theme mode
  final effectiveBrightness = themeMode == ThemeMode.system
      ? brightness
      : (themeMode == ThemeMode.light ? Brightness.light : Brightness.dark);

  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    title: Text(title),
    leading: IconButton(
      onPressed: () {
        ref.read(appThemeProvider.notifier).toggleTheme();
      },
      icon: effectiveBrightness == Brightness.light
          ? const Icon(Icons.light_mode)
          : const Icon(Icons.dark_mode),
    ),
    actions: showDropdown
        ? [
            DropdownButton(
              items: [
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(children: [Text('Logout'), Icon(Icons.logout)]),
                ),
              ],
              onChanged: (value) async {
                if (value == 'logout') {
                  try {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    debugPrint('Error signing out: $e');
                  }
                }
              },
              icon: Icon(Icons.more_vert),
            ),
          ]
        : null,
  );
}
