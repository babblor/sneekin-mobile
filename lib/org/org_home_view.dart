import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneekin/widgets/notch_pointer.dart';
import '../widgets/custom_app_bar.dart';

class OrgHomeView extends StatefulWidget {
  const OrgHomeView({super.key});

  @override
  State<OrgHomeView> createState() => _OrgHomeViewState();
}

class _OrgHomeViewState extends State<OrgHomeView> {
  final String orgName = "Meta";
  final List<Map<String, dynamic>> websites = [
    {
      "name": "Facebook",
      "mobile": "1234567890",
      "countryCode": "+1",
      "email": "facebook@meta.com",
      "logo": FontAwesomeIcons.facebook,
      "isWeb": true
    },
    {
      "name": "Instagram",
      "mobile": "0987654321",
      "countryCode": "+1",
      "email": "instagram@meta.com",
      "logo": FontAwesomeIcons.instagram,
      "isWeb": false
    },
    {
      "name": "Threads",
      "mobile": "1122334455",
      "countryCode": "+1",
      "email": "threads@meta.com",
      "logo": FontAwesomeIcons.threads,
      "isWeb": true
    },
    // Add other entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              onDrawerButtonPressed: () {
                log("Button pressed");
                Scaffold.of(context).openDrawer();
              },
            ),
            const SizedBox(height: 40),
            // Center(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       FaIcon(
            //         FontAwesomeIcons.meta,
            //         size: 30,
            //         color: theme.textTheme.headlineLarge?.color,
            //       ),
            //       const SizedBox(width: 12),
            //       Text(
            //         orgName,
            //         style: GoogleFonts.poppins(
            //           fontSize: 24,
            //           fontWeight: FontWeight.bold,
            //           color: theme.textTheme.bodyLarge?.color,
            //           letterSpacing: 1.2,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 30),
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
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                itemCount: websites.length,
                itemBuilder: (context, index) {
                  final orgAccount = websites[index];

                  return Notch(orgAccount: orgAccount);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
