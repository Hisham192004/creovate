import 'package:creovate/admin/admin_job_screen.dart';
import 'package:creovate/admin/admin_users_list_screen.dart';
import 'package:creovate/user/homepage.dart';
import 'package:flutter/material.dart';

class AdminRootScreen extends StatefulWidget {
  @override
  _AdminRootScreenState createState() => _AdminRootScreenState();
}

class _AdminRootScreenState extends State<AdminRootScreen> {
  int _selectedIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = [
    HomeScreen(),
    UserListScreen(),
    FeedbackScreen(),
    ComplaintScreen(),
    JobManagementScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "Feedback"),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: "Complaints"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
        ],
      ),
    );
  }
}

// Placeholder Screens - Replace with actual screens

class UserViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("User View Screen"));
  }
}

class FeedbackScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Feedback Screen"));
  }
}

class ComplaintScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Complaint Screen"));
  }
}

class JobScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Job Screen"));
  }
}
