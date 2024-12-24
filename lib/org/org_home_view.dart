import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/models/org_app_account.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/widgets/notch_pointer.dart';
import '../widgets/custom_app_bar.dart';

class OrgHomeView extends StatefulWidget {
  const OrgHomeView({super.key});

  @override
  State<OrgHomeView> createState() => _OrgHomeViewState();
}

class _OrgHomeViewState extends State<OrgHomeView> {
  List<OrgAppAccount> _filteredAccounts = [];

  List<OrgAppAccount> _allUsersVirtualAccounts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() async {
      final auth = Provider.of<AuthServices>(context, listen: false);
      await auth.getOrgAppsAccounts();

      log("auth.orgAppsAccount length: ${auth.orgAppsAccount.length}");

      _allUsersVirtualAccounts = auth.orgAppsAccount;

      _filteredAccounts = _allUsersVirtualAccounts.length > 3
          ? _allUsersVirtualAccounts.sublist(3)
          : []; // Empty list if fewer than 5 accounts
      log("_filteredAccounts length: ${_filteredAccounts.length}");
    });
  }

  void _filterAccounts(String query) {
    log("Search Query: $query");
    // if (query.isEmpty)
    //   return;
    if (query.isEmpty) {
      log("Executing if block (empty query)");
      setState(() {
        log("_allUsersVirtualAccounts in search length: ${_allUsersVirtualAccounts.length}");
        // Include accounts starting from index 4
        _filteredAccounts = _allUsersVirtualAccounts.length > 3
            ? _allUsersVirtualAccounts.sublist(3) // Accounts after index 4
            : []; // Empty list if fewer than 5 accounts
      });
    } else {
      log("Executing else block (search query)");
      setState(() {
        // Filter accounts based on the query
        _filteredAccounts = _allUsersVirtualAccounts
            .where((account) => account.name.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      });
    }
  }

  void _toggleSearchBar() {
    setState(() {
      // if (_isExpanded) {
      //   _controller.clear(); // Clear the search field
      //   // _filteredAccounts = List.from(_allUsersVirtualAccounts); // Reset to original array
      // }
      _isExpanded = !_isExpanded;
    });
  }

  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height,
        // padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: CustomAppBar(
                  onDrawerButtonPressed: () {
                    log("Button pressed");
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              const SizedBox(height: 40),
              auth.orgAppsAccount.isEmpty
                  ? SizedBox.shrink()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 80, // Adjust height as needed
                            child: Wrap(
                              spacing: 20, // Adjust horizontal spacing
                              alignment: WrapAlignment.center, // Center the children
                              children: auth.orgAppsAccount
                                  .take(3) // Limit to 3 items
                                  .map((account) => GestureDetector(
                                        onTap: () {
                                          log("Account tapped: ${account.name}");
                                          context.go('/org-app-account-profile', extra: account);
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 5),
                                              width: 60,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: theme.textTheme.headlineLarge?.color,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  account.name[0],
                                                  style: GoogleFonts.inter(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              account.name.length > 6
                                                  ? '${account.name.substring(0, 6)}...' // Truncate and add ellipses
                                                  : account.name,
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
                        ],
                      ),
                    ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: _isExpanded ? const EdgeInsets.symmetric(horizontal: 10.0) : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: _isExpanded ? theme.scaffoldBackgroundColor : Colors.transparent,
                        ),
                        child: _isExpanded
                            ? TextFormField(
                                controller: _controller,
                                autofocus: true,
                                onChanged: _filterAccounts,
                                onTap: _toggleSearchBar,
                                style: GoogleFonts.inter(color: theme.textTheme.headlineLarge?.color),
                                decoration: InputDecoration(
                                  hintText: "Search an account...",
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
                                    borderSide: const BorderSide(color: Color(0xFFFF6500)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Color(0xFFFF6500)),
                                  ),
                                  filled: true,
                                  fillColor: theme.scaffoldBackgroundColor,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isExpanded)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Websites/Apps",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 5), // Space between text and icon
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFFFF6500)),
                      onPressed: () {
                        setState(() => _isExpanded = true);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 25),
              // if (auth.orgAppsAccount.length > 3)
              //   if (auth.orgAppsAccount.length > 3)
              //     Row(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Expanded(
              //           child: _isExpanded
              //               ? Padding(
              //                   padding: _isExpanded ? const EdgeInsets.all(30.0) : const EdgeInsets.all(0.0),
              //                   child: AnimatedContainer(
              //                     duration: const Duration(milliseconds: 300),
              //                     curve: Curves.easeInOut,
              //                     child: TextFormField(
              //                       controller: _controller,
              //                       autofocus: true,
              //                       onChanged: _filterAccounts,
              //                       onTap: () {
              //                         _toggleSearchBar();
              //                         // _controller.clear();
              //                       },
              //                       style: GoogleFonts.inter(color: theme.textTheme.headlineLarge?.color),
              //                       decoration: InputDecoration(
              //                         hintText: "Search an account...",
              //                         hintStyle: GoogleFonts.inter(
              //                           color: theme.textTheme.bodyLarge?.color,
              //                           fontSize: 13,
              //                         ),
              //                         suffixIcon: const Icon(Icons.search, color: Color(0xFFFF6500)),
              //                         enabledBorder: OutlineInputBorder(
              //                           borderRadius: BorderRadius.circular(8.0),
              //                           borderSide:
              //                               const BorderSide(color: Color(0xFFFF6500)), // Orange color
              //                         ),
              //                         focusedBorder: OutlineInputBorder(
              //                           borderRadius: BorderRadius.circular(8.0),
              //                           borderSide:
              //                               const BorderSide(color: Color(0xFFFF6500)), // Orange color
              //                         ),
              //                         filled: true,
              //                         fillColor: theme.scaffoldBackgroundColor,
              //                         contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              //                       ),
              //                     ),
              //                   ),
              //                 )
              //               : const SizedBox(), // When collapsed, no expanded widget
              //         ),
              //         if (!_isExpanded)
              //           Padding(
              //             padding: const EdgeInsets.only(right: 8.0),
              //             child: IconButton(
              //               icon: const Icon(Icons.search, color: Color(0xFFFF6500)),
              //               onPressed: () => setState(() => _isExpanded = true),
              //             ),
              //           ),
              //       ],
              //     ),
              Expanded(
                child: _filteredAccounts.isEmpty
                    ? Center(
                        child: Text(
                          "No more accounts!",
                          style: GoogleFonts.inter(color: Colors.grey, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 0, bottom: 8, left: 20),
                        itemCount: _filteredAccounts.length,
                        itemBuilder: (context, index) {
                          final orgAccount = _filteredAccounts[index];

                          return Notch(orgAccount: orgAccount);
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
