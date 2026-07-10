import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  JobDetailScreen({required this.jobId, required this.jobData});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final coverLetterInput = TextEditingController();
  bool loading = false;
  bool applied = false;
  String msg = '';

  @override
  void initState() {
    super.initState();
    checkIfApplied();
  }

  void checkIfApplied() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    var applicants = widget.jobData['applicants'] as List;
    if (applicants.contains(auth.user!.uid)) {
      setState(() => applied = true);
    }
  }

  void applyForJob() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (coverLetterInput.text.isEmpty) {
      setState(() => msg = 'Please write a short cover letter');
      return;
    }

    setState(() {
      loading = true;
      msg = '';
    });

    try {
      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': widget.jobId,
        'jobTitle': widget.jobData['title'],
        'startupId': widget.jobData['startupId'],
        'startupName': widget.jobData['startupName'],
        'studentId': auth.user!.uid,
        'studentName': auth.name,
        'coverLetter': coverLetterInput.text.trim(),
        'status': 'pending',
        'appliedAt': DateTime.now().toString(),
      });

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({
        'applicants': FieldValue.arrayUnion([auth.user!.uid]),
      });

      setState(() {
        loading = false;
        applied = true;
        msg = 'Application sent successfully!';
      });

    } catch (e) {
      setState(() {
        loading = false;
        msg = 'Something went wrong, try again';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    var job = widget.jobData;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: Color(0xFF9683EC)),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job['title'] ?? '',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF9683EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job['role'] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // startup name + message button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job['startupName'] ?? '',
                    style: TextStyle(color: Color(0xFF9683EC), fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: job['startupId'],
                            otherUserName: job['startupName'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF9683EC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF9683EC)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.chat, size: 14, color: Color(0xFF9683EC)),
                          SizedBox(width: 4),
                          Text(
                            'Message',
                            style: TextStyle(color: Color(0xFF9683EC), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(job['location'] ?? '', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(job['duration'] ?? '', style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 20),

              Text('About this role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text(job['description'] ?? '', style: TextStyle(fontSize: 14, height: 1.5)),
              SizedBox(height: 24),

              if (!applied) ...[
                Text('Cover Letter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                TextField(
                  controller: coverLetterInput,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tell them why you are a good fit...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF9683EC)),
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],

              if (msg.isNotEmpty)
                Text(
                  msg,
                  style: TextStyle(
                    color: msg.contains('success') ? Colors.green : Colors.red,
                  ),
                ),

              SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: applied || loading ? null : applyForJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: applied ? Colors.grey : Color(0xFF9683EC),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          applied ? 'Already Applied ✓' : 'Apply Now',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}