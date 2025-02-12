import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/org/org_dashboard.dart';
import 'package:sneekin/org/org_dashboard_view.dart';
import 'package:sneekin/org/org_home_view.dart';
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
  bool isQrLoading = true;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
    return Consumer2<AppStore, HelperServices>(
      builder: (context, app, helper, child) {
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

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              log("PopScope didPop: $didPop");
              return;
            }

            log("Result: $result");

            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Exit App"),
                  content: const Text("Are you sure you want to quit the app?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
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
            body: Navigator(
              key: _navigatorKey,
              pages: [
                MaterialPage(child: _getPage(_activeIndex, app.isSignedIn)),
              ],
              onPopPage: (route, result) {
                if (!route.didPop(result)) {
                  return false;
                }
                return true;
              },
            ),
            bottomNavigationBar: CustomNavigationBar(
              currentIndex: _activeIndex,
              isOrg: !app.isSignedIn,
              onTap: (index) {
                if (index != _activeIndex) {
                  setState(() {
                    // helper.changeScreen(index);
                    _activeIndex = index;
                    log("User tapped tab: $index");
                  });
                } else {
                  log("User tapped the current tab: $index");
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _getPage(int index, bool isUser) {
    if (isUser) {
      switch (index) {
        case 0:
          return const UserHomeView();
        case 1:
          return QrLoginView(isQrLoading: isQrLoading);
        case 2:
          return const UserProfilePage();
        default:
          return const UserHomeView();
      }
    } else {
      switch (index) {
        case 0:
          return const OrgDashboard();
        case 1:
          return const OrgHomeView();
        case 2:
          return const OrgDashboardView();
        // case 3:
        //   return const AddOrgAppAccountPage();
        // case 4:
        //   return OrgAppAccountProfile(
        //     orgAccount: OrgAppAccount(clientId: "", id: 0, name: ""),
        //   );
        // case 5:
        //   return const VirtualAccountsOfOrgAppAccount();
        // case 6:
        //   return ShowOrgAppAccountsPage();
        default:
          return const OrgDashboard();
      }
    }
  }
}
