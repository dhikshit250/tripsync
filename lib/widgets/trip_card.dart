import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripCard extends StatelessWidget {
  final String destination;
  final String dateRange;
  final String imageUrl;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.destination,
    required this.dateRange,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Ink(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    // --- FIX IS HERE ---
                    Colors.black.withAlpha((255 * 0.8).round()),
                  ],
                ),
              ),
            ),
            // Trip Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    destination,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        const Shadow(blurRadius: 2.0, color: Colors.black54)
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        dateRange,
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}