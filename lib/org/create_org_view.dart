import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/models/organization.dart';
import 'package:sneekin/services/app_store.dart';

class CreateOrgView extends StatefulWidget {
  const CreateOrgView({super.key});

  @override
  _CreateOrgViewState createState() => _CreateOrgViewState();
}

class _CreateOrgViewState extends State<CreateOrgView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cinController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController panController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1F293F),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                        // onTap: () {
                        //   // log("Reloading");
                        //   context.go("/root");
                        // },
                        child: Image.asset("assets/icons/launcher_icon.png", height: 40)),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      "Sneek",
                      style: GoogleFonts.inter(fontSize: 17, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  "Create your organization",
                  style: GoogleFonts.poppins(
                    textStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Name Input Field
                _buildInputField(
                  controller: nameController,
                  labelText: 'Organization Name',
                  hintText: 'Enter organization name',
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: emailController,
                  labelText: 'Organization Email',
                  hintText: 'Enter organization email',
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: gstinController,
                  labelText: 'Organization GSTIN',
                  hintText: 'Enter organization gstin',
                ),
                const SizedBox(height: 20),

                // CIN Input Field
                _buildInputField(
                  controller: cinController,
                  labelText: 'Organization CIN',
                  hintText: 'Enter CIN',
                ),
                const SizedBox(height: 20),

                // PAN Input Field
                _buildInputField(
                  controller: panController,
                  labelText: 'Organization PAN',
                  hintText: 'Enter PAN',
                ),
                const SizedBox(height: 40),

                // Submit Button
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build text input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.inter(color: Colors.white),
        hintText: hintText,
        hintStyle: GoogleFonts.inter(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  // Helper function to build submit button
  Widget _buildSubmitButton(BuildContext context) {
    // return
    // Consumer<AuthServices>(
    //   builder: (context, authService, _) {
    return Consumer<AppStore>(builder: (context, value, _) {
      return ElevatedButton(
        onPressed: () async {
          if (nameController.text.isEmpty || cinController.text.isEmpty || panController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all fields'),
              ),
            );
            return;
          }
          var random = Random();
          int fiveDigitNumber = 10000 + random.nextInt(90000);

          final resp = await value.storeOrgData(
            org: Organization(
                org_id: fiveDigitNumber,
                org_name: nameController.text,
                org_email: emailController.text,
                org_gstin: gstinController.text,
                org_pan: panController.text,
                org_cin: cinController.text,
                org_cin_url: "",
                org_cin_verified: false,
                org_gstin_url: "",
                org_address: "",
                org_gstin_verified: false,
                org_logo_url: "",
                org_pan_url: "",
                org_pan_verified: false,
                org_website_name: ""),
          );

          dev.log("resp: $resp");

          if (resp == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Organization registered successfully.'),
              ),
            );
            context.go("/root");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Some error occurred.'),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6500),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size.fromHeight(50), // Full-width button
        ),
        child: value.isLoading
            ? const SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(),
              )
            : Text(
                'Register Organization',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
      );
    });
  }
  // );
}
