import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:toastification/toastification.dart';

class QrLoginView extends StatefulWidget {
  bool isQrLoading;
  QrLoginView({super.key, required this.isQrLoading});

  @override
  _QrLoginViewState createState() => _QrLoginViewState();
}

class _QrLoginViewState extends State<QrLoginView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = false;
  String? scannedData;

  // bool isLoading = true;

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
    // if (context.mounted) {
    //   Future.delayed(const Duration(seconds: 4), () {
    //     setState(() {
    //       widget.isQrLoading = false;
    //     });
    //   });
    //   log("QR Loading Value: ${widget.isQrLoading}");
    // }

    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer2<AuthServices, AppStore>(builder: (context, auth, app, _) {
        // if (widget.isQrLoading) {
        //   return Center(
        //     child: CircularProgressIndicator(
        //       color: theme.textTheme.headlineLarge?.color,
        //     ),
        //   );
        // }
        if (!app.isSignedIn || app.user?.name == null || app.user?.name == "") {
          app.initializeUserData();
        }

        return Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: (p0) {
                controller = p0;
                p0.scannedDataStream.listen((scanData) async {
                  if (isScanning) return;

                  setState(() {
                    isScanning = true;
                  });

                  log("scanData: ${scanData.code}");

                  if (scanData.code != null && scanData.code!.isNotEmpty) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setState) {
                          return const AlertDialog(
                            title: Text("Processing QR Code"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Verifying QR code, please wait..."),
                              ],
                            ),
                          );
                        },
                      ),
                    );

                    try {
                      log("Calling /qr-code/verify-sneek-qr endpoint...");
                      final resp = await auth.verifyQR(
                        mobileID: app.user?.mobileNumbers.first.id.toString() ?? "0",
                        qrCode: scanData.code!,
                      );

                      if (resp == true) {
                        // Reset the scanning state after success
                        setState(() {
                          isScanning = false;
                        });
                        showToast(
                          message: "Account created successfully",
                          type: ToastificationType.success,
                        );
                        Navigator.of(context).pop();
                        context.goNamed('user-home-page');
                      } else {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Verification Failed"),
                              content: const Text("Invalid QR code. Please try again."),
                              actions: [
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      isScanning = false;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } catch (e) {
                      log("Error verifying QR: $e");
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Error",
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            content: Text(
                              "An error occurred while verifying the QR code.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    isScanning = false;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    setState(() {
                      isScanning = false;
                    });
                    showToast(
                      message: "Invalid QR code",
                      type: ToastificationType.error,
                    );
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.transparent,
                overlayColor: Colors.black.withOpacity(0.5),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  size: const Size.square(250),
                  painter: QRCornerPainter(
                    cornerColor: const Color(0xFFFF6500),
                    strokeWidth: 5.0,
                  ),
                ),
              ),
            ),
            if (auth.isLoading || app.isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    if (context.mounted) {
      controller?.dispose();
    }
    super.dispose();
    // widget.isQrLoading = false;
  }
}

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

    const double cornerLength = 30.0;

    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
