import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class JobListingScreen extends StatefulWidget {
  final String category;

  const JobListingScreen({super.key, required this.category});

  @override
  _JobListingScreenState createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<JobListingScreen> with SingleTickerProviderStateMixin {
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  bool _isLoading = true;
  Set<String> _appliedJobIds = {}; // Track applied job IDs

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Fetch applied jobs for the current user
      final querySnapshot = await applicationsRef
          .where("userId", isEqualTo: user.uid)
          .get();

      setState(() {
        _appliedJobIds = Set.from(querySnapshot.docs.map((doc) => doc['jobId'] as String));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _applyForJob(String jobId) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    if (_appliedJobIds.contains(jobId)) {
      print("User has already applied for this job.");
      return;
    }

    final applicationData = {
      "jobId": jobId,
      "userId": user.uid,
      "status": "Pending",
      "appliedAt": FieldValue.serverTimestamp(),
    };

    await applicationsRef.add(applicationData);
    print("Application submitted.");

    // Update the state to reflect the applied job
    setState(() {
      _appliedJobIds.add(jobId);
    });
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      print('Could not launch $googleMapsUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Listings - ${widget.category}"),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Set TabBar text color to white
          unselectedLabelColor: Colors.white.withOpacity(0.7), // Optional: Set unselected tab text color
          tabs: [
            Tab(text: 'Jobs'),
            Tab(text: 'Applied Jobs'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildJobList(),
                _buildAppliedJobsList(),
              ],
            ),
    );
  }

  Widget _buildJobList() {
    return StreamBuilder<QuerySnapshot>(
      stream: jobsRef.where('category', isEqualTo: widget.category).snapshots(),
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

            final double latitude = jobData['location']?['latitude'] as double? ?? 0.0;
            final double longitude = jobData['location']?['longitude'] as double? ?? 0.0;

            String lastDate = jobData['lastDate'] as String? ?? DateTime.now().toString();
            try {
              lastDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(lastDate));
            } catch (e) {
              lastDate = "Invalid Date";
            }

            final bool isApplied = _appliedJobIds.contains(jobId);

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
                          jobData['jobPosterUrl'] as String,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 8),
                    Text(
                      jobData['title'] as String? ?? 'No Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      jobData['description'] as String? ?? 'No Description',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.deepPurple),
                        SizedBox(width: 4),
                        Text(
                          jobData['category'] as String? ?? 'No Category',
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
                          "Pay: ₹${jobData['pay'] as String? ?? '0'}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.card_giftcard, size: 16, color: Colors.deepPurple),
                        SizedBox(width: 4),
                        Text(
                          "Other Benefits: ${jobData['otherBenefits'] as String? ?? 'None'}",
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
                          "Last Date: $lastDate",
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
                          "Location: $latitude, $longitude",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _openMap(latitude, longitude),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Open in Google Maps',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: isApplied ? null : () => _applyForJob(jobId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied ? Colors.grey : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isApplied ? 'Applied' : 'Apply Now',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppliedJobsList() {
    final user = _auth.currentUser;
    if (user == null) {
      return Center(child: Text("User not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: applicationsRef.where('userId', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No applied jobs"));
        }

        final applications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            final applicationData = application.data() as Map<String, dynamic>;
            final jobId = applicationData['jobId'] as String;
            final appliedAt = applicationData['appliedAt'] as Timestamp?;
            final status = applicationData['status'] as String? ?? 'Pending';

            return FutureBuilder<DocumentSnapshot>(
              future: jobsRef.doc(jobId).get(),
              builder: (context, jobSnapshot) {
                if (jobSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
                  return ListTile(
                    title: Text("Job not found"),
                  );
                }

                final jobData = jobSnapshot.data!.data() as Map<String, dynamic>;
                final jobTitle = jobData['title'] as String? ?? 'No Title';
                final jobDescription = jobData['description'] as String? ?? 'No Description';

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
                          jobTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          jobDescription,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
                            SizedBox(width: 4),
                            Text(
                              "Applied At: ${DateFormat('yyyy-MM-dd').format(appliedAt?.toDate() ?? DateTime.now())}",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.info, size: 16, color: Colors.deepPurple),
                            SizedBox(width: 4),
                            Text(
                              "Status: $status",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
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
  }
}