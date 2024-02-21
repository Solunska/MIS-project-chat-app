import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/widgets/message_bubble.dart';
import 'package:rxdart/rxdart.dart';

class ChatDetail extends StatelessWidget {
  const ChatDetail(this.userId, {super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    final user = authenticatedUser.uid;

    return StreamBuilder(
      stream: CombineLatestStream.list([
        FirebaseFirestore.instance
            .collection('chat')
            .where('recipientId', isEqualTo: user)
            .where('userId', isEqualTo: userId)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        FirebaseFirestore.instance
            .collection('chat')
            .where('userId', isEqualTo: user)
            .where('recipientId', isEqualTo: userId)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
      ]),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.length < 2) {
          return const Center(
            child: Text('No messages.'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        // Merging snapshots from two queries into a single list
        List<DocumentSnapshot> mergedList = [];
        mergedList.addAll(chatSnapshots.data![0].docs);
        mergedList.addAll(chatSnapshots.data![1].docs);

        // Sorting the merged list by 'createdAt' timestamp
        mergedList.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: mergedList.length,
          itemBuilder: (ctx, index) {
            final Map<String, dynamic>? chatMessage =
                (mergedList[index].data() as Map<String, dynamic>?);

            final Map<String, dynamic>? nextChatMessage =
                index + 1 < mergedList.length
                    ? (mergedList[index + 1].data() as Map<String, dynamic>?)
                    : null;
            final currentMessageUserId = chatMessage?['userId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage?['message'] ?? '',
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage?['userImage'] ?? '',
                username: chatMessage?['username'] ?? '',
                message: chatMessage?['message'] ?? '',
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
