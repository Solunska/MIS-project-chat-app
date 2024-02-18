import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/screens/chat_detail.dart';
import 'package:first_app/widgets/new_messages.dart';
import 'package:flutter/material.dart';

class ChatMessageScreen extends StatelessWidget {
  const ChatMessageScreen(this.userId, {Key? key}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...');
              }
              if (snapshot.hasError) {
                return Text('Error');
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Text('User not found');
              }
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              var username = userData['username'];
              return Text('$username');
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
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
