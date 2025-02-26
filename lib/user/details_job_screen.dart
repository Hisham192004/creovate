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
    String jobId = widget.job['id']; // Ensure each job has an 'id' field in Firestore

    final applicationsRef = FirebaseFirestore.instance.collection('jobApplications');

    try {
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
          'userEmail': user.email,
          'jobId': jobId,
          'jobTitle': widget.job['title'],
          'category': widget.job['category'],
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job['title']),
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
                  widget.job['title'],
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.category, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      widget.job['category'],
                      style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Divider(height: 25, thickness: 1),
                Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(widget.job['description'], style: TextStyle(fontSize: 16, color: Colors.black87)),
                SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      "Pay: ₹${widget.job['pay']}",
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
                      "Benefits: ${widget.job['otherBenefits']}",
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
                      "Last Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.job['lastDate']))}",
                      style: TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Show loading indicator while applying
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
