import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sneekin/widgets/custom_drawer.dart';
import 'package:sneekin/widgets/custom_nav_shell.dart';

class PageWrapper extends StatefulWidget {
  final Widget page;
  final bool isOrg;

  const PageWrapper({super.key, required this.page, required this.isOrg});

  @override
  _PageWrapperState createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper> {
  int _activeIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateActiveIndex();
  }

  void _updateActiveIndex() {
    final String currentRoute = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    log("Current Route: $currentRoute");

    if (currentRoute.contains("org-app-account-profile")) {
      return; // Do not reset activeIndex when navigating away
    }

    setState(() {
      _activeIndex = _getIndexFromRoute(currentRoute);
    });
  }

  bool _handlePop() {
    if (_activeIndex != 0) {
      setState(() {
        _activeIndex = 0;
      });
      _navigateToPage(0);
      return false; // Prevent the app from popping
    }
    return true; // Allow the app to pop (exit)
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (popDisposition) => _handlePop(),
      child: Scaffold(
        drawer: const CustomDrawerWidget(),
        body: widget.page,
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _activeIndex,
          isOrg: widget.isOrg,
          onTap: (index) {
            if (index != _activeIndex) {
              setState(() {
                _activeIndex = index;
              });
              _navigateToPage(index);
            }
          },
        ),
      ),
    );
  }

  int _getIndexFromRoute(String route) {
    if (widget.isOrg) {
      switch (route) {
        case '/org-dashboard':
          return 0;
        case '/org-home-view':
          return 1;
        case '/org-dashboard-view':
          return 2;
        default:
          return 0;
      }
    } else {
      switch (route) {
        case '/user-home-page':
          return 0;
        case '/create-virtual-account':
          return 1;
        case '/user-profile-page':
          return 2;
        default:
          return 0;
      }
    }
  }

  void _navigateToPage(int index) {
    log("Navigating to index: $index");
    if (widget.isOrg) {
      switch (index) {
        case 0:
          context.goNamed('org-dashboard');
          break;
        case 1:
          context.goNamed('org-home-view');
          break;
        case 2:
          context.goNamed("org-dashboard-view");
          break;
        default:
          context.goNamed('org-dashboard');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.goNamed('user-home-page');
          break;
        case 1:
          context.goNamed('create-virtual-account');
          break;
        case 2:
          context.goNamed('user-profile-page');
          break;
        default:
          context.goNamed('user-home-page');
          break;
      }
    }
  }
}
