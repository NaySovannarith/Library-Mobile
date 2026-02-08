import 'package:flutter/material.dart';

Widget buildListTile({
  required IconData icon,
  required String title,
  VoidCallback? onTap,
}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: const Color.fromARGB(255, 114, 2, 2),
      child: Icon(
        icon,
        color: const Color.fromARGB(255, 119, 119, 119),
        size: 20,
      ),
    ),
    title: Text(title, style: const TextStyle(color: Colors.white)),
    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    onTap: onTap,
  );
}
