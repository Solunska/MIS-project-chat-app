import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/models/location.dart';
import 'package:first_app/widgets/chat_detail.dart';
import 'package:first_app/screens/map.dart';
import 'package:first_app/widgets/new_messages.dart';
import 'package:flutter/material.dart';

class ChatMessageScreen extends StatelessWidget {
  const ChatMessageScreen(this.userId, {Key? key}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFf2e9e4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF22223b),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white, 
            ),
          ),
          title: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...');
              }
              if (snapshot.hasError) {
                return const Text('Error');
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text('User not found');
              }
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              var username = userData['username'];
              var userLocation = PlaceLocation(
                latitude: userData['location']['latitude'],
                longitude: userData['location']['longitude'],
                address: userData['location']['address'],
              );
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MapScreen(location: userLocation, isSelecting: false),
                    ),
                  );
                },
                child: Text(
                  '$username',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatDetail(userId),
            ),
            NewMessage(userId),
          ],
        ));
  }
}
