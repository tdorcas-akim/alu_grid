import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

class PostJobScreen extends StatefulWidget {
  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final titleInput = TextEditingController();
  final descriptionInput = TextEditingController();
  final locationInput = TextEditingController();
  final durationInput = TextEditingController();
  String selectedRole = 'Design';
  bool loading = false;
  String msg = '';

  // job categories/roles
  List<String> roles = [
    'Design',
    'Software Development',
    'Marketing',
    'Business Analysis',
    'Content Creation',
    'Operations',
    'Research',
    'Community Management',
  ];

  void postJob() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (titleInput.text.isEmpty || descriptionInput.text.isEmpty) {
      setState(() => msg = 'Please fill in all fields');
      return;
    }

    setState(() {
      loading = true;
      msg = '';
    });

    try {
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': titleInput.text.trim(),
        'description': descriptionInput.text.trim(),
        'location': locationInput.text.trim(),
        'duration': durationInput.text.trim(),
        'role': selectedRole,
        'startupId': auth.user!.uid,
        'startupName': auth.name,
        'postedAt': DateTime.now().toString(),
        'applicants': [],
      });

      setState(() {
        loading = false;
        msg = 'Job posted successfully!';
        // clear fields
        titleInput.clear();
        descriptionInput.clear();
        locationInput.clear();
        durationInput.clear();
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post a Job',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9683EC),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Fill in the details below',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),

              // job title
              TextField(
                controller: titleInput,
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  hintText: 'e.g. UI Designer needed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // description
              TextField(
                controller: descriptionInput,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'What will the intern do?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // location
              TextField(
                controller: locationInput,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. Remote, ALU Campus',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // duration
              TextField(
                controller: durationInput,
                decoration: InputDecoration(
                  labelText: 'Duration',
                  hintText: 'e.g. 3 months',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // role dropdown
              Text(
                'Role Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
                items: roles.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (val) => setState(() => selectedRole = val!),
              ),
              SizedBox(height: 8),

              if (msg.isNotEmpty)
                Text(
                  msg,
                  style: TextStyle(
                    color: msg.contains('success')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : postJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9683EC),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Post Job',
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