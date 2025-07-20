import 'package:flutter/material.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy group data
    final groups = [
      {'name': 'Goa Trip', 'members': 4},
      {'name': 'Manali Backpack', 'members': 6},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Groups"),
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];

          // Explicitly cast the map values to their correct types
          final groupName = group['name'] as String;
          final memberCount = group['members'] as int;

          return ListTile(
            leading: const Icon(Icons.group_work_rounded),
            title: Text(groupName),
            subtitle: Text('$memberCount members'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to group details screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to group creation screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}