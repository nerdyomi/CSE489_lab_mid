import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../widgets/landmark_bottom_sheet.dart';

class OverviewMapScreen extends StatefulWidget {
  const OverviewMapScreen({super.key});

  @override
  State<OverviewMapScreen> createState() => _OverviewMapScreenState();
}

class _OverviewMapScreenState extends State<OverviewMapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<Landmark> _landmarks = [];
  bool _isLoading = true;
  String? _error;

  // Bangladesh center coordinates
  static const LatLng _bangladeshCenter = LatLng(23.6850, 90.3563);

  @override
  void initState() {
    super.initState();
    _loadLandmarks();
  }

  Future<void> _loadLandmarks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final landmarks = await ApiService().fetchLandmarks();
      setState(() {
        _landmarks = landmarks;
        _createMarkers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _createMarkers() {
    _markers = _landmarks.map((landmark) {
      return Marker(
        point: LatLng(landmark.lat, landmark.lon),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showLandmarkBottomSheet(landmark),
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }).toList();
  }

  void _showLandmarkBottomSheet(Landmark landmark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => LandmarkBottomSheet(
        landmark: landmark,
        onEdit: () {
          // Refresh landmarks after edit
          _loadLandmarks();
        },
        onDelete: () {
          // Refresh landmarks after delete
          _loadLandmarks();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadLandmarks,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _bangladeshCenter,
          initialZoom: 7.0,
          minZoom: 5.0,
          maxZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.bd_landmarks',
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLandmarks,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
