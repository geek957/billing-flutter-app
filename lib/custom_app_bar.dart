import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onHomePressed;

  const CustomAppBar({super.key, required this.title, required this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false, // Remove the back button
      leading: IconButton(
        icon: Icon(Icons.home, size: 30),
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          onHomePressed();
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
