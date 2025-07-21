// lib/screens/group_dashboard_screen.dart

import 'package:tripsync/screens/expenses_screen.dart'; // <-- NEW IMPORT
import 'package:tripsync/screens/chat_screen.dart';
import 'package:tripsync/screens/group_settings_screen.dart';
import 'package:tripsync/screens/placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/models/trip_group.dart';

class GroupDashboardScreen extends StatelessWidget {
  final TripGroup group;

  const GroupDashboardScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method is the same)
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, theme),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildBudgetSection(theme),
                  const SizedBox(height: 24),
                  _buildMembersSection(theme, screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (SliverAppBar is the same)
  SliverAppBar _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          group.groupName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Image.asset(
          'assets/images/goa.jpg', // Placeholder
          fit: BoxFit.cover,
        ),
        stretchModes: const [StretchMode.zoomBackground],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupSettingsScreen(group: group),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionButton(
          context,
          icon: Icons.format_list_bulleted_rounded,
          label: "Itinerary",
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: "Itinerary"))),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.paid_outlined,
          label: "Expenses",
          // --- UPDATED NAVIGATION ---
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpensesScreen(group: group),
              ),
            );
          },
          // --- END OF UPDATE ---
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.chat_bubble_outline_rounded,
          label: "Chat",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(group: group),
              ),
            );
          },
        ),
      ],
    );
  }

  // ... (rest of the file remains the same)
  Widget _buildBudgetSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Budget & Expenses", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Placeholder for Pie Chart
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // NOTE: Add a chart package like 'fl_chart' for a real pie chart
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: 0.45, // 45% spent
                          strokeWidth: 8,
                          backgroundColor: Colors.greenAccent.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        ),
                      ),
                      Text("₹${(group.totalBudget * 0.45).toStringAsFixed(0)}\n spent", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Budget:\n₹${group.totalBudget.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildLegend(color: Colors.redAccent, text: "Spent"),
                      const SizedBox(height: 6),
                      _buildLegend(color: Colors.greenAccent.withOpacity(0.3), text: "Remaining"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(ThemeData theme, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Members (${group.members.length})", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: group.members.length + 1, // +1 for the invite button
            itemBuilder: (context, index) {
              if (index == group.members.length) {
                return _buildInviteButton(context);
              }
              // TODO: Fetch member details from Firestore using UID
              return _buildMemberAvatar("User ${index + 1}");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAvatar(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 28,
            child: Icon(Icons.person),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInviteButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => _buildInviteSheet(ctx),
              );
            },
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
          const SizedBox(height: 4),
          const Text("Invite", style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInviteSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Invite New Member", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("Create Invite Link"),
            onTap: () {
              // TODO: Implement link generation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite link copied!')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_page_outlined),
            title: const Text("Invite from Contacts"),
            onTap: () {
              // TODO: Implement contact picker
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}