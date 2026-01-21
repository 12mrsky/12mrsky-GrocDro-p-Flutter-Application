import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _selectedLatLng = const LatLng(28.6139, 77.2090); // Delhi default
  String _address = "Move map to select location";

  Future<void> _updateAddress(LatLng latLng) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      final place = placemarks.first;
      setState(() {
        _address =
            "${place.street}, ${place.locality}, ${place.administrativeArea} - ${place.postalCode}";
      });
    } catch (_) {
      setState(() => _address = "Unable to fetch address");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Address")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLatLng,
                zoom: 16,
              ),
              onCameraMove: (position) {
                _selectedLatLng = position.target;
              },
              onCameraIdle: () {
                _updateAddress(_selectedLatLng);
              },
              markers: {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: _selectedLatLng,
                ),
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _address,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _address);
                    },
                    child: const Text("Use This Address"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
