import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  ChatScreen({required this.otherUserId, required this.otherUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgInput = TextEditingController();
  final db = FirebaseFirestore.instance;

  // create a unique chat room id from both user ids
  String getChatId(String uid1, String uid2) {
    var ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  void sendMsg() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (msgInput.text.trim().isEmpty) return;

    String chatId = getChatId(auth.user!.uid, widget.otherUserId);
    String text = msgInput.text.trim();
    msgInput.clear();

    await db.collection('chats').doc(chatId).collection('messages').add({
      'text': text,
      'senderId': auth.user!.uid,
      'senderName': auth.name,
      'sentAt': DateTime.now().millisecondsSinceEpoch,
    });

    // update last message in chat doc
    await db.collection('chats').doc(chatId).set({
      'users': [auth.user!.uid, widget.otherUserId],
      'lastMsg': text,
      'lastMsgTime': DateTime.now().millisecondsSinceEpoch,
      'user1Name': auth.name,
      'user2Name': widget.otherUserName,
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    String chatId = getChatId(auth.user!.uid, widget.otherUserId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Color(0xFF9683EC)),
                  ),
                  SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Color(0xFF9683EC),
                    radius: 18,
                    child: Text(
                      widget.otherUserName[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.otherUserName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Divider(height: 1),

            // messages list
            Expanded(
              child: StreamBuilder(
                stream: db
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('sentAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Color(0xFF9683EC)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No messages yet, say hi!', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  var msgs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      var msg = msgs[i].data();
                      bool isMe = msg['senderId'] == auth.user!.uid;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: 250),
                          decoration: BoxDecoration(
                            color: isMe ? Color(0xFF9683EC) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // message input
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgInput,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Color(0xFF9683EC)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendMsg,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF9683EC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}