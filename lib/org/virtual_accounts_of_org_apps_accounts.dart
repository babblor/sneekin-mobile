import 'dart:developer';
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class VirtualAccountsOfOrgAppAccount extends StatefulWidget {
  const VirtualAccountsOfOrgAppAccount({super.key});

  @override
  State<VirtualAccountsOfOrgAppAccount> createState() => _VirtualAccountsOfOrgAppAccountState();
}

class _VirtualAccountsOfOrgAppAccountState extends State<VirtualAccountsOfOrgAppAccount> {
  final TextEditingController orgAppNameController = TextEditingController();
  final TextEditingController orgAppEmailController = TextEditingController();
  final TextEditingController orgAppMobileController = TextEditingController();
  final TextEditingController orgAppCountryCodeController = TextEditingController();
  final TextEditingController orgAppLogoUrlController = TextEditingController();

  // Sample data for virtual accounts
  List<Map<String, String>> virtualAccounts = [
    {"name": "Virtual Account 1", "email": "va1@example.com"},
    {"name": "Virtual Account 2", "email": "va2@example.com"},
    {"name": "Virtual Account 3", "email": "va3@example.com"},
    {"name": "Virtual Account 4", "email": "va4@example.com"},
    {"name": "Virtual Account 5", "email": "va5@example.com"},
  ];

  void deleteVirtualAccount(int index) {
    setState(() {
      virtualAccounts.removeAt(index);
    });
  }

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
            Text(
              'Associated Virtual Accounts',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: virtualAccounts.length,
                itemBuilder: (context, index) {
                  return _buildVirtualAccountCard(context, index, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualAccountCard(BuildContext context, int index, ThemeData theme) {
    return Card(
      color: theme.secondaryHeaderColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          virtualAccounts[index]['name'] ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
        subtitle: Text(
          virtualAccounts[index]['email'] ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: theme.colorScheme.error,
          onPressed: () => deleteVirtualAccount(index),
        ),
      ),
    );
  }
}
