import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'details_job_screen.dart'; // Import Job Detail Screen

class JobListScreen extends StatefulWidget {
  final String selectedCategory;

  const JobListScreen({super.key, required this.selectedCategory  });

  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Listings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No jobs available"));
                }

                var jobs = snapshot.data!.docs;

                // Filter jobs based on selected category and date
                List<QueryDocumentSnapshot> filteredJobs = jobs.where((job) {
                  var data = job.data() as Map<String, dynamic>;

                  // Convert lastDate string to DateTime
                  DateTime lastDate = DateTime.parse(data['lastDate']);

                  // Check if job is still valid
                  bool isValid = lastDate.isAfter(DateTime.now());

                  // Apply category filter
                  bool matchesCategory =
                      widget.selectedCategory == "All" || data['category'] == widget.selectedCategory;

                  return isValid && matchesCategory;
                }).toList();

                if (filteredJobs.isEmpty) {
                  return Center(child: Text("No jobs found for selected category"));
                }

                return ListView.builder(
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    var job = filteredJobs[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(job['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Category: ${job['category']}"),
                            Text("Pay: ₹${job['pay']}"),
                            Text("Last Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(job['lastDate']))}"),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward, color: Colors.deepPurple),
                        onTap: () {
                          // Navigate to Job Detail Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailScreen(job: job),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
