
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/theme_services.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback onDrawerButtonPressed;

  const CustomAppBar({
    super.key,
    required this.onDrawerButtonPressed,
    // required String title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu, size: 25, color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: onDrawerButtonPressed,
            ),
            const SizedBox(
              width: 2,
            ),
            GestureDetector(
                onTap: () {
                  // log("Reloading");
                  context.go("/root");
                },
                child: Image.asset("assets/icons/launcher_icon.png", height: 40)),
            const SizedBox(
              width: 2,
            ),
            Text(
              "SNEEK",
              style: GoogleFonts.poppins(fontSize: 17, color: Theme.of(context).textTheme.bodyLarge?.color),
            )
          ],
        ),
        IconButton(
          icon:
              Icon(Icons.light_mode_outlined, size: 25, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            context.read<ThemeServices>().toggleTheme();
            // Provider.of<ThemeServices>(context, listen: false).toggleTheme();
          },
        ),
        // Row(
        //   children: [
        //     IconButton(
        //       icon: Icon(Icons.person, size: 30, color: Theme.of(context).textTheme.bodyLarge?.color),
        //       onPressed: onDrawerButtonPressed,
        //     ),
        //     const SizedBox(
        //       width: 15,
        //     ),
        //     IconButton(
        //       icon: Icon(Icons.light_mode_outlined,
        //           size: 30, color: Theme.of(context).textTheme.bodyLarge?.color),
        //       onPressed: () {
        //         context.read<ThemeServices>().toggleTheme();
        //         // Provider.of<ThemeServices>(context, listen: false).toggleTheme();
        //       },
        //     ),
        //   ],
        // )
      ],
    );
  }
}
