import 'package:flutter/material.dart';
import '../models/landmark.dart';

class LandmarkCard extends StatelessWidget {
  final Landmark landmark;

  const LandmarkCard({
    super.key,
    required this.landmark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.grey[300],
            child: _buildImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  landmark.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Lat: ${landmark.lat.toStringAsFixed(4)}, Lon: ${landmark.lon.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (landmark.imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    return Image.network(
      landmark.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported,
              size: 48, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text('No Image',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

