import 'package:flutter/material.dart';

Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );
}
