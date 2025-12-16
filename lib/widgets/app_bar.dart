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
  final brightness = Theme.of(context).brightness;

  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    title: Text(title),
    leading: IconButton(
      onPressed: () {
        ref.read(appThemeProvider.notifier).toggleTheme();
      },
      icon: brightness == Brightness.light
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
