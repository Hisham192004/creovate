import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminJobApplicationsScreen extends StatelessWidget {
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');

  Future<void> _updateApplicationStatus(String applicationId, String status) async {
    await applicationsRef.doc(applicationId).update({"status": status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Applications"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: applicationsRef.snapshots(),
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
              final applicationId = application.id;
              final applicationData = application.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Job ID: ${applicationData['jobId']}"),
                      SizedBox(height: 8),
                      Text("User ID: ${applicationData['userId']}"),
                      SizedBox(height: 8),
                      Text("Status: ${applicationData['status']}"),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _updateApplicationStatus(applicationId, "Accepted"),
                            child: Text("Accept"),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _updateApplicationStatus(applicationId, "Rejected"),
                            child: Text("Reject"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}