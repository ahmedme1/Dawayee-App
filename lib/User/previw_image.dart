import 'package:flutter/material.dart';

class PreviewImageScreen extends StatelessWidget {
  const PreviewImageScreen({super.key, required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Image.network(imageUrl);
  }
}
