import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';

class AddOrgAppAccountPage extends StatefulWidget {
  const AddOrgAppAccountPage({super.key});

  @override
  State<AddOrgAppAccountPage> createState() => _AddOrgAppAccountPageState();
}

class _AddOrgAppAccountPageState extends State<AddOrgAppAccountPage> {
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController appEmailController = TextEditingController();
  bool isMobileApp = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: theme.scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            CustomAppBar(
              onDrawerButtonPressed: () {
                log("Drawer button pressed");
                Scaffold.of(context).openDrawer();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Add Org App Account",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'App Name',
                      controller: appNameController,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'App Email',
                      controller: appEmailController,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Is Mobile App?',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Switch(
                          value: isMobileApp,
                          onChanged: (value) {
                            setState(() {
                              isMobileApp = value;
                            });
                          },
                          activeColor: theme.textTheme.headlineLarge?.color,
                          inactiveThumbColor: theme.secondaryHeaderColor,
                          inactiveTrackColor: Colors.grey.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.textTheme.headlineLarge?.color,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        // Implement logic to add app account here
                      },
                      child: Text(
                        'Add App Account',
                        style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: theme.secondaryHeaderColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color),
        filled: true,
        fillColor: theme.secondaryHeaderColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
