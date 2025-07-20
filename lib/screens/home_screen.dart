import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/screens/profile_screen.dart';
import 'package:tripsync/widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy data for trips - replace this with your Firestore stream later
  final List<Map<String, String>> _trips = [
    {
      "destination": "Manali",
      "dateRange": "Aug 15 - Aug 20, 2025",
      "imageUrl": "assets/images/manali.jpg", // Add this image to your assets
    },
    {
      "destination": "Goa",
      "dateRange": "Sep 10 - Sep 13, 2025",
      "imageUrl": "assets/images/goa.jpg", // Add this image to your assets
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Trips',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return TripCard(
            destination: trip['destination']!,
            dateRange: trip['dateRange']!,
            imageUrl: trip['imageUrl']!,
            onTap: () {
              // TODO: Navigate to Trip Details Screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Tapped on ${trip['destination']}")),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Trip Screen
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        tooltip: 'Create New Trip',
        child: const Icon(Icons.add),
      ),
    );
  }
}