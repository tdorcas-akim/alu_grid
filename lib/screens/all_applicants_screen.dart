import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class AllApplicantsScreen extends StatelessWidget {
  void updateStatus(String appId, String status) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(appId)
        .update({'status': status});
  }

  void openLink(String url) async {
    if (url.isEmpty) return;
    if (!url.startsWith('http')) url = 'https://$url';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
              Text(
                'All Applicants',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9683EC),
                ),
              ),
              SizedBox(height: 20),

              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('applications')
                      .where('startupId', isEqualTo: auth.user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Color(0xFF9683EC)));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No applicants yet!', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    var apps = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: apps.length,
                      itemBuilder: (context, i) {
                        var app = apps[i].data();
                        var appId = apps[i].id;
                        String portfolioLink = app['portfolioLink'] ?? '';

                        Color statusColor = app['status'] == 'accepted'
                            ? Colors.green
                            : app['status'] == 'not selected'
                                ? Colors.red
                                : Colors.orange;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF9683EC).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF9683EC).withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    app['studentName'] ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      app['status'].toString().toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'For: ${app['jobTitle']}',
                                style: TextStyle(color: Color(0xFF9683EC), fontSize: 13),
                              ),
                              SizedBox(height: 8),
                              Text('Cover Letter:', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(height: 4),
                              Text(
                                app['coverLetter'] ?? '',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // clickable portfolio link
                              if (portfolioLink.isNotEmpty) ...[
                                SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => openLink(portfolioLink),
                                  child: Row(
                                    children: [
                                      Icon(Icons.link, size: 14, color: Color(0xFF9683EC)),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          portfolioLink,
                                          style: TextStyle(
                                            color: Color(0xFF9683EC),
                                            fontSize: 12,
                                            decoration: TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              otherUserId: app['studentId'],
                                              otherUserName: app['studentName'],
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.chat, size: 14, color: Color(0xFF9683EC)),
                                      label: Text('Message', style: TextStyle(color: Color(0xFF9683EC), fontSize: 13)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Color(0xFF9683EC)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  if (app['status'] != 'accepted')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => updateStatus(appId, 'accepted'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Accept', style: TextStyle(color: Colors.white, fontSize: 13)),
                                      ),
                                    ),
                                  SizedBox(width: 6),
                                  if (app['status'] == 'accepted')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => updateStatus(appId, 'pending'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Reconsider', style: TextStyle(color: Colors.white, fontSize: 11)),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => updateStatus(appId, 'not selected'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Not Select', style: TextStyle(color: Colors.white, fontSize: 11)),
                                      ),
                                    ),
                                ],
                              ),
                            ],
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