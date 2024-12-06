import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

      _filteredAccounts = _allUsersVirtualAccounts.length > 4
          ? _allUsersVirtualAccounts.sublist(4)
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
        _filteredAccounts = _allUsersVirtualAccounts.length > 4
            ? _allUsersVirtualAccounts.sublist(4) // Accounts after index 4
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.globe,
                      size: 18,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Websites/Apps",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                // color: Colors.red,
                height: 80, // Adjust height as needed
                padding: const EdgeInsets.only(left: 34, right: 55),
                child: auth.orgAppsAccount.isEmpty
                    ? null
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: auth.orgAppsAccount.length.clamp(0, 4), // Limit to 4 items
                        itemBuilder: (context, index) {
                          var account = auth.orgAppsAccount[index];
                          return GestureDetector(
                            onTap: () {
                              log("Horizontal index: $index");
                              context.go('/org-app-account-profile', extra: account);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0), // Control horizontal spacing here
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 5), // Adjust vertical spacing if needed
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
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    account.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (auth.orgAppsAccount.length > 4)
                if (auth.orgAppsAccount.length > 4)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _isExpanded
                            ? Padding(
                                padding: _isExpanded ? const EdgeInsets.all(30.0) : const EdgeInsets.all(0.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: TextFormField(
                                    controller: _controller,
                                    autofocus: true,
                                    onChanged: _filterAccounts,
                                    onTap: () {
                                      _toggleSearchBar();
                                      // _controller.clear();
                                    },
                                    style: GoogleFonts.inter(color: theme.textTheme.headlineLarge?.color),
                                    decoration: InputDecoration(
                                      hintText: "Search an account...",
                                      hintStyle: GoogleFonts.inter(
                                        color: theme.textTheme.bodyLarge?.color,
                                        fontSize: 13,
                                      ),
                                      suffixIcon: const Icon(Icons.search, color: Color(0xFFFF6500)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide:
                                            const BorderSide(color: Color(0xFFFF6500)), // Orange color
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide:
                                            const BorderSide(color: Color(0xFFFF6500)), // Orange color
                                      ),
                                      filled: true,
                                      fillColor: theme.scaffoldBackgroundColor,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(), // When collapsed, no expanded widget
                      ),
                      if (!_isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Color(0xFFFF6500)),
                            onPressed: () => setState(() => _isExpanded = true),
                          ),
                        ),
                    ],
                  ),
              // if (auth.orgAppsAccount.length > 4)
              // SizedBox(
              //   height: 15,
              // ),
              Expanded(
                child: _filteredAccounts.isEmpty
                    ? Center(
                        child: Text(
                          "No more accounts!",
                          style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color, fontSize: 18),
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
