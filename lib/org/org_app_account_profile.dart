import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/models/org_app_account.dart';
import 'package:sneekin/org/apikeysdialog.dart';
import 'package:sneekin/org/org_app_account_details_dialog.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/widgets/custom_app_bar.dart';

import '../models/virtual_account.dart';

class OrgAppAccountProfile extends StatefulWidget {
  final OrgAppAccount orgAccount;

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

  bool _isSearchActive = false;

  bool canEdit = false;

  File? _orgAppsAccountLogoImage;

  bool hasImagePicked = false;

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickOrgLogoImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _orgAppsAccountLogoImage = File(image.path);
        hasImagePicked = true;
      });
    }
  }

  void _updateOrgAppAccountImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text("Upload Image"),
          content: Consumer<AuthServices>(builder: (context, auth, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  // onPressed: () => _pickImage(ImageSource.gallery),
                  onPressed: () {
                    _pickOrgLogoImage(setState);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Choose image"),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).textTheme.headlineLarge?.color,
                  child: auth.isLoading
                      ? SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        )
                      : FaIcon(
                          FontAwesomeIcons.chevronRight,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          size: 12,
                        ),
                )
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  List<VirtualAccount> _filteredAccounts = [];

  List<VirtualAccount> _allUsersVirtualAccounts = [];

  void _filterAccounts(String query) {
    log("Search Query: $query");
    if (query.isEmpty) {
      log("Executing if block (empty query)");
      setState(() {
        log("_allUsersVirtualAccounts in search length: ${_allUsersVirtualAccounts.length}");
        // Include accounts starting from index 4
        _filteredAccounts = _allUsersVirtualAccounts.isNotEmpty
            ? _allUsersVirtualAccounts // Accounts after index 4
            : []; // Empty list if fewer than 5 accounts
      });
    } else {
      log("Executing else block (search query)");
      setState(() {
        // Filter accounts based on the query
        _filteredAccounts = _allUsersVirtualAccounts
            .where((account) => account.orgAppName.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() async {
      final auth = Provider.of<AuthServices>(context, listen: false);
      await auth.getVirtualAccountsByOrgAppAccount(id: widget.orgAccount.id.toString());
      _allUsersVirtualAccounts = auth.websiteVirtualAccounts;
      _filteredAccounts = _allUsersVirtualAccounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final accounts = Provider.of<AuthServices>(context, listen: false).websiteVirtualAccounts;
    final theme = Theme.of(context);

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
              // Consumer<AuthServices>(builder: (context, auth, _) {

              // return
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
                          child: Image.asset(
                            "assets/images/paper-stack.png",
                            height: 25,
                            width: 25,
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
                        const SizedBox(height: 45),
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Row with Key Icon, Org Name, and Search Icon
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              OrgAppAccountDetailsDialog(account: widget.orgAccount),
                                        );
                                      },
                                      child: Icon(
                                        Icons.info_outline,
                                        color: theme.textTheme.headlineLarge?.color,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => ApiKeysDialog(account: widget.orgAccount),
                                          );
                                        },
                                        child:
                                            // Icon(
                                            //   Icons.passkey,
                                            //   color: theme.textTheme.headlineLarge?.color,
                                            //   size: 25,
                                            // ),
                                            Image.asset(
                                          "assets/images/passkey.png",
                                          height: 20,
                                          width: 20,
                                          color: theme.textTheme.headlineLarge?.color,
                                        )),
                                  ],
                                ),
                                // const SizedBox(width: 15),
                                // Name Text
                                Text(
                                  widget.orgAccount.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                // const SizedBox(width: 15),
                                // Hidden Search Icon (Replaced by Search Bar when Expanded)
                                const SizedBox(
                                  width: 5,
                                ),
                                if (!_isSearchActive)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSearchActive = !_isSearchActive;
                                      });
                                    },
                                    child: Icon(
                                      Icons.search,
                                      color: theme.textTheme.headlineLarge?.color,
                                      size: 26,
                                    ),
                                  ),
                              ],
                            ),

                            // Expandable Search Bar
                            if (_isSearchActive)
                              Positioned(
                                right: 25, // Adjust this for initial position
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 50,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5, // Expand to half screen width
                                  decoration: BoxDecoration(
                                    color: theme.secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                    // border: Border(
                                    //   bottom: BorderSide(
                                    //     color: Color(0xFFFF6500),
                                    //     width: 2.0, // Thickness of the underline
                                    //   ),
                                    // ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Search Icon Inside the Bar

                                      // Search Field
                                      Expanded(
                                        child: TextFormField(
                                          autofocus: true,
                                          style: theme.textTheme.bodyLarge,
                                          onChanged: _filterAccounts,
                                          decoration: InputDecoration(
                                            hintText: "Search...",
                                            hintStyle: theme.textTheme.bodySmall,
                                            border: InputBorder.none, // Remove internal borders
                                            contentPadding:
                                                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isSearchActive = !_isSearchActive; // Collapse the search bar
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                                          child: Icon(
                                            Icons.search,
                                            color: theme.textTheme.headlineLarge?.color,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer<AuthServices>(builder: (context, auth, _) {
                          if (auth.isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: theme.textTheme.headlineLarge?.color,
                              ),
                            );
                          }
                          if (auth.websiteVirtualAccounts.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    "No virtual accounts to show !",
                                    style: GoogleFonts.inter(fontSize: 17),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                ],
                              ),
                            );
                          }
                          final startIndex = (currentPage - 1) * rowsPerPage;
                          final endIndex =
                              (startIndex + rowsPerPage).clamp(0, auth.websiteVirtualAccounts.length);
                          return Column(
                            children: [
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
                                    2: FixedColumnWidth(100),
                                    3: FixedColumnWidth(120),
                                    4: FixedColumnWidth(120),
                                    5: FixedColumnWidth(120),
                                    6: FixedColumnWidth(120),
                                    7: FixedColumnWidth(120),
                                    8: FixedColumnWidth(150),
                                    9: FixedColumnWidth(50),
                                    10: FixedColumnWidth(150),
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
                                        _buildTableCell('Name', isHeader: true),
                                        _buildTableCell('Mobile ID', isHeader: true),
                                        _buildTableCell('Org App ID', isHeader: true),
                                        _buildTableCell('Org App Name', isHeader: true),
                                        _buildTableCell('Username', isHeader: true),
                                        _buildTableCell('Created App', isHeader: true),
                                        _buildTableCell('Last Login App', isHeader: true),
                                        _buildTableCell('Last Login Time', isHeader: true),
                                        _buildTableCell('Age', isHeader: true),
                                        _buildTableCell('Payment Due Status', isHeader: true),
                                      ],
                                    ),
                                    // Table Rows

                                    ..._filteredAccounts.sublist(startIndex, endIndex).map((user) {
                                      return TableRow(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade800,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        children: [
                                          _buildTableCell(user.id.toString()),
                                          _buildTableCell(user.name ?? "___"),
                                          _buildTableCell(
                                              (user.mobileID.toString() ?? 0.toString())), // Handle nulls
                                          _buildTableCell(user.orgAppId.toString()),
                                          _buildTableCell(user.orgAppName),
                                          _buildTableCell(user.username),
                                          _buildTableCell(user.createdApp),
                                          _buildTableCell(user.lastLoginApp),
                                          _buildTableCell(user.lastLoginTime?.toIso8601String() ?? "___"),
                                          _buildTableCell((user.ageGroup.toString() ?? 0.toString())),
                                          _buildTableCell(user.paymentDueStatus ?? "___"),
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
                                    icon: Icon(Icons.chevron_left_outlined,
                                        color: theme.textTheme.bodyLarge?.color),
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
                                    onPressed: endIndex < auth.websiteVirtualAccounts.length
                                        ? () => setState(() => currentPage++)
                                        : null,
                                    icon: Icon(Icons.chevron_right_outlined,
                                        color: theme.textTheme.bodyLarge?.color),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    onPressed: endIndex < auth.websiteVirtualAccounts.length
                                        ? () => setState(() => currentPage =
                                            (auth.websiteVirtualAccounts.length / rowsPerPage).ceil())
                                        : null,
                                    icon: Icon(Icons.last_page, color: theme.textTheme.bodyLarge?.color),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          );
                        })
                      ],
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: 35,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 105,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.textTheme.headlineLarge?.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: widget.orgAccount.logo == null || widget.orgAccount.logo!.isEmpty
                                ? Text(
                                    widget.orgAccount.name[0],
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      widget.orgAccount.logo!,
                                      width: 105,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        )

                        // if (canEdit)
                        // Positioned(
                        //   bottom: -10,
                        //   right: -10,
                        //   child: StatefulBuilder(
                        //       builder: (BuildContext context, void Function(void Function()) setState) {
                        //     return InkWell(
                        //       onTap: _updateOrgAppAccountImage,
                        //       child: Container(
                        //         width: 30,
                        //         height: 30,
                        //         decoration: BoxDecoration(
                        //           color:
                        //               // hasImagePicked ? Colors.green :
                        //               theme.textTheme.headlineLarge?.color,
                        //           shape: BoxShape.circle,
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black.withOpacity(0.1),
                        //               blurRadius: 5,
                        //               offset: const Offset(0, 3),
                        //             ),
                        //           ],
                        //         ),
                        //         child: const Center(
                        //           child: FaIcon(
                        //             FontAwesomeIcons.penToSquare,
                        //             color: Colors.white,
                        //             size: 15,
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   }),
                        // ),
                      ],
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
              // }),
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
          color: isHeader ? theme.textTheme.headlineLarge?.color : theme.textTheme.bodyMedium?.color,
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
