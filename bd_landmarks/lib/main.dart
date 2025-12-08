import 'package:flutter/material.dart';

void main() {
  runApp(const BdLandmarksApp());
}

class BdLandmarksApp extends StatelessWidget {
  const BdLandmarksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BD Landmarks App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const BdLandmarksHome(),
    );
  }
}

class BdLandmarksHome extends StatelessWidget {
  const BdLandmarksHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BD Landmarks'),
      ),
      body: const Center(
        child: Text('BD Landmarks App'),
      ),
    );
  }
}
