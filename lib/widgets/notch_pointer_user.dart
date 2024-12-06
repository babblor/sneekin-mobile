import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneekin/models/virtual_account.dart';

class UserNotch extends StatelessWidget {
  VirtualAccount account;

  UserNotch({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      // onTap: () {
      //   context.go('/org-app-account-profile', extra: orgAccount);
      // },
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 48),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main White Container
              Container(
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SizedBox(
                            //   width: 15,
                            // ),
                            Text(
                              account.orgAppName,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.circle,
                          size: 18,
                          color: Colors.green,
                        )
                      ],
                    ),
                  ),
                ), // Placeholder height
              ),
              Positioned(
                top: -26, // Adjust the vertical offset as needed
                right: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Notch background shape
                    CustomPaint(
                      size: const Size(60, 45), // Adjust the size to best match your design
                      painter: NotchPainter(context: context),
                    ),
                    // Icon on top of the notch
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 12),
                      child: FaIcon(
                        FontAwesomeIcons.globe,
                        // account == null
                        //     ? FontAwesomeIcons.unlink
                        //     : account.mobile == true
                        //         ? FontAwesomeIcons.mobileRetro
                        //         : FontAwesomeIcons.globe,
                        size: 16,
                        color: theme.textTheme.headlineLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 17,
                left: -30,
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.textTheme.headlineLarge?.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text(
                    account.username[0],
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  )),
                ),
              ),
              // Right-top notch
            ],
          ),
        ),
      ),
    );
  }
}

class NotchPainter extends CustomPainter {
  final BuildContext context;

  NotchPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the main shape paint
    final paint = Paint()..color = Theme.of(context).secondaryHeaderColor;

    // Define the path for the main shape
    final path = Path()
      ..moveTo(size.width, size.height) // Bottom-right corner
      ..lineTo(0, size.height) // Bottom-left corner
      ..lineTo(0, size.height * 0.6) // Notch bottom left
      ..lineTo(size.width * 0.6, 0) // Notch top left
      ..lineTo(size.width, 0) // Top-right corner
      ..close(); // Close the path

    // Draw the main shape path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}