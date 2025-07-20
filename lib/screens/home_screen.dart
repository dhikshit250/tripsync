import 'package:flutter/material.dart';
import 'package:tripsync/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text("Groups")),
    Center(child: Text("Recent Activity")),
    Container(), // Placeholder for FAB (Add Trip)
    Center(child: Text("Invitations")),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Add Trip Button Pressed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create New Trip")),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex > 2 ? _selectedIndex : _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
            BottomNavigationBarItem(icon: Icon(null), label: ''), // FAB gap
            BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Invites'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
