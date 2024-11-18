import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/auth/auth_screen.dart';
import 'package:sneekin/auth/otp_page.dart';
import 'package:sneekin/org/add_org_app_account.dart';
import 'package:sneekin/org/create_org_view.dart';
import 'package:sneekin/org/org_app_account_profile.dart';
import 'package:sneekin/org/org_dashboard.dart';
import 'package:sneekin/org/org_dashboard_view.dart';
import 'package:sneekin/org/org_home_view.dart';
import 'package:sneekin/org/show_org_app_account.dart';
import 'package:sneekin/org/virtual_accounts_of_org_apps_accounts.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/splash/splash_screen.dart';
import 'package:sneekin/user/qr_login_view.dart';
import 'package:sneekin/user/user_home_view.dart';
import 'package:sneekin/user/user_profile_page.dart';
import 'package:sneekin/widgets/navigation_shell.dart';

import '../user/create_user_view.dart';
import '../widgets/page_wrapper.dart'; // Import PageWrapper

class RouterServices with ChangeNotifier {
  GoRouter _goRouter(AuthServices authServices) => GoRouter(
        initialLocation: '/splash',
        routes: [
          // Tab Controller

          GoRoute(
            path: '/root',
            name: 'root',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const NavigationShell(),
            ),
          ),

          GoRoute(
            path: '/splash',
            name: 'splash',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SplashScreen(),
            ),
          ),

          // Auth Routes

          GoRoute(
            path: '/auth',
            name: 'auth',
            pageBuilder: (context, state) => MaterialPage(key: state.pageKey, child: const OtpPage()),
          ),
          GoRoute(
            path: '/creation',
            name: 'creation',
            pageBuilder: (context, state) => MaterialPage(key: state.pageKey, child: const AuthScreen()),
          ),

          // User Management Routes

          GoRoute(
            path: '/create-user',
            name: 'create-user',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const CreateUserScreen(),
            ),
          ),

          GoRoute(
            path: '/user-page-page',
            name: 'user-home-page',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PageWrapper(
                page: UserHomeView(),
                isOrg: false,
              ),
            ),
          ),

          GoRoute(
            path: '/create-virtual-account',
            name: 'create-virtual-account',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: PageWrapper(
                page: QrLoginView(),
                isOrg: false,
              ),
            ),
          ),

          GoRoute(
            path: '/user-profile-page',
            name: 'user-profile-page',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PageWrapper(
                page: UserProfilePage(),
                isOrg: false,
              ),
            ),
          ),

          // Orginization Routes

          GoRoute(
            path: '/create-org',
            name: 'create-org',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const CreateOrgView(),
            ),
          ),
          GoRoute(
            path: '/add-org-app-account',
            name: 'add-org-app-account',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PageWrapper(
                page: AddOrgAppAccountPage(),
                isOrg: true,
              ),
            ),
          ),
          GoRoute(
            path: '/org-app-account-profile',
            name: 'org-app-account-profile',
            pageBuilder: (context, state) {
              final orgAccount = state.extra as Map<String, dynamic>?;
              return MaterialPage(
                key: state.pageKey,
                child: PageWrapper(
                  page: OrgAppAccountProfile(
                    orgAccount: orgAccount ?? {},
                  ),
                  isOrg: true,
                ),
              );
            },
          ),
          GoRoute(
            path: '/org-dashboard-view',
            name: 'org-dashboard-view',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PageWrapper(
                page: OrgDashboardView(),
                isOrg: true,
              ),
            ),
          ),
          GoRoute(
            path: '/org-dashboard',
            name: 'org-dashboard',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PageWrapper(
                page: OrgDashboard(),
                isOrg: true,
              ),
            ),
          ),
          GoRoute(
            path: '/org-home-view',
            name: 'org-home-view',
            pageBuilder: (context, state) {
              debugPrint("Navigating to Org Home View");
              return MaterialPage(
                key: state.pageKey,
                child: const PageWrapper(
                  page: OrgHomeView(),
                  isOrg: true,
                ),
              );
            },
          ),
          GoRoute(
            path: '/show-org-app-accounts',
            name: 'show-org-app-accounts',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: PageWrapper(
                page: ShowOrgAppAccountsPage(),
                isOrg: true,
              ),
            ),
          ),
          GoRoute(
            path: '/virtual-ac-org-app',
            name: 'virtual-ac-org-app',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PageWrapper(
                page: VirtualAccountsOfOrgAppAccount(),
                isOrg: true,
              ),
            ),
          ),
        ],
      );

  GoRouter getRouter(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context, listen: false);
    return _goRouter(authServices);
  }
}
