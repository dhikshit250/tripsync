// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tripsync/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // A FutureBuilder is used to fetch data from Firestore
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data?.data() == null) {
          // Handle cases where user data might not be in Firestore
          return Scaffold(appBar: AppBar(title: const Text('Profile')), body: const Center(child: Text('Could not load user data.')));
        }

        // Extract user data from the Firestore document
        final userData = snapshot.data!.data()!;
        final String displayName = userData['displayName'] ?? 'Anonymous Traveler';
        final int? age = userData['age'];
        final String? gender = userData['gender'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No email provided',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                const Divider(),

                // Display new user details
                ListTile(
                  leading: const Icon(Icons.cake_outlined),
                  title: const Text('Age'),
                  trailing: Text(age?.toString() ?? 'Not set', style: const TextStyle(fontSize: 16)),
                ),
                ListTile(
                  leading: const Icon(Icons.wc_outlined),
                  title: const Text('Gender'),
                  trailing: Text(gender ?? 'Not set', style: const TextStyle(fontSize: 16)),
                ),

                const Divider(),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await GoogleSignIn().signOut();
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}