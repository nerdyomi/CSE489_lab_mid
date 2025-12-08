import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../widgets/landmark_card.dart';

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
    _landmarksFuture = ApiService().fetchLandmarks();
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
              return LandmarkCard(landmark: landmarks[index]);
            },
          );
        },
      ),
    );
  }
}
