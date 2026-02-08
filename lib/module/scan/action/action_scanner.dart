import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum ScanTarget { shelf, table }

class ActionScannerPage extends StatefulWidget {
  final ScanTarget target;

  const ActionScannerPage({super.key, required this.target});

  @override
  State<ActionScannerPage> createState() => _ActionScannerPageState();
}

class _ActionScannerPageState extends State<ActionScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _done = false;

  String get _title =>
      widget.target == ScanTarget.shelf ? 'Scan Shelf QR' : 'Scan Table QR';

  String get _hint => widget.target == ScanTarget.shelf
      ? 'Point camera at the SHELF QR'
      : 'Point camera at the TABLE QR';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_done) return;

    final code = capture.barcodes.isNotEmpty
        ? capture.barcodes.first.rawValue
        : null;

    if (code == null || code.isEmpty) return;

    _done = true;
    await controller.stop();

    if (!mounted) return;
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),

          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            fit: BoxFit.cover,
            onDetect: _handleDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Camera error: $error\n\nCheck camera permission.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
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
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_hint, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
