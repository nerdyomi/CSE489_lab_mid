import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../widgets/landmark_card.dart';

class RecordsListScreen extends StatelessWidget {
  const RecordsListScreen({super.key});

  // Dummy data for now
  List<Landmark> _getDummyLandmarks() {
    return [
      Landmark(
        id: '1',
        title: 'Dhaka City Hall',
        lat: 23.8103,
        lon: 90.4125,
        imageUrl: 'https://via.placeholder.com/400x200?text=Dhaka+City+Hall',
      ),
      Landmark(
        id: '2',
        title: 'National Mosque',
        lat: 23.7645,
        lon: 90.3572,
        imageUrl: 'https://via.placeholder.com/400x200?text=National+Mosque',
      ),
      Landmark(
        id: '3',
        title: 'Liberation War Museum',
        lat: 23.8103,
        lon: 90.4225,
        imageUrl: 'https://via.placeholder.com/400x200?text=War+Museum',
      ),
      Landmark(
        id: '4',
        title: 'Ahsan Manzil Palace',
        lat: 23.7597,
        lon: 90.2562,
        imageUrl: 'https://via.placeholder.com/400x200?text=Ahsan+Manzil',
      ),
      Landmark(
        id: '5',
        title: 'Lalbagh Fort',
        lat: 23.7598,
        lon: 90.2567,
        imageUrl: 'https://via.placeholder.com/400x200?text=Lalbagh+Fort',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final landmarks = _getDummyLandmarks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
      ),
      body: landmarks.isEmpty
          ? const Center(
              child: Text('No landmarks found'),
            )
          : ListView.builder(
              itemCount: landmarks.length,
              itemBuilder: (context, index) {
                return LandmarkCard(landmark: landmarks[index]);
              },
            ),
    );
  }
}
