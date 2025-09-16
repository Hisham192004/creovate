import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class UserApplicationsScreen extends StatelessWidget {
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Applications", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Text(
            "Please log in to view applications.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Applications", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        shadowColor: Colors.black54,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: applicationsRef.where("userId", isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No applications found",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            );
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
                      title: Text("Job not found", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      subtitle: Text("Status: ${applicationData['status']}", style: GoogleFonts.poppins()),
                    );
                  }

                  final jobData = jobSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.all(12),
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: Colors.black45,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobData['title'] as String? ?? 'No Title',
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          SizedBox(height: 4),
                          Text(
                            jobData['description'] as String? ?? 'No Description',
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Category: ${jobData['category'] as String? ?? 'N/A'}",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                          ),
                          Text(
                            "Pay: ₹${jobData['pay'] as String? ?? '0'}",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green),
                          ),
                          Text(
                            "Status: ${applicationData['status']}",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: applicationData['status'] == 'Accepted' ? Colors.green : Colors.orange),
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
      ),
    );
  }
}
