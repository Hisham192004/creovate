import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobMapScreen extends StatefulWidget {
  @override
  _JobMapScreenState createState() => _JobMapScreenState();
}

class _JobMapScreenState extends State<JobMapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('jobs').get();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final double latitude = data['location']['latitude'];
        final double longitude = data['location']['longitude'];
        final String title = data['title'];

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: title,
                snippet: "Job Location",
              ),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching jobs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Locations on Map"),
        backgroundColor: Colors.deepPurple,
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: LatLng(11.2456625, 75.7850164), // Default center (can be adjusted)
          zoom: 10,
        ),
        markers: _markers,
      ),
    );
  }
}