import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JobListScreen extends StatelessWidget {
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');

  Future<void> _deleteJob(String jobId) async {
    try {
      await jobsRef.doc(jobId).delete();
    } catch (e) {
      print("Error deleting job: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job List"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No jobs found"));
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (jobData['jobPosterUrl'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            jobData['jobPosterUrl'],
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 8),
                      Text(
                        jobData['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        jobData['description'],
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 4),
                          Text(
                            jobData['category'],
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 4),
                          Text(
                            "Pay: ₹${jobData['pay']}",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 4),
                          Text(
                            "Last Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(jobData['lastDate']))}",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 4),
                          Text(
                            "Location: ${jobData['location']['latitude']}, ${jobData['location']['longitude']}",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteJob(jobId),
                        ),
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