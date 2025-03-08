import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = false;

  Future<void> _applyForJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to apply for jobs")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    String userId = user.uid;
    String jobId = widget.job['id'] ?? ''; // Ensure jobId is not null

    if (jobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Job ID is missing!")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final applicationsRef = FirebaseFirestore.instance.collection('jobApplications');

    try {
      print("Applying for Job ID: $jobId");

      // Check if the user has already applied
      var existingApplication = await applicationsRef
          .where('userId', isEqualTo: userId)
          .where('jobId', isEqualTo: jobId)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You have already applied for this job")),
        );
      } else {
        // Apply for the job
        await applicationsRef.add({
          'userId': userId,
          'userEmail': user.email ?? "No Email",
          'jobId': jobId,
          'jobTitle': widget.job['title'] ?? 'No Title',
          'category': widget.job['category'] ?? 'No Category',
          'appliedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Application submitted successfully!")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error applying for job: ${error.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle null safety for job details
    String title = widget.job['title'] ?? 'No Title';
    String category = widget.job['category'] ?? 'No Category';
    String description = widget.job['description'] ?? 'No Description';
    String pay = widget.job['pay']?.toString() ?? '0';
    String otherBenefits = widget.job['otherBenefits'] ?? 'None';
    String jobId = widget.job['id'] ?? 'No ID';

    // Handle last date with error prevention
    String lastDate = widget.job['lastDate'] ?? '';
    String formattedLastDate = "N/A"; // Default if date is missing

    if (lastDate.isNotEmpty) {
      try {
        formattedLastDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(lastDate));
      } catch (e) {
        formattedLastDate = "Invalid Date"; // Handle parsing errors
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.category, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Divider(height: 25, thickness: 1),
                Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(description, style: TextStyle(fontSize: 16, color: Colors.black87)),
                SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      "Pay: ₹$pay",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Benefits: $otherBenefits",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Last Date: $formattedLastDate",
                      style: TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Apply button with loading indicator
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.deepPurple)
                      : ElevatedButton(
                          onPressed: _applyForJob,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            "Apply Now",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
