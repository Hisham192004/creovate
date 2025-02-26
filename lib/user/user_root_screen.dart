import 'package:creovate/admin/admin_root_screen.dart';
import 'package:creovate/user/homepage.dart';
import 'package:creovate/user/user_profile_screen.dart';
import 'package:flutter/material.dart';


class UserRootScreen extends StatefulWidget {
  @override
  _UserRootScreenState createState() => _UserRootScreenState();
}

class _UserRootScreenState extends State<UserRootScreen> {
  int _selectedIndex = 0;

  // List of Screens
  final List<Widget> _screens = [
    HomeScreen(),
    Scaffold(),
    Scaffold(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "My Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 30, color: Colors.deepPurple), // Highlight Post Job
            label: "Post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
