import 'package:flutter/material.dart';
import 'package:library_app/module/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset('assets/itc.png', fit: BoxFit.contain),
        ),
        title: const Text(
          'ITC LIBRARY',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Book',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Poetry Section
              _buildCategorySection('Poetry', [
                _buildBookCard(
                  'Prisoner\n(Arnod Miller)',
                  'Lorem Ipsum Dolor Sit Sit',
                  Colors.grey[300]!,
                  Icons.menu_book,
                ),
                _buildBookCard(
                  'The Words I Cannot Say (Smith Brooks)',
                  'Lorem Ipsum Dolor Sit Sit',
                  Colors.red[900]!,
                  Icons.menu_book,
                ),
              ]),
              const SizedBox(height: 24),

              // Romance Section
              _buildCategorySection('Romance', [
                _buildBookCard(
                  'Meet You\n(Bill Silas)',
                  'Lorem Ipsum Dolor Sit Sit',
                  Colors.orange[300]!,
                  Icons.menu_book,
                ),
                _buildBookCard(
                  'Moonstruck\n(Amber Love)',
                  'Lorem Ipsum Dolor Sit Sit',
                  Colors.blue[700]!,
                  Icons.menu_book,
                ),
              ]),
              const SizedBox(height: 24),

              // Short Stories Section
              _buildCategorySection('Short Stories', [
                _buildBookCard(
                  'How to Write a\nShort Story',
                  'Lorem Ipsum Dolor Sit Sit',
                  Colors.red[800]!,
                  Icons.menu_book,
                ),
                _buildBookCard(
                  'Short Story\nCollection',
                  'Lorem Ipsum Dolor Sit Sit',
                  Colors.blue[300]!,
                  Icons.menu_book,
                ),
              ]),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Widget> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: books[0]),
            const SizedBox(width: 12),
            Expanded(child: books[1]),
          ],
        ),
      ],
    );
  }

  Widget _buildBookCard(
    String title,
    String description,
    Color backgroundColor,
    IconData icon, {
    bool isSelected = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 60,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Book Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Star Rating
            Row(
              children: List.generate(
                5,
                (index) =>
                    Icon(Icons.star, size: 16, color: Colors.yellow[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
