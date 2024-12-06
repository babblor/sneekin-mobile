import 'dart:developer';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:toastification/toastification.dart';

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _clientWebsiteController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<AppStore>(context, listen: false).initializeOrgData();
    });
  }

  bool hasOrgAppLogoPicked = false;
  File? _logoImage;

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _imageFile = File(image.path);
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _logoImage = File(image.path);
        hasOrgAppLogoPicked = true;
      });
    }
  }

  bool isMobile = false;

  void _showAddDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add App Account',
                    style: theme.textTheme.headlineSmall?.copyWith(color: theme.textTheme.bodyLarge?.color),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _nameController.clear();
                        _mobileController.clear();
                        _emailController.clear();
                        _clientWebsiteController.clear();
                        _logoImage = null;
                        hasOrgAppLogoPicked = false;
                      });
                      Navigator.pop(context);
                    },
                    child: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: theme.textTheme.headlineLarge?.color,
                      size: 18,
                    ),
                  )
                ],
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                hintText: 'Enter your name',
                                hintStyle: GoogleFonts.inter(fontSize: 13),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                              onSaved: (value) => _name = value,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          InkWell(
                            onTap: () {
                              _pickImage(setState);
                            },
                            child: CircleAvatar(
                                backgroundColor: theme.textTheme.headlineLarge?.color,
                                child: Icon(
                                  Icons.upload_file,
                                  color: hasOrgAppLogoPicked ? Colors.green : Colors.white,
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),

                      // IsMobile Checkbox
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Is Mobile?',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Checkbox(
                            value: isMobile,
                            onChanged: (value) {
                              log("checkbox: $isMobile");
                              setState(() {
                                isMobile = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Conditionally Show Client Website Field
                      if (!isMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Client Website',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _clientWebsiteController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Client Website is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                hintText: 'Enter client website',
                                hintStyle: GoogleFonts.inter(fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),

                      // Mobile Number Field
                      Row(
                        children: [
                          Text(
                            'Mobile Number',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          hintText: 'Enter Mobile Number',
                          hintStyle: GoogleFonts.inter(fontSize: 13),
                        ),
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          hintText: 'Enter App Email',
                          hintStyle: GoogleFonts.inter(fontSize: 13),
                        ),
                        onSaved: (value) => _appEmail = value,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              actions: [
                Consumer<AuthServices>(builder: (context, auth, _) {
                  return InkWell(
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      if (isMobile && _clientWebsiteController.text.isNotEmpty) {
                        showToast(
                          message: "Client Website should be empty for mobile apps",
                          type: ToastificationType.error,
                        );
                        return;
                      }
                      if (!isMobile && (_clientWebsiteController.text.isEmpty)) {
                        showToast(
                          message: "Client Website is required for non-mobile apps",
                          type: ToastificationType.error,
                        );
                        return;
                      }
                      final result = await auth.createOrgAppsAccount(
                          name: _nameController.text,
                          mobile: _mobileController.text,
                          email: _emailController.text,
                          // clientWebsite: isMobile ? "" : _clientWebsiteController.text,
                          clientWebsite: _clientWebsiteController.text,
                          logo: _logoImage ?? File(""),
                          isMobile: isMobile);
                      if (result == true) {
                        showToast(message: "Org Apps Account Added!", type: ToastificationType.success);
                        setState(() {
                          _nameController.clear();
                          _mobileController.clear();
                          _emailController.clear();
                          _clientWebsiteController.clear();
                          hasOrgAppLogoPicked = false;
                          _logoImage = null;
                          isMobile = false;
                        });
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          _nameController.clear();
                          _mobileController.clear();
                          _emailController.clear();
                          _clientWebsiteController.clear();
                          _logoImage = null;
                          isMobile = false;
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.textTheme.headlineLarge?.color,
                      child: Center(
                        child: auth.isLoading
                            ? SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              )
                            : const FaIcon(
                                FontAwesomeIcons.chevronRight,
                                color: Colors.white,
                                size: 15,
                              ),
                      ),
                    ),
                  );
                })
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final org = Provider.of<AppStore>(context, listen: false).org;
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

                        Consumer<AppStore>(builder: (context, app, _) {
                          return Row(
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
                                      app.org?.totalWebsites.toString() ?? 0.toString(),
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
                                      app.org?.totalMobileApps.toString() ?? 0.toString(),
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
                                    app.org?.totalVirtualAccountUsers.toString() ?? 0.toString(),
                                    style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ],
                          );
                        }),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 80,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () => _showAddDetailsDialog(),
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: theme.textTheme.headlineLarge?.color,
                                          shape: BoxShape.circle),
                                      child: const Center(
                                          child: FaIcon(
                                        FontAwesomeIcons.add,
                                        color: Colors.white,
                                        size: 20,
                                      )))),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
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
                            ],
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

                        Consumer<AppStore>(builder: (context, app, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    app.org?.name ?? "N/A",
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.bodyLarge?.color),
                                  ),
                                  const SizedBox(
                                    height: 10,
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
                                        app.org?.email ?? "N/A",
                                        style: GoogleFonts.inter(
                                            fontSize: 13, color: theme.textTheme.bodyLarge?.color),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
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
                                        app.org?.mobileNumbers?.first.mobileNumber ?? "N/A",
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
                          );
                        }),
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
