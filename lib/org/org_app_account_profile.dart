import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneekin/org/apikeysdialog.dart';
import 'package:sneekin/widgets/custom_app_bar.dart';

class OrgAppAccountProfile extends StatefulWidget {
  final Map<String, dynamic> orgAccount;

  const OrgAppAccountProfile({
    super.key,
    required this.orgAccount,
  });

  @override
  State<OrgAppAccountProfile> createState() => _OrgAppAccountProfileState();
}

class _OrgAppAccountProfileState extends State<OrgAppAccountProfile> {
  int currentPage = 1;
  final int rowsPerPage = 5;

  final List<Map<String, dynamic>> userData = List.generate(
    100,
    (index) => {
      'User ID': '$index',
      'Username': 'User $index',
      'Age': 20 + (index % 30),
      'Created Time': '2023-01-01 12:00 PM',
      'Created App': 'App${index % 5}',
      'Last Login Time': '2023-01-05 09:00 AM',
      'Last Login App': 'App${index % 3}',
      'Payment Status': index % 2 == 0 ? 'Paid' : 'Pending',
    },
  );

  bool _isSearchActive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage).clamp(0, userData.length);

    return SafeArea(
      child: Container(
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
              const SizedBox(height: 70),
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25, left: 30),
                          child: FaIcon(
                            FontAwesomeIcons.globe,
                            size: 20,
                            color: theme.textTheme.headlineLarge?.color,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Facebook",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: theme.textTheme.headlineLarge?.color),
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const ApiKeysDialog(),
                                );
                              },
                              child: Icon(
                                Icons.key,
                                color: theme.textTheme.bodyLarge?.color,
                                size: 25,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _isSearchActive ? MediaQuery.of(context).size.width * 0.8 : 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                if (_isSearchActive)
                                  Expanded(
                                    child: TextFormField(
                                      autofocus: true,
                                      style: theme.textTheme.bodyLarge,
                                      decoration: InputDecoration(
                                        hintText: "Search...",
                                        hintStyle: theme.textTheme.bodySmall,
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: theme.iconTheme.color,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isSearchActive = !_isSearchActive;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        // Horizontal Scrollable Table
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(50),
                              1: FixedColumnWidth(100),
                              2: FixedColumnWidth(50),
                              3: FixedColumnWidth(150),
                              4: FixedColumnWidth(100),
                              5: FixedColumnWidth(150),
                              6: FixedColumnWidth(150),
                              7: FixedColumnWidth(150),
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              // Table Header
                              TableRow(
                                decoration: BoxDecoration(
                                  color: theme.secondaryHeaderColor,
                                ),
                                children: [
                                  _buildTableCell('ID', isHeader: true),
                                  _buildTableCell('Username', isHeader: true),
                                  _buildTableCell('Age', isHeader: true),
                                  _buildTableCell('Created Time', isHeader: true),
                                  _buildTableCell('Created App', isHeader: true),
                                  _buildTableCell('Last Login Time', isHeader: true),
                                  _buildTableCell('Last Login App', isHeader: true),
                                  _buildTableCell('Payment Status', isHeader: true),
                                ],
                              ),
                              // Table Rows
                              ...userData.sublist(startIndex, endIndex).map((user) {
                                return TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade800, // Set the desired color
                                        width: 1.0, // Set the desired border width
                                      ),
                                    ),
                                  ),
                                  children: [
                                    _buildTableCell(user['User ID']),
                                    _buildTableCell(user['Username']),
                                    _buildTableCell(user['Age'].toString()),
                                    _buildTableCell(user['Created Time']),
                                    _buildTableCell(user['Created App']),
                                    _buildTableCell(user['Last Login Time']),
                                    _buildTableCell(user['Last Login App']),
                                    _buildTableCell(user['Payment Status']),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Pagination
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: currentPage > 1 ? () => setState(() => currentPage = 1) : null,
                              icon: Icon(Icons.first_page, color: theme.textTheme.bodyLarge?.color),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
                              icon:
                                  Icon(Icons.chevron_left_outlined, color: theme.textTheme.bodyLarge?.color),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$currentPage',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed:
                                  endIndex < userData.length ? () => setState(() => currentPage++) : null,
                              icon:
                                  Icon(Icons.chevron_right_outlined, color: theme.textTheme.bodyLarge?.color),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: endIndex < userData.length
                                  ? () => setState(() => currentPage = (userData.length / rowsPerPage).ceil())
                                  : null,
                              icon: Icon(Icons.last_page, color: theme.textTheme.bodyLarge?.color),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: 35,
                    child: Container(
                      width: 105,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.textTheme.headlineLarge?.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'F',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(3.0),
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(100),
                  //       child: FloatingActionButton(
                  //         onPressed: () {
                  //           showDialog(
                  //             context: context,
                  //             builder: (context) => const ApiKeysDialog(),
                  //           );
                  //         },
                  //         backgroundColor: theme.textTheme.headlineLarge?.color,
                  //         child: FaIcon(
                  //           FontAwesomeIcons.key,
                  //           color: Colors.white,
                  //           size: 14,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: isHeader ? 16 : 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodyMedium?.color,
        ),
        textAlign: TextAlign.center,
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
