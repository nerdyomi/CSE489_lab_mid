class Landmark {
  final String id;
  final String title;
  final double lat;
  final double lon;
  final String imageUrl;

  Landmark({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.imageUrl,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] as String? ?? '';
    
    // If image is a relative path, prepend the base URL
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://labs.anontech.info/cse489/t3/$imageUrl';
    }
    
    return Landmark(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? 'Unknown',
      lat: (json['lat'] is String 
          ? double.tryParse(json['lat'] as String) ?? 0.0
          : (json['lat'] as num? ?? 0).toDouble()),
      lon: (json['lon'] is String 
          ? double.tryParse(json['lon'] as String) ?? 0.0
          : (json['lon'] as num? ?? 0).toDouble()),
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'imageUrl': imageUrl,
    };
  }
}
