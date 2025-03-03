import 'package:creovate/user/user_job_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Creovate Home Page',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<String> boxNames = [
    "DANCE",
    "PAINTING",
    "DRAWING",
    "PHOTOGRAPHY",
    "GRAPHIC DESIGN",
    "DIGITAL ART",
    "MUSIC",
    "FASHION DESIGN",
    "INTERIOR DESIGN",
    "FILM AND VIDEO",
    "VIDEO GAMES DESIGN",
    "TEXTILE ARTS"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'CREOVATE',
          style: GoogleFonts.lobster(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient (All Purple Theme)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade900,
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade500,
                  Colors.deepPurple.shade300,
                ],
              ),
            ),
          ),

          // Grid Layout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2, // Adjusted ratio for better UI
              ),
              itemCount: boxNames.length,
              itemBuilder: (context, index) {
                return HomeBox(
                  title: boxNames[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobListScreen(selectedCategory: boxNames[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade800,
              Colors.purple.shade600,
              Colors.purple.shade400
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.purpleAccent.shade100, width: 2), // Soft Purple Border
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade900.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black45,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
