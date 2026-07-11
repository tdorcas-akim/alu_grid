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
  String workType = 'Remote';
  bool loading = false;
  String msg = '';

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

  List<String> workTypes = ['Remote', 'In-Person', 'Hybrid'];

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
        'workType': workType,
        'startupId': auth.user!.uid,
        'startupName': auth.name,
        'postedAt': DateTime.now().toString(),
        'applicants': [],
      });

      setState(() {
        loading = false;
        msg = 'Job posted successfully!';
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
              Text('Fill in the details below', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 24),

              TextField(
                controller: titleInput,
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  hintText: 'e.g. UI Designer needed',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: descriptionInput,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'What will the intern do?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: locationInput,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. Kigali, Rwanda',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: durationInput,
                decoration: InputDecoration(
                  labelText: 'Duration',
                  hintText: 'e.g. 3 months',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // work type selector
              Text('Work Type', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: workTypes.map((type) {
                  bool active = workType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => workType = type),
                      child: Container(
                        margin: EdgeInsets.only(right: type != 'Hybrid' ? 8 : 0),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? Color(0xFF9683EC) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active ? Color(0xFF9683EC) : Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: active ? Colors.white : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              Text('Role Category', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: msg.contains('success') ? Colors.green : Colors.red,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Post Job', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}