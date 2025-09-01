import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandingPage extends StatelessWidget {
  const BrandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: Text(
              "Order to Smile",
              style: GoogleFonts.leagueSpartan(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [const Shadow(blurRadius: 10, color: Colors.black54)]
              ),
            ),
          ),
        ],
      ),
    );
  }
}
