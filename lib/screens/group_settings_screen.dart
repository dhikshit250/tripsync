// lib/screens/group_settings_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/models/trip_group.dart';
import 'package:tripsync/screens/home_screen.dart';

class GroupSettingsScreen extends StatefulWidget {
  final TripGroup group;

  const GroupSettingsScreen({super.key, required this.group});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late TextEditingController _groupNameController;
  late TextEditingController _budgetController;
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.group.groupName);
    _budgetController =
        TextEditingController(text: widget.group.totalBudget.toStringAsFixed(0));
  }

  // --- NEW METHOD TO SAVE CHANGES ---
  Future<void> _saveChanges() async {
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    try {
      final newGroupName = _groupNameController.text.trim();
      final newBudget = double.tryParse(_budgetController.text.trim()) ?? 0.0;

      await FirebaseFirestore.instance.collection('groups').doc(widget.group.id).update({
        'groupName': newGroupName,
        'totalBudget': newBudget,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes saved!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save changes: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _leaveGroup() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Leave')),
        ],
      ),
    );

    if (confirm == true && currentUser != null) {
      try {
        // If the admin is leaving, they must assign a new admin
        if (widget.group.adminUid == currentUser!.uid && widget.group.members.length > 1) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please transfer ownership before leaving the group.'),
            backgroundColor: Colors.orange,
          ));
          return;
        }

        await FirebaseFirestore.instance.collection('groups').doc(widget.group.id).update({
          'members': FieldValue.arrayRemove([currentUser!.uid])
        });

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to leave group: $e')));
      }
    }
  }

  Future<void> _deleteGroup() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('This will permanently delete the group, including all expenses and messages. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final groupRef = FirebaseFirestore.instance.collection('groups').doc(widget.group.id);

        final expenses = await groupRef.collection('expenses').get();
        final messages = await groupRef.collection('messages').get();

        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var doc in expenses.docs) {
          batch.delete(doc.reference);
        }
        for (var doc in messages.docs) {
          batch.delete(doc.reference);
        }
        batch.delete(groupRef);

        await batch.commit();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete group: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUserAdmin = currentUser?.uid == widget.group.adminUid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Group Settings", style: GoogleFonts.poppins()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("Trip Details"),
            const SizedBox(height: 16),
            TextFormField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: "Group Name"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Budget (₹)"),
            ),
            const SizedBox(height: 24),
            // --- UPDATED BUTTON ---
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _saveChanges, // Use the new method
              child: const Text("Save Changes"),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("Danger Zone"),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _leaveGroup,
              icon: const Icon(Icons.exit_to_app),
              label: const Text("Leave Group"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
            const SizedBox(height: 12),
            if (isUserAdmin)
              OutlinedButton.icon(
                onPressed: _deleteGroup,
                icon: const Icon(Icons.delete_forever),
                label: const Text("Delete Group"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary),
    );
  }
}