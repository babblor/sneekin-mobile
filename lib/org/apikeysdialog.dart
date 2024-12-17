import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneekin/models/org_app_account.dart';

class ApiKeysDialog extends StatefulWidget {
  OrgAppAccount account;
  ApiKeysDialog({super.key, required this.account});

  @override
  State<ApiKeysDialog> createState() => _ApiKeysDialogState();
}

class _ApiKeysDialogState extends State<ApiKeysDialog> {
  bool _isSecretHidden = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  "API Keys",
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: FaIcon(
                    FontAwesomeIcons.close,
                    size: 18,
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                ),
              ]),
          const SizedBox(height: 16.0),

          // Client ID Field
          Text(
            "Client ID",
            style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: widget.account.clientId,
                    hintStyle: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                  ),
                  style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                // padding: EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                decoration: BoxDecoration(
                    color: theme.textTheme.headlineLarge?.color, borderRadius: BorderRadius.circular(6)),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      // Copy Client ID logic
                      Clipboard.setData(const ClipboardData(text: "your-client-id"));
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Client ID copied to clipboard")),
                      // );
                    },
                    icon: const Icon(Icons.copy, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Client Secret Field

          Text(
            "Client Website",
            style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: widget.account.clientWebsite ?? "no-client-website",
                    hintStyle: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                  ),
                  style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: theme.textTheme.headlineLarge?.color, borderRadius: BorderRadius.circular(6)),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      // Copy Client Secret logic
                      Clipboard.setData(const ClipboardData(text: "your-client-website"));
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Client website copied to clipboard")),
                      // );
                    },
                    icon: const Icon(Icons.copy, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),
          Text(
            "Client Secret",
            style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: _isSecretHidden ? "*******" : widget.account.clientSecret ?? "no-secret-keys",
                    hintStyle: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                  ),
                  style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: () {
                  log("_isSecretHidden: $_isSecretHidden");
                  setState(() {
                    _isSecretHidden = !_isSecretHidden;
                  });
                },
                icon: Icon(
                  _isSecretHidden ? Icons.visibility_off : Icons.visibility,
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: theme.textTheme.headlineLarge?.color, borderRadius: BorderRadius.circular(6)),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      // Copy Client Secret logic
                      Clipboard.setData(const ClipboardData(text: "your-client-secret"));
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Client Secret copied to clipboard")),
                      // );
                    },
                    icon: const Icon(Icons.copy, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          // Warning message
          Row(
            children: [
              Icon(Icons.warning, color: theme.textTheme.headlineLarge?.color, size: 18),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  "Always store your token securely to protect your account.",
                  style: GoogleFonts.inter(color: theme.textTheme.headlineLarge?.color, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
