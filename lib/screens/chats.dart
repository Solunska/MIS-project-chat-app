import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_app/screens/chat_messages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfffcf2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6a040f),
        title: const Text(
          'Conversations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFfffcf2),
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Color(0xFFfffcf2),
            ),
          ),
        ],
      ),
      body: const UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data?.docs ?? [];

        // Filter out the current user
        final filteredUsers =
            users.where((user) => user.id != currentUserUid).toList();

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final userData =
                filteredUsers[index].data() as Map<String, dynamic>;
            final userId = filteredUsers[index].id;

            return UserListItem(
              userId: userId,
              username: userData['username'],
              userImage: userData['image_url'],
            );
          },
        );
      },
    );
  }
}

class UserListItem extends StatelessWidget {
  final String userId;
  final String username;
  final String userImage;

  const UserListItem({
    required this.userId,
    required this.username,
    required this.userImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder(
      stream: CombineLatestStream.list([
        FirebaseFirestore.instance
            .collection('chat')
            .where('recipientId', isEqualTo: userId)
            .where('userId', isEqualTo: currentUserUid)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        FirebaseFirestore.instance
            .collection('chat')
            .where('userId', isEqualTo: userId)
            .where('recipientId', isEqualTo: currentUserUid)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(userImage),
            ),
            title: Text(username),
            subtitle: const Text('Loading...'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMessageScreen(userId),
                ),
              );
            },
          );
        }

        List<DocumentSnapshot> mergedList = [];
        mergedList.addAll(chatSnapshots.data![0].docs);
        mergedList.addAll(chatSnapshots.data![1].docs);

        // Sorting the merged list by 'createdAt' timestamp
        mergedList.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

        if (mergedList.isEmpty) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(userImage),
            ),
            title: Text(
              username,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF403d39),
                  fontSize: 20),
            ),
            subtitle: const Text('No messages'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMessageScreen(userId),
                ),
              );
            },
          );
        }

        final lastMessageData = mergedList.first.data() as Map<String, dynamic>;
        final lastMessage = lastMessageData['message'];
        final createdAt = lastMessageData['createdAt'] != null
            ? (lastMessageData['createdAt'] as Timestamp).toDate()
            : null;

        String subtitleText = lastMessage ?? '';
        if (createdAt != null) {
          final formattedDate = DateFormat.yMMMd().add_jm().format(createdAt);
          subtitleText = '$lastMessage - $formattedDate';
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userImage),
          ),
          title: Text(
            username,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF403d39),
                fontSize: 20),
          ),
          subtitle: Text(subtitleText,
              style: const TextStyle(color: Color.fromARGB(255, 84, 84, 84))),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatMessageScreen(userId),
              ),
            );
          },
        );
      },
    );
  }
}
