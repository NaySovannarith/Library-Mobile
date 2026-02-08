import 'package:flutter/material.dart';
import 'package:library_app/module/staff_module/staff_scan_book/staff_scan_details.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminScan extends StatefulWidget {
  const AdminScan({super.key});

  @override
  State<AdminScan> createState() => _AdminScanState();
}

class _AdminScanState extends State<AdminScan> {
  bool hasScanned = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Scan Book')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              if (hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isEmpty) return;

              final String? code = barcodes.first.rawValue;
              if (code == null) return;

              setState(() {
                hasScanned = true;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdScanDetails(barcode: code)),
              ).then((_) {
                setState(() {
                  hasScanned = false;
                });
              });
            },
          ),
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 214, 131, 14),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(painter: ScannerCornersPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-right corner
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
