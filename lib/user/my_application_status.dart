import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserApplicationsScreen extends StatelessWidget {
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("My Applications")),
        body: Center(child: Text("Please log in to view applications.")),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Applications"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: applicationsRef.where("userId", isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No applications found"));
          }

          final applications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              final applicationData = application.data() as Map<String, dynamic>;
              final jobId = applicationData['jobId'] as String? ?? 'Unknown Job';

              return FutureBuilder<DocumentSnapshot>(
                future: jobsRef.doc(jobId).get(),
                builder: (context, jobSnapshot) {
                  if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
                    return ListTile(
                      title: Text("Job not found"),
                      subtitle: Text("Status: ${applicationData['status']}"),
                    );
                  }

                  final jobData = jobSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.all(8),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobData['title'] as String? ?? 'No Title',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(jobData['description'] as String? ?? 'No Description'),
                          SizedBox(height: 8),
                          Text("Category: ${jobData['category'] as String? ?? 'N/A'}"),
                          Text("Pay: ₹${jobData['pay'] as String? ?? '0'}"),
                          Text("Status: ${applicationData['status']}"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
