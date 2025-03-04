import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobListingScreen extends StatelessWidget {
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _applyForJob(String jobId) async {
    final userId = _auth.currentUser!.uid;
    final applicationData = {
      "jobId": jobId,
      "userId": userId,
      "status": "Pending",
      "appliedAt": FieldValue.serverTimestamp(),
    };

    await applicationsRef.add(applicationData);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the category passed from the previous screen
    final String category = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("Job Listings - $category"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobsRef.where('category', isEqualTo: category).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No jobs available in this category"));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final jobId = job.id;
              final jobData = job.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobData['title'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(jobData['description']),
                      SizedBox(height: 8),
                      Text("Category: ${jobData['category']}"),
                      SizedBox(height: 8),
                      Text("Pay: ₹${jobData['pay']}"),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _applyForJob(jobId),
                        child: Text("Apply"),
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