import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../widgets/landmark_card.dart';
import '../screens/landmark_form_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  late Future<List<Landmark>> _landmarksFuture;

  @override
  void initState() {
    super.initState();
    _loadLandmarks();
  }

  void _loadLandmarks() {
    setState(() {
      _landmarksFuture = ApiService().fetchLandmarks();
    });
  }

  Future<void> _deleteLandmark(Landmark landmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Landmark'),
        content: Text('Are you sure you want to delete "${landmark.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ApiService().deleteLandmark(landmark.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${landmark.title} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadLandmarks();
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete landmark: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _editLandmark(Landmark landmark) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandmarkFormScreen(landmark: landmark),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Landmark updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadLandmarks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
      ),
      body: FutureBuilder<List<Landmark>>(
        future: _landmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No landmarks found'),
            );
          }

          final landmarks = snapshot.data!;
          return ListView.builder(
            itemCount: landmarks.length,
            itemBuilder: (context, index) {
              final landmark = landmarks[index];
              return Dismissible(
                key: Key('landmark_${landmark.id}'),
                background: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.edit, color: Colors.white, size: 32),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white, size: 32),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Swipe right - Edit
                    _editLandmark(landmark);
                    return false; // Don't dismiss
                  } else if (direction == DismissDirection.endToStart) {
                    // Swipe left - Delete (show confirmation first)
                    await _deleteLandmark(landmark);
                    return false; // Don't auto-dismiss, refresh happens in _deleteLandmark
                  }
                  return false;
                },
                child: GestureDetector(
                  onTap: () => _editLandmark(landmark),
                  child: LandmarkCard(landmark: landmark),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
