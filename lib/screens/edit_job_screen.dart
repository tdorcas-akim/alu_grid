import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditJobScreen extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  EditJobScreen({required this.jobId, required this.jobData});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late TextEditingController titleInput;
  late TextEditingController descriptionInput;
  late TextEditingController locationInput;
  late TextEditingController durationInput;
  late String selectedRole;
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

  @override
  void initState() {
    super.initState();
    // prefill with existing job data
    titleInput = TextEditingController(text: widget.jobData['title']);
    descriptionInput = TextEditingController(text: widget.jobData['description']);
    locationInput = TextEditingController(text: widget.jobData['location']);
    durationInput = TextEditingController(text: widget.jobData['duration']);
    selectedRole = widget.jobData['role'] ?? 'Design';
  }

  void saveChanges() async {
    if (titleInput.text.isEmpty || descriptionInput.text.isEmpty) {
      setState(() => msg = 'Please fill in all fields');
      return;
    }

    setState(() {
      loading = true;
      msg = '';
    });

    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({
        'title': titleInput.text.trim(),
        'description': descriptionInput.text.trim(),
        'location': locationInput.text.trim(),
        'duration': durationInput.text.trim(),
        'role': selectedRole,
      });

      setState(() {
        loading = false;
        msg = 'Job updated successfully!';
      });

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        loading = false;
        msg = 'Something went wrong';
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: Color(0xFF9683EC)),
              ),
              SizedBox(height: 20),
              Text(
                'Edit Job',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9683EC),
                ),
              ),
              SizedBox(height: 24),

              TextField(
                controller: titleInput,
                decoration: InputDecoration(
                  labelText: 'Job Title',
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
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
                  onPressed: loading ? null : saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9683EC),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}