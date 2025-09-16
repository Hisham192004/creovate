import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FeedbackListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Feedback", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('feedbacks').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feedback_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No feedback available", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          
          var feedbackList = snapshot.data!.docs;
          
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              var feedback = feedbackList[index];
              var data = feedback.data() as Map<String, dynamic>;
              
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                shadowColor: Colors.black.withOpacity(0.3),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(data['feedback'] ?? "No feedback", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text("${data['rating']?.toString() ?? 'N/A'}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text("User ID: ${data['userId'] ?? 'Anonymous'}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        "Date: ${data['timestamp'] != null ? DateFormat('yyyy-MM-dd HH:mm').format((data['timestamp'] as Timestamp).toDate()) : 'N/A'}",
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