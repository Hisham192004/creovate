import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminJobApplicationsScreen extends StatelessWidget {
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');

  Future<void> _updateApplicationStatus(String applicationId, String status) async {
    await applicationsRef.doc(applicationId).update({"status": status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Applications"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: applicationsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No applications found", style: TextStyle(fontSize: 16)));
          }

          final applications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              final applicationId = application.id;
              final applicationData = application.data() as Map<String, dynamic>;
              final jobId = applicationData['jobId'] as String;
              final userId = applicationData['userId'] as String;
              final appliedAt = applicationData['appliedAt'] as Timestamp?;
              final status = applicationData['status'] as String? ?? 'Pending';

              return FutureBuilder<DocumentSnapshot>(
                future: jobsRef.doc(jobId).get(),
                builder: (context, jobSnapshot) {
                  if (jobSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Job not found", style: TextStyle(fontSize: 16)),
                      ),
                    );
                  }

                  final jobData = jobSnapshot.data!.data() as Map<String, dynamic>;
                  final jobTitle = jobData['title'] as String? ?? 'No Title';

                  return FutureBuilder<DocumentSnapshot>(
                    future: usersRef.doc(userId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return Card(
                          margin: EdgeInsets.all(8),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("User not found", style: TextStyle(fontSize: 16)),
                          ),
                        );
                      }

                      final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      final userName = userData['name'] as String? ?? 'No Name';
                      final userEmail = userData['email'] as String? ?? 'No Email';

                      // Check if the buttons should be disabled
                      final bool isAccepted = status == "Accepted";
                      final bool isRejected = status == "Rejected";

                      return Card(
                        margin: EdgeInsets.all(8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Job: $jobTitle",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Applicant: $userName",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Email: $userEmail",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Applied At: ${DateFormat('yyyy-MM-dd – HH:mm').format(appliedAt?.toDate() ?? DateTime.now())}",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "Status: ",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isAccepted
                                          ? Colors.green.withOpacity(0.2)
                                          : isRejected
                                              ? Colors.red.withOpacity(0.2)
                                              : Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isAccepted
                                            ? Colors.green
                                            : isRejected
                                                ? Colors.red
                                                : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: isAccepted || isRejected
                                        ? null // Disable button if status is "Accepted" or "Rejected"
                                        : () => _updateApplicationStatus(applicationId, "Accepted"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: isAccepted || isRejected
                                        ? null // Disable button if status is "Accepted" or "Rejected"
                                        : () => _updateApplicationStatus(applicationId, "Rejected"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Reject",
                                      style: TextStyle(color: Colors.white),
                                    ),
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
              );
            },
          );
        },
      ),
    );
  }
}