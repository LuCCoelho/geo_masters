import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_bar.dart';

class FriendsRoomScreen extends ConsumerWidget {
  const FriendsRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: getAppBar(context, 'Friends Room', ref, showDropdown: true),
      body: Stack(
        children: [
          Center(child: Text('Friends Room')),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.chevron_left),
            ),
          ),
        ],
      ),
    );
  }
}
