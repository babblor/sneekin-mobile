import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTopBar extends StatefulWidget {
  const CustomTopBar({super.key});

  @override
  State<CustomTopBar> createState() => _CustomTopBarState();
}

class _CustomTopBarState extends State<CustomTopBar> {
  bool isUserSelected = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F293F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'User',
            style: GoogleFonts.inter(
              color: isUserSelected ? Colors.orange : Colors.white.withOpacity(0.9),
              fontWeight: isUserSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          _buildToggleButton(),
          Text(
            'Organization',
            style: GoogleFonts.inter(
              color: !isUserSelected ? Colors.orange : Colors.white.withOpacity(0.9),
              fontWeight: !isUserSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isUserSelected = !isUserSelected;
        });
      },
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: isUserSelected ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
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
}
