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
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      // backgroundColor: Colors.red,
      drawer: const CustomDrawerWidget(),
      body: widget.page,
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _activeIndex,
        isOrg: widget.isOrg,
        onTap: (index) {
          setState(() {
            _activeIndex = index;
          });
          _navigateToPage(index);
        },
      ),
    );
  }

  void _navigateToPage(int index) {
    log("index:$index");
    if (widget.isOrg) {
      // Organization navigation
      switch (index) {
        case 0:
          context.goNamed('org-dashboard');
          break;
        case 1:
          // context.goNamed('org-dashboard');
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
      // User navigation
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
