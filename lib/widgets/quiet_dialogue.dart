import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool> onWillPop(BuildContext context) async {
  bool shouldExit = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.transparent,
      title: Text(
        "Exit App",
        style: GoogleFonts.poppins(),
      ),
      content: Text(
        "Are you sure you want to quit the app?",
        style: GoogleFonts.poppins(),
      ),
      actions: [
        TextButton(
          onPressed: () => (context).pop(false), // Cancel
          child: Text(
            "No",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: () => exit(1), // Confirm
          child: Text(
            "Yes",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
      ],
    ),
  );

  return shouldExit;
}
