import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sns_app/modules/auth/auth.repository.dart';
import 'package:sns_app/modules/auth/current_user_store.dart';

class Header extends ConsumerWidget {
  const Header({super.key});

  void _hendleMenuSelected(WidgetRef ref, int val) async {
    if (val == 1) {
      await AuthRepository().signout();
      ref.read(currentUserProvider.notifier).setCurrentUser(null);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return AppBar(
      title: const Text('SNS APP', style: TextStyle(color: Colors.white)),
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.menu, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 0,
              child: ListTile(
                title: Text(currentUser!.userMetadata!["name"]),
                subtitle: Text(currentUser.email!),
              ),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: ListTile(
                title: Text("Sign Out", style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
          onSelected: (val) => _hendleMenuSelected(ref, val),
        ),
      ],
    );
  }
}
