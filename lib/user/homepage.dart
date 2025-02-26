import 'package:creovate/user/user_job_list_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Creovate Home Page',
      theme: ThemeData(primarySwatch: Colors.red),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<String> boxNames = [
    "Dance",
    "Painting",
    "Drawing",
    "Photography",
    "Graphic Design",
    "Digital Art",
    "Music",
    "Fashion Design",
    "Interior Design",
    "Film and Video",
    "Video Games Design",
    "Textile Arts"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Creovate',
          style: TextStyle(
            fontFamily: 'Pacifico', // Stylish font
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 boxes per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: boxNames.length,
          itemBuilder: (context, index) {
            return HomeBox(
              title: boxNames[index],
              onTap: () {
                // Define action for onTap if needed
                Navigator.push(context, MaterialPageRoute(builder: (context) => JobListScreen( selectedCategory:  boxNames[index],),));
              },
            );
          },
        ),
      ),
    );
  }
}

class HomeBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  HomeBox({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto', // Custom font for boxes
            ),
          ),
        ),
      ),
    );
  }
}