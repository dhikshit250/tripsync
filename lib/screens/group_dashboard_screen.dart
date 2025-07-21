// lib/screens/group_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/models/trip_group.dart';

// Placeholder screens for navigation
class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Itinerary")), body: const Center(child: Text("Itinerary Page")));
}

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Expenses")), body: const Center(child: Text("Expenses Page")));
}

class GroupChatScreen extends StatelessWidget {
  const GroupChatScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Group Chat")), body: const Center(child: Text("Group Chat Page")));
}


class GroupDashboardScreen extends StatelessWidget {
  final TripGroup group;

  const GroupDashboardScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    // Calculate trip duration
    final duration = group.endDate.difference(group.startDate).inDays;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- Group Banner with Name + Cover Image ---
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                group.groupName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              background: Image.asset(
                'assets/images/goa.jpg', // Replace with group.coverImageUrl later
                fit: BoxFit.cover,
              ),
              stretchModes: const [StretchMode.zoomBackground],
            ),
          ),

          // --- Trip Summary Stats ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Trip Summary", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(height: 20),
                      _buildStatRow(Icons.group, "Total Members", "${group.members.length} members"),
                      const SizedBox(height: 12),
                      _buildStatRow(Icons.account_balance_wallet_outlined, "Total Budget", "₹${group.totalBudget.toStringAsFixed(0)}"),
                      const SizedBox(height: 12),
                      _buildStatRow(Icons.calendar_today_outlined, "Trip Duration", "$duration days"),
                      const SizedBox(height: 12),
                      _buildStatRow(Icons.beach_access, "Trip Type", group.tripType),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Quick Action Buttons ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionButton(
                    context,
                    icon: Icons.format_list_bulleted_rounded,
                    label: "Itinerary",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ItineraryScreen()));
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.paid_outlined,
                    label: "Expenses",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: "Chat",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupChatScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- TODO: Add other sections like "Manage Members", "Documents" etc. here ---
        ],
      ),
    );
  }

  // Helper widget for a single stat row
  Widget _buildStatRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // Helper widget for the action buttons
  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: theme.colorScheme.primary.withAlpha(40),
            foregroundColor: theme.colorScheme.primary,
            elevation: 0,
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      ],
    );
  }
}