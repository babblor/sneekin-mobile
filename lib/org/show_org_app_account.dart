import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';

class ShowOrgAppAccountsPage extends StatelessWidget {
  final List<Map<String, dynamic>> orgAppAccounts = [
    {"appName": "Facebook", "appEmail": "support@facebook.com", "isMobileApp": false},
    {"appName": "Instagram", "appEmail": "support@instagram.com", "isMobileApp": true},
    {"appName": "Threads", "appEmail": "support@threads.com", "isMobileApp": false},
  ];

  ShowOrgAppAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              onDrawerButtonPressed: () {
                log("Button pressed");
                Scaffold.of(context).openDrawer();
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Org App Accounts",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: orgAppAccounts.length,
                itemBuilder: (context, index) {
                  final appAccount = orgAppAccounts[index];
                  return _buildOrgAppAccountTile(context, appAccount, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgAppAccountTile(BuildContext context, Map<String, dynamic> appAccount, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        context.go('/org-app-account-profile', extra: appAccount);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: theme.secondaryHeaderColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.secondaryHeaderColor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            appAccount['appName'],
            style: GoogleFonts.inter(
              fontSize: 18,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            appAccount['appEmail'],
            style: GoogleFonts.inter(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Icon(
            appAccount['isMobileApp'] ? Icons.phone_android : Icons.web,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
