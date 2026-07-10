import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'edit_job_screen.dart';

class StartupDashboardScreen extends StatelessWidget {
  void deleteJob(String jobId, BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Job'),
        content: Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
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
                'Welcome, ${auth.name}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9683EC),
                ),
              ),
              SizedBox(height: 4),
              Text('Your posted jobs', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),

              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .where('startupId', isEqualTo: auth.user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Color(0xFF9683EC)),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No jobs posted yet!', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    var jobs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, i) {
                        var job = jobs[i].data();
                        var jobId = jobs[i].id;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF9683EC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF9683EC).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      job['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF9683EC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      job['role'] ?? '',
                                      style: TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                job['description'] ?? '',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(job['location'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  SizedBox(width: 16),
                                  Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(job['duration'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${(job['applicants'] as List).length} applicant(s)',
                                style: TextStyle(color: Color(0xFF9683EC), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 12),

                              // edit and delete buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditJobScreen(jobId: jobId, jobData: job),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.edit, size: 16, color: Color(0xFF9683EC)),
                                      label: Text('Edit', style: TextStyle(color: Color(0xFF9683EC))),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Color(0xFF9683EC)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => deleteJob(jobId, context),
                                      icon: Icon(Icons.delete, size: 16, color: Colors.red),
                                      label: Text('Delete', style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
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