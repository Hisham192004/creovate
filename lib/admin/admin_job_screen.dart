import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class JobManagementScreen extends StatefulWidget {
  @override
  _JobManagementScreenState createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen> {
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _payController = TextEditingController();
  final TextEditingController _otherBenefitsController = TextEditingController();

  String _selectedCategory = "Dance";
  DateTime? _selectedLastDate;
  Position? _currentPosition;

  final List<String> _categories = [
    "Dance", "Painting", "Drawing", "Photography", "Graphic Design",
    "Digital Art", "Music", "Fashion Design", "Interior Design",
    "Film and Video", "Video Games Design", "Textile Arts"
  ];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedLastDate = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error getting location: $e")));
    }
  }

  Future<void> _addJob() async {
    if (_jobTitleController.text.isEmpty ||
        _jobDescriptionController.text.isEmpty ||
        _payController.text.isEmpty ||
        _otherBenefitsController.text.isEmpty ||
        _selectedLastDate == null ||
        _currentPosition == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    await jobsRef.add({
      "title": _jobTitleController.text.trim(),
      "description": _jobDescriptionController.text.trim(),
      "category": _selectedCategory,
      "pay": _payController.text.trim(),
      "lastDate": _selectedLastDate!.toIso8601String(),
      "otherBenefits": _otherBenefitsController.text.trim(),
      "location": {
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude
      },
      "createdAt": FieldValue.serverTimestamp(),
    });

    _jobTitleController.clear();
    _jobDescriptionController.clear();
    _payController.clear();
    _otherBenefitsController.clear();
    setState(() {
      _selectedLastDate = null;
      _currentPosition = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Job Added Successfully")));
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Management"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _jobTitleController,
              decoration:
                  InputDecoration(labelText: "Job Title", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _jobDescriptionController,
              decoration: InputDecoration(
                  labelText: "Job Description", border: OutlineInputBorder()),
              maxLines: 2,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedCategory,
              decoration: InputDecoration(border: OutlineInputBorder()),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value.toString();
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _payController,
              decoration:
                  InputDecoration(labelText: "Pay (₹)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _otherBenefitsController,
              decoration: InputDecoration(
                  labelText: "Other Benefits", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedLastDate == null
                        ? "Select Last Date"
                        : "Last Date: ${DateFormat('yyyy-MM-dd').format(_selectedLastDate!)}",
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(_currentPosition == null
                      ? "Fetching location..."
                      : "Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}"),
                ),
                IconButton(
                  icon: Icon(Icons.location_on, color: Colors.deepPurple),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addJob,
              child: Text("Add Job"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
