import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ComplaintListPage extends StatefulWidget {
  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('complaints').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_problem, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No complaints found", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var complaint = snapshot.data!.docs[index];
              var data = complaint.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                shadowColor: Colors.black.withOpacity(0.3),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.warning, color: Colors.white),
                  ),
                  title: Text(data['title'] ?? "No Title", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text("Category: ${data['category'] ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 5),
                      Text("Details: ${data['details'] ?? 'No details provided'}", style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 5),
                      Text(
                        "Submitted: ${data['timestamp'] != null ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate()) : 'N/A'}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}