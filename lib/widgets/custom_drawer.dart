import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomDrawerWidget extends StatefulWidget {
  // AppStore app;
  CustomDrawerWidget({super.key
      // , required this.app
      });

  @override
  _CustomDrawerWidgetState createState() => _CustomDrawerWidgetState();
}

class _CustomDrawerWidgetState extends State<CustomDrawerWidget> {
  String name = "User Name"; // Placeholder for user name
  double _age = 21; // Placeholder for age
  String sneakId = "Sneak123"; // Placeholder for Sneak ID

  final TextEditingController _nameController = TextEditingController(text: "Meta");
  final TextEditingController _emailController = TextEditingController(text: "admin@meta.org");
  final TextEditingController _phoneController = TextEditingController(text: "+91-8537841568");
  final TextEditingController _addressController = TextEditingController(text: "Bengalore, Karnataka, India");

  // int? _age;

  @override
  void initState() {
    super.initState();
    // Initialize user data here if needed.
    // final app = Provider.of(context, listen: false);
    // _nameController.text = (app.isSignedIn ? app.user?.name : app.org?.org_name)!;
    // _emailController.text = (app.isSignedIn ? app.user?.email_id : app.org?.org_email)!;
    // // _phoneController.text = (widget.app.isSignedIn ? widget.app.user?. : widget.app.org?.org_name)!;
    // if (app.isSignedIn) {
    //   _age = (app.user?.age)!.toDouble();
    // }
    // log("widget.app.org?.org_address: ${app.org?.org_address}");
    // if (app.isOrgSignedIn) {
    //   _addressController.text = (app.org?.org_address == "" ? "N/A" : app.org?.org_address)!;
    // }
  }

  bool canEdit = false;
  bool isVerified = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = Provider.of<AppStore>(context, listen: false);

    _nameController.text = app.isSignedIn ? (app.user?.name ?? name) : (app.org?.org_name ?? name);
    _emailController.text = app.isSignedIn ? (app.user?.email_id ?? "N/A") : (app.org?.org_email ?? "N/A");
    if (app.isOrgSignedIn) {
      _addressController.text = (app.org?.org_address == "" ? "N/A" : app.org?.org_address)!;
    }
    if (app.isSignedIn) {
      _age = app.user!.age?.toDouble() ?? 0.0;
    }

    return SafeArea(
      child: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    // style: theme.textTheme.headlineLarge,
                    style: GoogleFonts.poppins(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineLarge?.color),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the drawer
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.iconTheme.color,
                      child: Center(
                        child: Text(
                          app.isSignedIn
                              ? (app.user?.name?.isNotEmpty == true ? app.user!.name![0] : "N/A")
                              : (app.org?.org_name?.isNotEmpty == true ? app.org!.org_name![0] : "N/A"),
                          style: GoogleFonts.inter(
                            fontSize: 35,
                            color: theme.textTheme.headlineLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    if (canEdit)
                      Positioned(
                        bottom: -5,
                        right: -5,
                        child: GestureDetector(
                          onTap: () {
                            // Handle edit action here
                            log("Edit button tapped!");
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.penToSquare,
                                color: theme.textTheme.headlineLarge?.color,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      log("canEdit: $canEdit");
                      setState(() {
                        canEdit = !canEdit;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FaIcon(
                        FontAwesomeIcons.penToSquare,
                        color: theme.textTheme.headlineLarge?.color,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              // _buildTextWithText(
              //     "ID",
              //     app.isSignedIn
              //         ? (app.user?.user_id?.toString() ?? sneakId)
              //         : (app.org?.org_id.toString() ?? sneakId),
              //     theme),
              // const SizedBox(
              //   height: 10,
              // ),
              if (canEdit)
                const SizedBox(
                  height: 15,
                ),
              _buildTextField("Name", _nameController, theme),
              if (canEdit)
                const SizedBox(
                  height: 15,
                ),
              _buildIconField(Icons.mail, _emailController, theme, true),
              if (canEdit)
                const SizedBox(
                  height: 15,
                ),
              SizedBox(
                height: 5,
              ),
              _buildIconField(Icons.phone, _phoneController, theme, true),
              if (canEdit)
                const SizedBox(
                  height: 15,
                ),
              SizedBox(
                height: 5,
              ),
              app.isSignedIn
                  ? _buildAgeSlider(context, theme)
                  : _buildIconField(Icons.place, _addressController, theme, false),
              if (canEdit)
                SizedBox(
                  height: 25,
                ),
              if (canEdit)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () {},
                          child: FaIcon(
                            FontAwesomeIcons.save,
                            size: 24,
                            color: theme.textTheme.headlineLarge?.color,
                          )),
                    ],
                  ),
                ),
              if (canEdit)
                SizedBox(
                  height: 10,
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogoutButton(
                    onPressed: () async {
                      log("logging out...");
                      final resp = await Provider.of<AppStore>(context, listen: false).signOut();
                      if (resp == true) {
                        context.go("/auth");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Logged out successfully")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error in logging out.")),
                        );
                      }
                    },
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildPoweredBy(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextWithText(String label, String value, ThemeData theme) {
    return Container(
      // margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: canEdit ? 15 : 14, fontWeight: FontWeight.bold)),
          const SizedBox(
            width: 10,
          ),
          Text(value,
              style: GoogleFonts.inter(
                fontSize: canEdit ? 15 : 14,
              )),
        ],
      ),
    );
  }

  Widget _buildAgeSlider(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Age", style: GoogleFonts.inter(fontSize: canEdit ? 15 : 14, fontWeight: FontWeight.bold)),
        const SizedBox(
          width: 5,
        ),
        SfSlider(
          value: _age,
          min: 15.0,
          max: 95.0,
          stepSize: 1,
          activeColor: const Color(0xFFFF6500),
          inactiveColor: Colors.grey,
          onChanged: canEdit
              ? (dynamic value) {
                  setState(() {
                    _age = value;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildLogoutButton({required void Function() onPressed, required ThemeData theme}) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_outlined,
              color: theme.textTheme.headlineLarge?.color,
              size: 21,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Logout",
              style: GoogleFonts.poppins(
                  fontSize: 18, color: theme.textTheme.headlineLarge?.color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoweredBy(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Powered by",
              style: theme.textTheme.bodySmall!
                  .copyWith(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset("assets/images/logo.png", height: 40, width: 40),
              const SizedBox(width: 10),
              Text(
                "Abblor",
                style: theme.textTheme.headlineLarge!
                    .copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ThemeData theme) {
    return Container(
      // margin: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label on the left
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: canEdit ? 15 : 14, // Smaller font size when canEdit is false
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10), // Space between label and text field
          // Form Field on the right
          Expanded(
            child: TextFormField(
              enabled: canEdit,
              controller: controller,
              style: GoogleFonts.inter(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: canEdit ? 15 : 14, // Smaller font size when canEdit is false
              ),
              decoration: InputDecoration(
                // suffixIcon: canEdit
                //     ? Padding(
                //         padding: const EdgeInsets.only(top: 12.0),
                //         child: isVerified
                //             ? const FaIcon(
                //                 FontAwesomeIcons.circleCheck,
                //                 color: Colors.green,
                //                 size: 20,
                //               )
                //             : const FaIcon(
                //                 FontAwesomeIcons.xmark,
                //                 color: Colors.red,
                //                 size: 20,
                //               ),
                //       )
                //     : null,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                hintText: null, // Remove hintText since label is outside
                border: canEdit
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400), // Border when editable
                      )
                    : InputBorder.none, // No border when not editable
                enabledBorder: canEdit
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400), // Border when enabled
                      )
                    : InputBorder.none,
                focusedBorder: canEdit
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                      )
                    : InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconField(IconData label, TextEditingController controller, ThemeData theme, bool showVerify) {
    return Container(
      // margin: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label on the left
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FaIcon(
                label,
                size: canEdit ? 20 : 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ],
          ),
          const SizedBox(width: 10), // Space between label and text field
          // Form Field on the right
          Expanded(
            child: TextFormField(
              enabled: canEdit,
              controller: controller,
              style: GoogleFonts.inter(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: canEdit ? 15 : 14, // Smaller font size when canEdit is false
              ),
              decoration: InputDecoration(
                suffix: showVerify
                    ? !canEdit
                        ? isVerified
                            ? const FaIcon(
                                FontAwesomeIcons.circleCheck,
                                color: Colors.green,
                                size: 17,
                              )
                            : const FaIcon(
                                FontAwesomeIcons.xmark,
                                color: Colors.red,
                                size: 17,
                              )
                        : null
                    : null,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                hintText: null, // Remove hintText since label is outside
                border: canEdit
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400), // Border when editable
                      )
                    : InputBorder.none, // No border when not editable
                enabledBorder: canEdit
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400), // Border when enabled
                      )
                    : InputBorder.none,
                focusedBorder: canEdit
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                      )
                    : InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
