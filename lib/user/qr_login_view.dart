import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrLoginView extends StatefulWidget {
  const QrLoginView({super.key});

  @override
  _QrLoginViewState createState() => _QrLoginViewState();
}

class _QrLoginViewState extends State<QrLoginView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = false; // To control the loader state
  String? scannedData; // Holds the scanned data

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        controller!.pauseCamera();
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        controller!.resumeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.transparent, // Hidden default border
              overlayColor: Colors.black.withOpacity(0.5),
            ),
          ),

          // Custom Overlay with Fixed Size
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 250, // Fixed size of the scanning area
              height: 250,
              child: CustomPaint(
                size: const Size.square(250), // Matches the scanning area size
                painter: QRCornerPainter(
                  cornerColor: const Color(0xFFFF6500),
                  strokeWidth: 5.0,
                ),
              ),
            ),
          ),
          // Center Loader
          if (isScanning)
            Center(
              child: CircularProgressIndicator(
                color: theme.textTheme.headlineLarge?.color,
              ),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanning) {
        setState(() {
          isScanning = true; // Show loader
        });

        // Simulate a delay to show the loader
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            isScanning = false; // Hide loader
            scannedData = scanData.code; // Store scanned data
          });

          // Show dialog with scanned data
          _showScannedDataDialog(scanData.code ?? 'No data found');
          log('Scanned Data: ${scanData.code}');
        });
      }
    });
  }

  void _showScannedDataDialog(String data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text(
            'Scanned Data',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            data,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/// Custom Painter for QR corner edges
class QRCornerPainter extends CustomPainter {
  final Color cornerColor;
  final double strokeWidth;

  QRCornerPainter({required this.cornerColor, this.strokeWidth = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Length of the corner lines
    const double cornerLength = 30.0; // Smaller for a compact scanning area

    // Draw top-left corner
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint); // Horizontal line
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint); // Vertical line

    // Draw top-right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint); // Horizontal line
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint); // Vertical line

    // Draw bottom-left corner
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint); // Horizontal line
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint); // Vertical line

    // Draw bottom-right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height),
        paint); // Horizontal line
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength),
        paint); // Vertical line
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
