import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomIcons {
  static const IconData user_home_outline_rounded = Icons.home_outlined;
  static const IconData qr_code_scanner = Icons.qr_code_scanner_outlined;
  static const IconData user_profile_outlined = Icons.person_outlined;
}

class CustomOrgIcons {
  static const IconData org_home_outline_rounded = FontAwesomeIcons.globe;
  static const IconData org_dashboard = Icons.speed_outlined;
  static const IconData org_profile = Icons.person_outlined;
}

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final bool isOrg;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.isOrg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      // backgroundColor: Colors.red,
      backgroundColor: theme.secondaryHeaderColor,
      currentIndex: currentIndex,
      // selectedItemColor: theme.textTheme.bodyLarge?.color,
      onTap: onTap,
      showSelectedLabels: true,
      // showUnselectedLabels: true,
      iconSize: 25,
      items: isOrg
          ? [
              BottomNavigationBarItem(
                tooltip: "Dashboard",
                label: 'Dashboard',
                icon: Icon(
                  CustomOrgIcons.org_dashboard,
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
              BottomNavigationBarItem(
                tooltip: "Websites/Apps",
                label: 'Websites/Apps',
                icon: Image.asset(
                  "assets/images/websites-apps.webp",
                  height: 25,
                  width: 25,
                  color: Color.fromRGBO(255, 94, 0, 1).withOpacity(1),
                ),
              ),
              BottomNavigationBarItem(
                tooltip: "Profile",
                label: 'Profile',
                icon: Icon(
                  CustomOrgIcons.org_profile,
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
            ]
          : [
              BottomNavigationBarItem(
                  label: 'Home',
                  icon: Icon(
                    CustomIcons.user_home_outline_rounded,
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                  tooltip: "Home"),
              BottomNavigationBarItem(
                  label: 'Scan',
                  icon: Icon(
                    CustomIcons.qr_code_scanner,
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                  tooltip: "Scan"),
              BottomNavigationBarItem(
                  label: 'Profile',
                  icon: Icon(
                    CustomIcons.user_profile_outlined,
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                  tooltip: "Profile"),
            ],
    );
  }
}
