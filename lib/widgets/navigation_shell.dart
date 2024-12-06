import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/org/add_org_app_account.dart';
import 'package:sneekin/org/create_org_view.dart';
import 'package:sneekin/org/org_dashboard.dart';
import 'package:sneekin/org/org_dashboard_view.dart';
import 'package:sneekin/org/org_home_view.dart';
import 'package:sneekin/org/show_org_app_account.dart';
import 'package:sneekin/org/virtual_accounts_of_org_apps_accounts.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/helper_services.dart';
import 'package:sneekin/user/qr_login_view.dart';
import 'package:sneekin/user/user_home_view.dart';
import 'package:sneekin/user/user_profile_page.dart';
import 'package:sneekin/widgets/custom_drawer.dart';
import 'package:sneekin/widgets/custom_nav_shell.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  NavigationShellState createState() => NavigationShellState();
}

class NavigationShellState extends State<NavigationShell> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      log("calling microtask for initializeOrgData in Nav shell");
      Provider.of<AppStore>(context, listen: false).initializeOrgData();
      log("calling microtask for initializeUserData in Nav shell");
      Provider.of<AppStore>(context, listen: false).initializeUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStore>(
      builder: (context, app, child) {
        log("initially isSigned in status: ${app.isSignedIn}");
        log("initially isOrgSigned in status: ${app.isOrgSignedIn}");
        if (app.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
          );
        }

        final List<Widget> pages = app.isSignedIn
            ? [
                const UserHomeView(),
                const QrLoginView(),
                const UserProfilePage(),
              ]
            : [
                const OrgDashboard(),
                const OrgHomeView(),
                const OrgDashboardView(),
                const AddOrgAppAccountPage(),
                const CreateOrgView(),
                const VirtualAccountsOfOrgAppAccount(),
                ShowOrgAppAccountsPage(),
              ];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              log("PopScope didPop: $didPop");
              return;
            }

            log("Result: $result");

            // Show a confirmation dialog
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Exit App"),
                  content: const Text("Are you sure you want to quit the app?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false), // Do not exit
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true), // Exit the app
                      child: const Text("Yes"),
                    ),
                  ],
                );
              },
            );
          },
          child: Scaffold(
            key: context.read<HelperServices>().globalScaffoldKey,
            drawer: const CustomDrawerWidget(),
            body: IndexedStack(
              index: _activeIndex,
              children: pages,
            ),
            bottomNavigationBar: CustomNavigationBar(
              currentIndex: _activeIndex,
              isOrg: !app.isSignedIn,
              onTap: (index) {
                setState(() {
                  _activeIndex = index;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
