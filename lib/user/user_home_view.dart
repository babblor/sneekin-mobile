import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_app_bar.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  List<bool> isOpen = [];
  String? phoneNumber = "1234567890"; // Dummy phone number for placeholder

  // Dummy data for virtual accounts
  List<Map<String, dynamic>> virtualAccounts = [
    {
      "appname": "Facebook",
      "virtualId": "123abc01",
      "applogo": "F",
      "createdDate": "2024-01-01",
    },
    {
      "appname": "PayPal",
      "virtualId": "123xyz02",
      "applogo": "P",
      "createdDate": "2024-01-01",
    },
    {
      "appname": "WhatsApp",
      "virtualId": "123xyz03",
      "applogo": "W",
      "createdDate": "2024-01-01",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the isOpen list based on the number of virtual accounts
    isOpen = List.generate(virtualAccounts.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              onDrawerButtonPressed: () {
                log("Button pressed");
                Scaffold.of(context).openDrawer();
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Virtual Accounts",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  // color: Colors.white,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 60, right: 30),
                child: virtualAccounts.isEmpty
                    ? Center(
                        child: Text(
                          "No active accounts!",
                          style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: virtualAccounts.length,
                        itemBuilder: (context, index) {
                          var session = virtualAccounts[index];
                          return GestureDetector(
                            onTap: () => toggleContainer(index), // Toggle the card
                            child: Container(
                              // height: 50,
                              // padding: EdgeInsets.only(left: 16),
                              margin: const EdgeInsets.only(top: 30, bottom: 10),
                              width: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).secondaryHeaderColor,
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Header Section
                                      SizedBox(
                                        height: 70,
                                        child: SizedBox(
                                          height: 50,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                session['appname'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              const Icon(Icons.circle, size: 15, color: Colors.green)
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Expandable Section
                                      if (isOpen[index])
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Virtual ID: ${session['virtualId']}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Created Date: ${session['createdDate']}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "App Name: ${session['appname']}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              )
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  // Notch Section
                                  Positioned(
                                    top: -26, // Adjust the vertical offset as needed
                                    right: 0,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Notch background shape
                                        CustomPaint(
                                          size:
                                              const Size(60, 45), // Adjust the size to best match your design
                                          painter: NotchPainter(context: context),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5, left: 25),
                                          child: FaIcon(
                                            FontAwesomeIcons.globe,
                                            size: 17,
                                            color: theme.textTheme.headlineLarge?.color,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 16,
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
                                          session["applogo"],
                                          // size: 20,
                                          // color: theme.textTheme.bodyLarge?.color,
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: theme.textTheme.bodyLarge?.color),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleContainer(int index) {
    setState(() {
      isOpen[index] = !isOpen[index];
    });
  }

  void snackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
