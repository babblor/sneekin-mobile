import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/helper_services.dart';

class CustomIcons {
  static const IconData user_home_outline_rounded = Icons.home_outlined;
  static const IconData qr_code_scanner = Icons.qr_code_scanner_rounded;
  static const IconData user_profile_outlined = Icons.person_outlined;
}

class CustomOrgIcons {
  static const IconData org_home_outline_rounded = FontAwesomeIcons.globe;
  static const IconData org_dashboard = Icons.speed_outlined;
  static const IconData org_profile = Icons.person_outlined;
}

class CustomNavigationBar extends StatefulWidget {
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
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late int _page;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _page = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _page = widget.currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HelperServices>(builder: (context, helper, _) {
      return CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: widget.currentIndex,
        height: 60.0,
        animationCurve: Curves.linear,
        animationDuration: const Duration(milliseconds: 0),
        items: widget.isOrg
            ? [
                _buildNavItem(
                    helper.hasReachedOrgAppAccountPage
                        ? CustomOrgIcons.org_home_outline_rounded
                        : CustomOrgIcons.org_dashboard,
                    "Dashboard",
                    0),
                _buildImageItem("assets/images/websites-apps.webp", "Websites/Apps", 1),
                _buildNavItem(CustomOrgIcons.org_profile, "Profile", 2),
              ]
            : [
                _buildNavItem(CustomIcons.user_home_outline_rounded, "Home", 0),
                _buildNavItem(CustomIcons.qr_code_scanner, "Scan", 1),
                _buildNavItem(CustomIcons.user_profile_outlined, "Profile", 2),
              ],
        color: const Color.fromARGB(66, 22, 22, 22),
        buttonBackgroundColor: Colors.black12,
        backgroundColor: Colors.transparent,
        onTap: (index) {
          setState(() {
            _page = index;
          });

          // Reset hasReachedOrgAppAccountPage when navigating to a different page
          if (index != 4 && index != 5) {
            // Adjust index based on your navigation structure
            Provider.of<HelperServices>(context, listen: false).resetHasReachedOrgAppAccountPage();
          }

          widget.onTap(index);
        },
        letIndexChange: (index) => true,
      );
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = index == widget.currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color.fromARGB(255, 32, 30, 30) : Colors.transparent,
      ),
      padding: EdgeInsets.all(isSelected ? 12 : 0),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? const Color(0xFFFF6500) : Colors.white,
      ),
    );
  }

  Widget _buildImageItem(String asset, String label, int index) {
    bool isSelected = index == widget.currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color.fromARGB(255, 32, 30, 30) : Colors.transparent,
      ),
      padding: EdgeInsets.all(isSelected ? 12 : 0),
      child: Image.asset(
        asset,
        height: 22,
        width: 22,
        color: isSelected ? const Color(0xFFFF6500) : Colors.white,
      ),
    );
  }
}
