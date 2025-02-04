import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/widgets/custom_app_bar.dart';
import '../models/user_virtual_account.dart' as UserVirtualAccount;

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  List<bool> isOpen = [];
  String? phoneNumber = "1234567890"; // Dummy phone number for placeholder

  // final bool _isSearchActive = false;
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  List<UserVirtualAccount.VirtualAccount> _filteredAccounts = [];

  List<UserVirtualAccount.VirtualAccount> _allUsersVirtualAccounts = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final auth = Provider.of<AuthServices>(context, listen: false);
      await auth.getUserVirtualAccounts();

      if (auth.userVirtualAccounts.isNotEmpty) {
        log("all groups length: ${auth.virtualAccountsResp.groups.length}");
        log("all userVirtualAccounts.length: ${auth.userVirtualAccounts.length}");
        isOpen = List.generate(auth.userVirtualAccounts.length, (index) => false);
        log("isOpen length: ${isOpen}");
      }
      _allUsersVirtualAccounts = auth.userVirtualAccounts;

      // Initialize `_filteredAccounts` with accounts starting from index 4
      _filteredAccounts = _allUsersVirtualAccounts;
      log("initial _filteredAccounts length: ${_filteredAccounts.length}");
    });
  }

  void _filterAccounts(String query) {
    log("Search Query: $query");
    if (query.isEmpty) {
      log("Executing if block (empty query)");
      setState(() {
        log("_allUsersVirtualAccounts in search length: ${_allUsersVirtualAccounts.length}");
        // Include accounts starting from index 4
        _filteredAccounts = _allUsersVirtualAccounts;
      });
    } else {
      log("Executing else block (search query)");
      setState(() {
        // Filter accounts based on the query
        _filteredAccounts = _allUsersVirtualAccounts
            .where((account) => account.username.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      });
    }
  }

  UserVirtualAccount.VirtualAccount? _horizentalAccount;

  void _toggleSearchBar() {
    setState(() {
      // if (_isExpanded) {
      //   _controller.clear(); // Clear the search field
      //   // _filteredAccounts = List.from(_allUsersVirtualAccounts); // Reset to original array
      // }
      _isExpanded = !_isExpanded;
    });
  }

  final bool _isHorizentalAccountShow = false;

  @override
  Widget build(BuildContext context) {
    log("user_home_view built");
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Consumer<AuthServices>(builder: (context, auth, _) {
          if (auth.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.textTheme.headlineLarge?.color,
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomAppBar(
                  onDrawerButtonPressed: () {
                    log("Button pressed");
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Horizontal scroll view for first 3-4 accounts
              if (auth.virtualAccountsResp.groups.isNotEmpty && !auth.isLoading)
                Center(
                  child: Container(
                    height: 80, // Adjust height as needed
                    alignment: Alignment.center,
                    child: auth.virtualAccountsResp.groups.isEmpty
                        ? null
                        : Wrap(
                            spacing: 20, // Adjust horizontal spacing
                            alignment: WrapAlignment.center, // Center the children
                            children: auth.virtualAccountsResp.groups
                                // .take(3) // Limit to 3 items
                                .map((account) => GestureDetector(
                                      onTap: () {
                                        log("Account tapped: ${account.mobileId}");
                                        setState(() {
                                          // _horizentalAccount = account;
                                          // _isHorizentalAccountShow = !_isHorizentalAccountShow;
                                          _filteredAccounts = account.userVirtualAccounts;
                                        });
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 5), // Adjust vertical spacing if needed
                                            width: 60,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: theme.textTheme.headlineLarge?.color,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                account.mobileId.toString()[0],
                                                style: GoogleFonts.inter(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            account.mobileId.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Ensure proper truncation
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                  ),
                ),

              // if (_isExpanded)
              //   const SizedBox(
              //     height: 25,
              //   ),
              // if (auth.userVirtualAccounts.length > 3)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 40.0),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.end,
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       children: [
              //         if (_isExpanded)
              //           Expanded(
              //             child: AnimatedContainer(
              //               duration: const Duration(milliseconds: 300),
              //               width: _isExpanded ? double.infinity : 50,
              //               child: TextFormField(
              //                 controller: _controller,
              //                 autofocus: _isExpanded,
              //                 onChanged: _filterAccounts,
              //                 // onTap: _toggleSearchBar,
              //                 style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
              //                 decoration: InputDecoration(
              //                   hintText: _isExpanded ? "Search an account..." : null,
              //                   hintStyle: GoogleFonts.inter(
              //                     color: theme.textTheme.bodyLarge?.color,
              //                     fontSize: 13,
              //                   ),
              //                   suffixIcon: _isExpanded
              //                       ? InkWell(
              //                           onTap: () {
              //                             // reset();
              //                             _toggleSearchBar();
              //                           },
              //                           child: const Icon(Icons.search, color: Color(0xFFFF6500)))
              //                       : null,
              //                   enabledBorder: OutlineInputBorder(
              //                     borderRadius: BorderRadius.circular(8.0),
              //                     borderSide: const BorderSide(color: Color(0xFFFF6500)), // Orange color
              //                   ),
              //                   focusedBorder: OutlineInputBorder(
              //                     borderRadius: BorderRadius.circular(8.0),
              //                     borderSide: const BorderSide(color: Color(0xFFFF6500)), // Green color
              //                   ),
              //                   disabledBorder: OutlineInputBorder(
              //                     borderRadius: BorderRadius.circular(8.0),
              //                     borderSide:
              //                         BorderSide(color: theme.disabledColor), // Disabled color from theme
              //                   ),
              //                   filled: true,
              //                   fillColor: theme.scaffoldBackgroundColor,
              //                   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              //                 ),
              //               ),
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),

              const SizedBox(
                height: 15,
              ),
              if (auth.userVirtualAccounts.isNotEmpty && !auth.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_isExpanded)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: theme.scaffoldBackgroundColor,
                            ),
                            child: TextFormField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: _filterAccounts,
                              style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                hintText: "Search a virtual account...",
                                hintStyle: GoogleFonts.inter(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontSize: 13,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search, color: Color(0xFFFF6500)),
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = false;
                                      // _controller.clear();
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(color: Color(0xFFFF6500)), // Orange color
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(color: Color(0xFFFF6500)), // Orange color
                                ),
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                        ),
                      if (!_isExpanded)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Center(
                              child: Text(
                                "Virtual Accounts",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5), // Space between text and icon
                            IconButton(
                              icon: const Icon(Icons.search, color: Color(0xFFFF6500)),
                              onPressed: () => setState(() => _isExpanded = true),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: _filteredAccounts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/scanning.gif",
                              height: 125,
                              width: 125,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "No active accounts!",
                              style: GoogleFonts.inter(color: Colors.grey, fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8, left: 20, top: 1),
                        itemCount: _filteredAccounts.length,
                        itemBuilder: (context, index) {
                          var account = _filteredAccounts[index];
                          log("_filteredAccounts in listview: ${_filteredAccounts.length}");
                          return GestureDetector(
                            onTap: () {
                              toggleContainer(index);
                              log("index: $index");
                            },
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
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
                                      width: 230,
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        // height: 50,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // SizedBox(
                                              //   width: 15,
                                              // ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Row(
                                                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text("   "),
                                                      Text(
                                                        (account.username ?? "").length > 10
                                                            ? '${account.username.substring(0, 10)}...'
                                                            : account.username ?? "",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
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
                                              // Expandable Section
                                              if (!auth.isLoading &&
                                                  auth.userVirtualAccounts.isNotEmpty &&
                                                  isOpen.isNotEmpty)
                                                if (isOpen[index])
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 16, vertical: 8),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 15,
                                                        ),

                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start, // Align to the start vertically
                                                          children: [
                                                            Text(
                                                              "ID: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "${account.id}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow:
                                                                    TextOverflow.visible, // Allow wrapping
                                                                softWrap: true, // Ensure text wraps
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start, // Align vertically to the start
                                                          children: [
                                                            Text(
                                                              "Mobile No: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "${account.mobileNumber}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow:
                                                                    TextOverflow.visible, // Allow wrapping
                                                                softWrap: true, // Enable wrapping
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start, // Aligns content to the start vertically
                                                          children: [
                                                            Text(
                                                              "App Name: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "${account.orgAppName}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow:
                                                                    TextOverflow.visible, // Allow wrapping
                                                                softWrap: true, // Enable line breaks
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "Username: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                account.username,
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow:
                                                                    TextOverflow.visible, // Allow wrapping
                                                                softWrap: true, // Ensure text wraps
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start, // Aligns content to the top
                                                          children: [
                                                            Text(
                                                              "Created App: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "${account.createdApp}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow:
                                                                    TextOverflow.visible, // Allow wrapping
                                                                softWrap: true, // Enable line breaks
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start, // Aligns content to the top
                                                          children: [
                                                            Text(
                                                              "Last Login App: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "${account.lastLoginApp}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow:
                                                                    TextOverflow.visible, // Allow wrapping
                                                                softWrap: true, // Enable line breaks
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start, // Aligns content to the top
                                                          children: [
                                                            Text(
                                                              "Payment Status: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "${account.paymentDueStatus}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow: TextOverflow
                                                                    .visible, // Allows text to break into lines
                                                                softWrap: true, // Enables wrapping
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start, // Aligns content to the top
                                                          children: [
                                                            Text(
                                                              "Last Login Time: ",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "${account.lastLoginTime}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                                ),
                                                                overflow: TextOverflow
                                                                    .visible, // Allows text to break into lines
                                                                softWrap: true, // Enables wrapping
                                                              ),
                                                            ),
                                                          ],
                                                        )

                                                        // const SizedBox(
                                                        //   height: 5,
                                                        // )
                                                      ],
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ), // Placeholder height
                                    ),

                                    Positioned(
                                      top: 9,
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
                                            color: Colors.white,
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
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void toggleContainer(int index) {
    log("isOpen index: $index");
    log("isOpen[index]: ${isOpen[index]}");
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
