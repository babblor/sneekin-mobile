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
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<AppStore>(context, listen: false).initializeOrgData();
      Provider.of<AppStore>(context, listen: false).initializeUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStore>(
      builder: (context, app, child) {
        final List<Widget> pages = app.isSignedIn
            ? [
                const UserHomeView(),
                QrLoginView(),
                const UserProfilePage(),
              ]
            : [
                const OrgDashboard(),
                const OrgHomeView(),

                const OrgDashboardView(),
                // OrgDashboard(),
                const AddOrgAppAccountPage(),
                const CreateOrgView(),
                const VirtualAccountsOfOrgAppAccount(),
                ShowOrgAppAccountsPage(),
              ];

        if (app.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
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
        );
      },
    );
  }
}
