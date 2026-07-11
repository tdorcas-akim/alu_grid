import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: Color(0xFF9683EC)),
              ),
              SizedBox(height: 20),
              Text(
                'New Message',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9683EC)),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (val) => setState(() => searchText = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9683EC)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(color: Color(0xFF9683EC)));
                    }

                    var users = snapshot.data!.docs.where((doc) {
                      var user = doc.data();
                      // don't show yourself
                      if (doc.id == auth.user!.uid) return false;
                      if (searchText.isEmpty) return true;
                      return user['name'].toString().toLowerCase().contains(searchText);
                    }).toList();

                    if (users.isEmpty) {
                      return Center(child: Text('No users found', style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        var user = users[i].data();
                        var userId = users[i].id;

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  otherUserId: userId,
                                  otherUserName: user['name'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Color(0xFF9683EC).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF9683EC).withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(0xFF9683EC),
                                  child: Text(
                                    user['name'][0].toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      user['role'].toString().toUpperCase(),
                                      style: TextStyle(color: Color(0xFF9683EC), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}