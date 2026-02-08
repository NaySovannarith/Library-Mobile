import 'package:flutter/material.dart';

class ShelfLoc extends StatefulWidget {
  const ShelfLoc({super.key});

  @override
  State<ShelfLoc> createState() => _ShelfLocState();
}

class _ShelfLocState extends State<ShelfLoc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code Shelf Location')),
      body: Center(child: Text('Shelf Location Scanner Coming Soon')),
    );
  }
}
