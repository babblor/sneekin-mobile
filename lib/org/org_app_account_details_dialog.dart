import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:toastification/toastification.dart';

import '../models/org_app_account.dart';

class OrgAppAccountDetailsDialog extends StatefulWidget {
  OrgAppAccount account;
  OrgAppAccountDetailsDialog({super.key, required this.account});

  @override
  State<OrgAppAccountDetailsDialog> createState() => _OrgAppAccountDetailsDialogState();
}

class _OrgAppAccountDetailsDialogState extends State<OrgAppAccountDetailsDialog> {
  final bool _isSecretHidden = true;
  bool canEdit = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _clientWebsiteController = TextEditingController();

  File? _logoImage;
  bool hasImagePicked = false;

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _imageFile = File(image.path);
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _logoImage = File(image.path);
        hasImagePicked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _emailController.text = widget.account.email ?? "";
    _mobileController.text = widget.account.mobile ?? "";
    _nameController.text = widget.account.name;
    _clientWebsiteController.text = widget.account.clientWebsite ?? "";
    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor, // Dark blue background

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "App Details",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 24,
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigator.pop(context);
                        setState(() {
                          canEdit = !canEdit;
                        });
                      },
                      child: FaIcon(
                        canEdit ? FontAwesomeIcons.xmark : FontAwesomeIcons.penToSquare,
                        size: 18,
                        color: theme.textTheme.headlineLarge?.color,
                      ),
                    ),
                    // SizedBox(
                    //   width: 20,
                    // ),
                  ],
                )
              ]),
          const SizedBox(height: 12.0),

          Container(
              padding: canEdit ? const EdgeInsets.all(15) : const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(width: 1, color: canEdit ? const Color(0xFFFF6500) : theme.secondaryHeaderColor)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Name",
                        style: GoogleFonts.inter(
                            color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                      ),
                      if (canEdit) const SizedBox(width: 8.0),
                      if (!canEdit)
                        const SizedBox(
                          width: 0,
                        ),
                      Expanded(
                        child: TextField(
                          // readOnly: true,
                          controller: _nameController,
                          enabled: canEdit,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            border: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when editable
                                  )
                                : InputBorder.none, // No border when not editable
                            enabledBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when enabled
                                  )
                                : InputBorder.none,
                            focusedBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                                  )
                                : InputBorder.none,
                            hintText: widget.account.name,
                            hintStyle: GoogleFonts.inter(
                                color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                          ),
                          style: GoogleFonts.inter(
                              color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                        ),
                      ),
                      if (canEdit)
                        const SizedBox(
                          width: 10,
                        ),
                      if (canEdit)
                        InkWell(
                          onTap: () {
                            _pickImage();
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Theme.of(context).textTheme.headlineLarge?.color ?? Colors.grey.shade800,
                            backgroundImage: _logoImage != null ? FileImage(_logoImage!) : null,
                            child: _logoImage != null
                                ? null
                                : FaIcon(
                                    FontAwesomeIcons.camera,
                                    size: 12,
                                    color: hasImagePicked ? Colors.green : Colors.white,
                                  ),
                          ),
                        )
                    ],
                  ),

                  if (canEdit) const SizedBox(height: 16.0),
                  // if (!canEdit)
                  //   SizedBox(
                  //     height: 4,
                  //   ),

                  // Client ID Field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Email",
                        style: GoogleFonts.inter(
                            color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                      ),
                      if (canEdit) const SizedBox(width: 8.0),
                      if (!canEdit)
                        const SizedBox(
                          width: 0,
                        ),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          // readOnly: true,
                          enabled: canEdit,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            border: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when editable
                                  )
                                : InputBorder.none, // No border when not editable
                            enabledBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when enabled
                                  )
                                : InputBorder.none,
                            focusedBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                                  )
                                : InputBorder.none,
                            hintText: widget.account.email ?? "no-email",
                            hintStyle: GoogleFonts.inter(
                                color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                          ),
                          style: GoogleFonts.inter(
                              color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                        ),
                      ),
                    ],
                  ),

                  if (canEdit) const SizedBox(height: 16.0),
                  // if (!canEdit)
                  //   SizedBox(
                  //     height: 4,
                  //   ),

                  // Client Secret Field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Mobile",
                        style: GoogleFonts.inter(
                            color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                      ),
                      if (canEdit) const SizedBox(width: 8.0),
                      if (!canEdit)
                        const SizedBox(
                          width: 0,
                        ),
                      Expanded(
                        child: TextField(
                          controller: _mobileController,
                          // readOnly: true,
                          enabled: canEdit,
                          // obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            border: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when editable
                                  )
                                : InputBorder.none, // No border when not editable
                            enabledBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when enabled
                                  )
                                : InputBorder.none,
                            focusedBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                                  )
                                : InputBorder.none,
                            hintText: widget.account.mobile ?? "N/A",
                            hintStyle: GoogleFonts.inter(
                                color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                          ),
                          style: GoogleFonts.inter(
                              color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                        ),
                      ),
                    ],
                  ),

                  if (canEdit) const SizedBox(height: 16.0),
                  // if (!canEdit)
                  //   SizedBox(
                  //     height: 4,
                  //   ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Client Website",
                        style: GoogleFonts.inter(
                            color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                      ),
                      if (canEdit) const SizedBox(width: 8.0),
                      if (!canEdit)
                        const SizedBox(
                          width: 0,
                        ),
                      Expanded(
                        child: TextField(
                          controller: _clientWebsiteController,
                          // readOnly: true,
                          enabled: canEdit,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            border: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when editable
                                  )
                                : InputBorder.none, // No border when not editable
                            enabledBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400), // Border when enabled
                                  )
                                : InputBorder.none,
                            focusedBorder: canEdit
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                                  )
                                : InputBorder.none,
                            hintText: widget.account.clientWebsite != ""
                                ? widget.account.clientWebsite
                                : "no-client-website",
                            hintStyle: GoogleFonts.inter(
                                color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                          ),
                          style: GoogleFonts.inter(
                              color: theme.textTheme.bodyLarge?.color, fontSize: canEdit ? 14 : 12),
                        ),
                      ),
                    ],
                  ),
                  if (canEdit) const SizedBox(height: 24.0),

                  // Warning message
                  if (canEdit)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon(Icons.warning, color: theme.textTheme.headlineLarge?.color, size: 18),
                        // const SizedBox(width: 8.0),
                        // Expanded(
                        //   child: Text(
                        //     "Always store your token securely to protect your account.",
                        //     style: GoogleFonts.inter(color: theme.textTheme.headlineLarge?.color, fontSize: 12),
                        //   ),
                        // ),
                        Consumer<AuthServices>(builder: (context, auth, _) {
                          return InkWell(
                            onTap: () async {
                              if (_logoImage == null &&
                                  _nameController.text == widget.account.name &&
                                  _emailController.text == widget.account.email &&
                                  _mobileController.text == widget.account.mobile &&
                                  _clientWebsiteController.text == widget.account.clientWebsite) {
                                showToast(message: "Nothing to update", type: ToastificationType.error);
                                return;
                              }
                              final result = await auth.updateOrgAppsAccount(
                                  id: widget.account.id,
                                  name: _nameController.text,
                                  mobile: _mobileController.text,
                                  email: _emailController.text,
                                  clientWebsite: _clientWebsiteController.text,
                                  logo: _logoImage ?? File(""));
                              if (result == true) {
                                showToast(
                                    message: "Org-Apps-Account updated successfully!",
                                    type: ToastificationType.success);
                                context.go("/root");
                              }
                            },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.textTheme.headlineLarge?.color,
                              child: auth.isLoading
                                  ? SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    )
                                  : FaIcon(
                                      FontAwesomeIcons.chevronRight,
                                      color: theme.textTheme.bodyLarge?.color,
                                      size: 12,
                                    ),
                            ),
                          );
                        })
                      ],
                    ),
                ],
              ))
        ],
      ),
    );
  }
}
