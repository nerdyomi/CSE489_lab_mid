import 'package:flutter/material.dart';

class RecordsListScreen extends StatelessWidget {
  const RecordsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
      ),
      body: const Center(
        child: Text('Landmark Records - Coming Soon'),
      ),
    );
  }
}
