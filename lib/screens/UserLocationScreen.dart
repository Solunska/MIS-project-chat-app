import 'package:flutter/material.dart';

class UserLocationScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String address;

  const UserLocationScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    // Construct the URL for the static map image
    final mapImageUrl =
        'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:A%7C$latitude,$longitude&key=AIzaSyAJA43M1Z_M9cLERLk7_f5H6KmbZ9uuK-A';
  
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                mapImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Navigate back to the chat screen
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
