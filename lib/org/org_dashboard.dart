import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_app_bar.dart';

class OrgDashboard extends StatefulWidget {
  const OrgDashboard({super.key});

  @override
  State<OrgDashboard> createState() => _OrgDashboardState();
}

class _OrgDashboardState extends State<OrgDashboard> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _appNumber;
  String? _appEmail;
  String? _uploadedFile;

  int selectedIndex = 0;

  // Example data for each circle
  final List<List<double>> dataSets = [
    List.generate(12, (index) => (index + 1) * 10.0 % 125), // Data for Circle 1
    List.generate(12, (index) => (index + 2) * 8.0 % 100), // Data for Circle 2
    List.generate(12, (index) => (index + 3) * 6.5 % 150), // Data for Circle 3
    List.generate(12, (index) => (index + 4) * 12.0 % 130), // Data for Circle 4
    List.generate(12, (index) => (index + 5) * 9.0 % 90), // Data for Circle 5
  ];

  void _showAddDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add App Account',
            style: theme.textTheme.headlineSmall?.copyWith(color: theme.textTheme.bodyLarge?.color),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  Row(
                    children: [
                      Text(
                        'Name',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.inter(fontSize: 13)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    onSaved: (value) => _name = value,
                  ),
                  const SizedBox(height: 16),

                  // App Number Field
                  Row(
                    children: [
                      Text(
                        'App Number',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter App Number',
                        hintStyle: GoogleFonts.inter(fontSize: 13)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                    onSaved: (value) => _appNumber = value,
                  ),
                  const SizedBox(height: 16),

                  // App Email Field
                  Row(
                    children: [
                      Text(
                        'App Email',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter App Email',
                        hintStyle: GoogleFonts.inter(fontSize: 13)),
                    onSaved: (value) => _appEmail = value,
                  ),
                  const SizedBox(height: 16),

                  // Profile Image Upload
                  Row(
                    children: [
                      Text(
                        'Profile Image',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Simulate file selection
                          setState(() {
                            _uploadedFile = 'ProfileImage.jpg'; // Mock file name
                          });
                        },
                        child: Text(
                          'Choose File',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _uploadedFile ?? 'No file selected',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.error)),
            ),
            ElevatedButton(
              style: const ButtonStyle(
                  // backgroundColor:
                  ),
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  _formKey.currentState?.save();
                  log('Name: $_name, App Number: $_appNumber, App Email: $_appEmail, File: $_uploadedFile');
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Website Name Heading
              CustomAppBar(
                onDrawerButtonPressed: () {
                  log("Button pressed");
                  Scaffold.of(context).openDrawer();
                },
              ),
              const SizedBox(height: 50),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40, // Adjust the vertical offset as needed
                    right: 0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Notch background shape

                        CustomPaint(
                          size: const Size(80, 70), // Adjust the size to best match your design
                          painter: NotchPainter(context: context),
                        ),
                        // Icon on top of the notch
                      ],
                    ),
                  ),
                  Container(
                    // color: theme.scaffoldBackgroundColor,
                    // height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: theme.secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                context.go("/org-home-view");
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.computer,
                                    size: 24,
                                    color: theme.textTheme.headlineLarge?.color,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "8",
                                    style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.go("/org-home-view");
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.mobile,
                                    size: 24,
                                    color: theme.textTheme.headlineLarge?.color,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "14",
                                    style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.peopleGroup,
                                  size: 24,
                                  color: theme.textTheme.headlineLarge?.color,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "64",
                                  style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dataSets.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selectedIndex == index
                                        ? theme.textTheme.headlineLarge?.color
                                        : Colors.grey,
                                  ),
                                  width: 50,
                                  height: 50,
                                  child: const Center(
                                      child: FaIcon(FontAwesomeIcons.facebook, color: Colors.white)),
                                ),
                              );
                            },
                          ),
                        ),

                        // Bar Chart
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: 50,
                                    getTitlesWidget: (value, _) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          value.toInt().toString(),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, _) {
                                      const months = [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec'
                                      ];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          months[value.toInt()],
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(
                                12,
                                (index) => BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: dataSets[selectedIndex][index], // Dynamic data
                                      color: Colors.blue,
                                      width: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Meta",
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 15,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "admin@meta.org",
                                      style: GoogleFonts.inter(
                                          fontSize: 13, color: theme.textTheme.bodyLarge?.color),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 15,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "+91-8537841568",
                                      style: GoogleFonts.inter(
                                          fontSize: 13, color: theme.textTheme.bodyLarge?.color),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            InkWell(
                                onTap: () {
                                  context.go("/org-dashboard-view");
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.penToSquare,
                                  color: theme.textTheme.headlineLarge?.color,
                                  size: 25,
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ],
              ),
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
    // Define the shadow paint
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Define the main shape paint
    final paint = Paint()..color = Theme.of(context).secondaryHeaderColor;

    // Define the path for the main shape
    final path = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * 0.6)
      ..lineTo(size.width * 0.6, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    // Create an outer shadow path by slightly inflating the path
    final shadowPath = Path()
      ..moveTo(size.width + 4, size.height + 4) // Start a little outside bottom-right
      ..lineTo(-4, size.height + 4) // Bottom-left outside
      ..lineTo(-4, size.height * 0.6 - 4) // Slightly outside the corner notch
      ..lineTo(size.width * 0.6 + 4, -4) // Top-left outside
      ..lineTo(size.width + 4, -4) // Top-right outside
      ..lineTo(size.width + 4, size.height + 4) // Close the path outside bottom-right
      ..close();

    // Draw the shadow path
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw the main shape path on top
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
