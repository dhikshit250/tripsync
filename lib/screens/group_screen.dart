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
      appBar: AppBar(title: const Text("My Groups")),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return ListTile(
            leading: const Icon(Icons.group),
            title: Text(group['name']!),
            subtitle: Text('${group['members']} members'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to group details screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to group creation screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
