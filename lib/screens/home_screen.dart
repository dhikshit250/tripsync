// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/models/trip_group.dart';
import 'package:tripsync/screens/create_group_screen.dart';
import 'package:tripsync/screens/group_dashboard_screen.dart'; // Make sure this is imported
import 'package:tripsync/screens/profile_screen.dart';
import 'package:tripsync/widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

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
              return TripCard(
                destination: group.groupName,
                dateRange: '${group.startDate.toLocal().toString().split(' ')[0]} - ${group.endDate.toLocal().toString().split(' ')[0]}',
                imageUrl: "assets/images/goa.jpg", // Replace with dynamic or placeholder image
                onTap: () {
                  // --- FIX IS HERE: REPLACED SNACKBAR WITH NAVIGATOR ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDashboardScreen(group: group),
                    ),
                  );
                  // --- END OF FIX ---
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