import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ItemAdderScreen(),
    );
  }
}

class ItemAdderScreen extends StatefulWidget {
  @override
  _ItemAdderScreenState createState() => _ItemAdderScreenState();
}

class _ItemAdderScreenState extends State<ItemAdderScreen> {
  List<String> items = [];

  void showAddItemDialog() {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Item Name"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Item name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  addItem(_controller.text.trim());
                  Navigator.pop(context); // Close dialog
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void addItem(String itemName) {
    setState(() {
      items.add(itemName);
    });
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void navigateToDetailScreen(String itemName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(itemName: itemName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Items to Top Left')),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddItemDialog, // Open input dialog
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            tileColor: Colors.blueGrey.withOpacity(0.2),
            onTap: () => navigateToDetailScreen(items[index]), // Open new screen
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteItem(index), // Delete item
            ),
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String itemName;

  DetailScreen({required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(itemName)),
      body: Center(
        child: Text(
          'Welcome to $itemName Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
