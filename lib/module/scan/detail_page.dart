import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:library_app/module/scan/action/action_scanner.dart';
//import 'package:library_app/module/scan/status/borrowed.dart';

class BookDetailPage extends StatefulWidget {
  final String isbn;

  const BookDetailPage({super.key, required this.isbn});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  Map<String, dynamic>? book;
  final List<Map<String, String>> _movementLog = [];
  String? shelfQr;
  String? tableQr;

  @override
  void initState() {
    super.initState();
    fetchBook();
  }

  Future<void> fetchBook() async {
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:${widget.isbn}',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['totalItems'] > 0) {
      if (!mounted) return;
      setState(() {
        book = data['items'][0]['volumeInfo'];
      });
    }
  }

  Future<void> _scanFor(ScanTarget target) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ActionScannerPage(target: target)),
    );

    if (result == null) return;

    setState(() {
      if (target == ScanTarget.shelf) {
        shelfQr = result;
      } else {
        tableQr = result;
      }
    });

    _recordMovement(
      target == ScanTarget.shelf
          ? 'Shelved at: $result'
          : 'Reading at table: $result',
    );
  }

  void _recordMovement(String action) {
    final entry = {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'isbn': widget.isbn,
    };
    setState(() {
      _movementLog.insert(0, entry);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action recorded')));
  }

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final image = book!['imageLinks']?['thumbnail'];

    return Scaffold(
      appBar: AppBar(title: Text(book!['title'] ?? 'Book')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (image != null) Image.network(image, height: 200),
              const SizedBox(height: 16),
              Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 226, 139, 9),
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  book!['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                ),

                child: Text(
                  'Authors: ${(book!['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Text(book!['description'] ?? ''),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location in the library ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shelf QR: ${shelfQr ?? "Not scanned"}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Table QR: ${tableQr ?? "Not scanned"}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 190, 128, 3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 190, 128, 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUICK ACTIONS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Four quick actions: Read on table, Return, Shelve, Borrow
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _scanFor(ScanTarget.shelf),
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Shelve'),
                        ),

                        ElevatedButton.icon(
                          onPressed: () => _scanFor(ScanTarget.table),
                          icon: const Icon(Icons.table_bar_sharp),
                          label: const Text('Read on table'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Optional: view recent movement log
                    if (_movementLog.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Recent moves',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          itemCount: _movementLog.length.clamp(0, 5),
                          itemBuilder: (context, index) {
                            final e = _movementLog[index];
                            return Text('${e['timestamp']}: ${e['action']}');
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
