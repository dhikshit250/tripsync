// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/models/trip_group.dart';
import 'package:tripsync/screens/create_group_screen.dart';
import 'package:tripsync/screens/group_dashboard_screen.dart';
import 'package:tripsync/screens/profile_screen.dart';
import 'package:tripsync/services/image_service.dart'; // <-- NEW IMPORT
import 'package:tripsync/widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final ImageService _imageService = ImageService(); // Create an instance of the service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Trips', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members', arrayContains: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No trips yet!\nTap the '+' to create one.",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final groups = snapshot.data!.docs.map((doc) => TripGroup.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return FutureBuilder<String>(
                future: _imageService.fetchImageForPlace(group.groupName), // Fetch the image
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                    // Show a placeholder while the image loads
                    return const Card(
                      child: SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (imageSnapshot.hasError || !imageSnapshot.hasData) {
                    // Show a placeholder if fetching fails
                    return TripCard(
                      destination: group.groupName,
                      dateRange: '${group.startDate.toLocal().toString().split(' ')[0]} - ${group.endDate.toLocal().toString().split(' ')[0]}',
                      imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1', // Default URL
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDashboardScreen(group: group),
                          ),
                        );
                      },
                    );
                  }

                  // Once the image URL is fetched, build the TripCard
                  return TripCard(
                    destination: group.groupName,
                    dateRange: '${group.startDate.toLocal().toString().split(' ')[0]} - ${group.endDate.toLocal().toString().split(' ')[0]}',
                    imageUrl: imageSnapshot.data!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDashboardScreen(group: group),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        tooltip: 'Create New Group',
        child: const Icon(Icons.add),
      ),
    );
  }
}