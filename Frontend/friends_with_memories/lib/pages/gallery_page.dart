// lib/pages/gallery_page.dart
import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 oszlop a képeknek
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 9, // Példa 9 képre, módosítható a szükségletek szerint
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[300], // Példa kép helykitöltő
            child: const Icon(Icons.image, size: 50),
          );
        },
      ),
    );
  }
}
