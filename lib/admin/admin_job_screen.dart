import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creavate/admin/location_selected_on_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart'; // Add this import

class JobManagementScreen extends StatefulWidget {
  @override
  _JobManagementScreenState createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen> {
  final CollectionReference jobsRef =
      FirebaseFirestore.instance.collection('jobs');

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _payController = TextEditingController();
  final TextEditingController _otherBenefitsController =
      TextEditingController();

  String _selectedCategory = "Dance";
  DateTime? _selectedLastDate;
  Position? _currentPosition;
  File? _jobPosterImage;
  bool _isLoading = false; // Track loading state

  final List<String> _categories = [
    "Dance",
    "Painting",
    "Drawing",
    "Photography",
    "Graphic Design",
    "Digital Art",
    "Music",
    "Fashion Design",
    "Interior Design",
    "Film and Video",
    "Video Games Design",
    "Textile Arts"
  ];

  final ImagePicker _picker = ImagePicker();
  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dob1wjjvc',
    apiKey: '615959474599611',
    apiSecret: 'jtw3DhqbBURDSKLERJ9tMMFAhr8',
  );

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

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
    // Check if location permissions are granted
    var status = await Permission.location.status;
    if (!status.isGranted) {
      // Request location permissions
      status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required")),
        );
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  Future<void> _pickJobPosterImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _jobPosterImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    try {
      final response = await cloudinary.upload(
        file: image.path,
        resourceType: CloudinaryResourceType.image,
      );
      return response.secureUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
      return null;
    }
  }

  Future<void> _addJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_jobPosterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload a job poster image")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Upload job poster image to Cloudinary
      final imageUrl = await _uploadImageToCloudinary(_jobPosterImage!);
      if (imageUrl == null) {
        throw Exception("Failed to upload job poster image");
      }

      // Save job details to Firestore
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
        "jobPosterUrl": imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Clear form fields
      _jobTitleController.clear();
      _jobDescriptionController.clear();
      _payController.clear();
      _otherBenefitsController.clear();
      setState(() {
        _selectedLastDate = null;
        _currentPosition = null;
        _jobPosterImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Job Added Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding job: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> _selectLocationFromMap() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          onLocationSelected: (location) {
            setState(() {
              _currentPosition = Position(
                latitude: location.latitude,
                longitude: location.longitude,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                altitudeAccuracy: 0,
                headingAccuracy: 0,
              );
            });
          },
        ),
      ),
    );
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
        title: Text("Job Management",
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [



TextFormField(
                    controller: _jobTitleController,
                    decoration: InputDecoration(
                      labelText: "Job Title",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a job title";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _jobDescriptionController,
                    decoration: InputDecoration(
                      labelText: "Job Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a job description";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: _selectedCategory,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                          value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value.toString();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a category";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _payController,
                    decoration: InputDecoration(
                      labelText: "Pay (₹)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the pay amount";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _otherBenefitsController,
                    decoration: InputDecoration(
                      labelText: "Other Benefits",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter other benefits";
                      }
                      return null;
                    },
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
                      IconButton(
                        icon: Icon(Icons.map, color: Colors.deepPurple),
                        onPressed: _selectLocationFromMap,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickJobPosterImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _jobPosterImage == null
                          ? Center(child: Text("Tap to upload job poster"))
                          : Image.file(_jobPosterImage!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addJob,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Add Job", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Form fields remain the same as before
                  // ...
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(), // Show loading indicator
            ),
        ],
      ),
    );
  }
}













