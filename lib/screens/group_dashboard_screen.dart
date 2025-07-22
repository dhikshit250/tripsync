// lib/screens/group_dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/models/trip_group.dart';
import 'package:tripsync/screens/chat_screen.dart';
import 'package:tripsync/screens/expenses_screen.dart';
import 'package:tripsync/screens/group_settings_screen.dart';
import 'package:tripsync/screens/placeholder_screen.dart';
import 'package:tripsync/services/image_service.dart'; // <-- NEW IMPORT

class GroupDashboardScreen extends StatefulWidget {
  final TripGroup group;

  const GroupDashboardScreen({super.key, required this.group});

  @override
  State<GroupDashboardScreen> createState() => _GroupDashboardScreenState();
}

class _GroupDashboardScreenState extends State<GroupDashboardScreen> {
  final ImageService _imageService = ImageService();
  String? _bannerImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchBannerImage();
  }

  Future<void> _fetchBannerImage() async {
    // Use the group's location to fetch an image
    final imageUrl = await _imageService.fetchImageForPlace(widget.group.location);
    if (mounted) {
      setState(() {
        _bannerImageUrl = imageUrl;
      });
    }
  }

  Future<void> _removeMember(BuildContext context, String memberUid, String memberName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text('Are you sure you want to remove $memberName from the group?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('groups').doc(widget.group.id).update({
          'members': FieldValue.arrayRemove([memberUid])
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$memberName has been removed.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove member: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildMembersSection(context, theme, screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          widget.group.groupName,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // --- UPDATED BACKGROUND IMAGE LOGIC ---
        background: _bannerImageUrl == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Image.network(
          _bannerImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback in case the image fails to load
            return Image.asset('assets/images/goa.jpg', fit: BoxFit.cover);
          },
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
                builder: (context) => GroupSettingsScreen(group: widget.group),
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
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: "Itinerary"))),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.paid_outlined,
          label: "Expenses",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpensesScreen(group: widget.group),
              ),
            );
          },
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.chat_bubble_outline_rounded,
          label: "Chat",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(group: widget.group),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBudgetSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Budget & Expenses",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: 0.45,
                          strokeWidth: 8,
                          backgroundColor: Colors.greenAccent.withOpacity(0.3),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        ),
                      ),
                      Text(
                          "₹${(widget.group.totalBudget * 0.45).toStringAsFixed(0)}\n spent",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Total Budget:\n₹${widget.group.totalBudget.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildLegend(color: Colors.redAccent, text: "Spent"),
                      const SizedBox(height: 6),
                      _buildLegend(
                          color: Colors.greenAccent.withOpacity(0.3),
                          text: "Remaining"),
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

  Widget _buildMembersSection(BuildContext context, ThemeData theme, double screenWidth) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isAdmin = currentUser?.uid == widget.group.adminUid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Members (${widget.group.members.length})",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.group.members.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.group.members.length) {
                return _buildInviteButton(context);
              }

              final memberUid = widget.group.members[index];
              return _buildMemberAvatar(context, memberUid, isAdmin);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAvatar(BuildContext context, String memberUid, bool isAdmin) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(memberUid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(radius: 28),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String displayName = userData['displayName'] ?? '...';
        final bool isCurrentUserAdmin = widget.group.adminUid == currentUser?.uid;
        final bool isThisMemberTheAdmin = widget.group.adminUid == memberUid;

        Widget avatar = Column(
          children: [
            CircleAvatar(
              radius: 28,
              child: isThisMemberTheAdmin
                  ? const Icon(Icons.shield)
                  : const Icon(Icons.person),
            ),
            const SizedBox(height: 4),
            Text(
              displayName.split(' ').first,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: isCurrentUserAdmin && !isThisMemberTheAdmin
              ? GestureDetector(
            onLongPress: () {
              _removeMember(context, memberUid, displayName);
            },
            child: avatar,
          )
              : avatar,
        );
      },
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
          const Text("Invite New Member",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("Copy Invite Code"),
            subtitle: Text(widget.group.inviteCode),
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite code copied to clipboard!')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_page_outlined),
            title: const Text("Invite from Contacts"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onPressed}) {
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