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
    'VISUAL ARTS', 'PERFORMING ARTS', 'LITERARY ARTS', 'APPLIED ARTS',
    'MEDIA ARTS', 'CRAFTS', 'EXPERIMENTAL & MIXED MEDIA', 'OTHER EMERGING FIELDS'
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListPage(title: boxNames[index]),
                  ),
                );
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
          color: Colors.blueGrey,
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

class ListPage extends StatelessWidget {
  final String title;

  ListPage({required this.title});

  final List<String> items = [
    'Item 1', 'Item 2', 'Item 3', 'Item 4'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title - Items')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              items[index],
              style: TextStyle(fontSize: 18),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(item: items[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String item;

  DetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$item Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://via.placeholder.com/300'), // Placeholder image
            SizedBox(height: 20),
            Text(
              'Details for $item',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
