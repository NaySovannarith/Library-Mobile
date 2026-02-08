import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:library_app/module/home/home_page.dart';
import 'package:library_app/module/profile/profile_page.dart';
import 'package:library_app/module/scan/scan_page.dart';

class CustomNavBar1 extends StatefulWidget {
  const CustomNavBar1({super.key});

  @override
  State<CustomNavBar1> createState() => _CustomNavBar1State();
}

class _CustomNavBar1State extends State<CustomNavBar1> {
  int _selectedIndex = 0;

  static const List<Widget> _page = [HomePage(), ScanPage(), ProfilePage()];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: BottomAppBar(
                  color: Colors.black.withOpacity(0.5),
                  elevation: 10,
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home, "HOME", 0),
                        _buildNavItem(Icons.camera_alt, "SCAN", 1),
                        _buildNavItem(Icons.person, "PROFILE", 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : Colors.white54,
              shadows: isSelected
                  ? [
                      Shadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
