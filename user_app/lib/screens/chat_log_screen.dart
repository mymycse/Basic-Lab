import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bubble/bubble.dart';

class ChatLogScreen extends StatelessWidget {
  const ChatLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final chatRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chatlog')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('대화 내역', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xCC1ea698),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('대화 내역이 없습니다.'));
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final data = messages[index].data() as Map<String, dynamic>;
              final sender = data['sender'] ?? '알 수 없음';
              final text = data['text'] ?? '';
              final ts = (data['timestamp'] as Timestamp?)?.toDate();

              final isUser = sender == '사용자';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Bubble(
                      nip: isUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
                      color: isUser
                          ? const Color(0xFFD2F5E3)
                          : const Color(0xFFEDEDED),
                      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                      margin: BubbleEdges.only(
                        top: 4,
                        bottom: 4,
                        left: isUser ? 50 : 0,
                        right: isUser ? 0 : 50,
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ts != null
                            ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
                            : '시간 정보 없음',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}