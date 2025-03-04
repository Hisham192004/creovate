import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  LocationPickerScreen({required this.onLocationSelected});

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_selectedLocation != null) {
                widget.onLocationSelected(_selectedLocation!);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(11.261616399717091, 75.77888282531606), // Default initial location
          zoom: 10,
        ),
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: _selectedLocation == null
            ? {}
            : {
                Marker(
                  markerId: MarkerId("selected_location"),
                  position: _selectedLocation!,
                ),
              },
      ),
    );
  }
}