import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'job_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String searchText = '';
  String selectedFilter = 'All';
  List<String> mySkills = [];

  List<String> filters = [
    'All',
    'Design',
    'Software Development',
    'Marketing',
    'Business Analysis',
    'Content Creation',
    'Operations',
    'Research',
    'Community Management',
  ];

  // smart matching — skills that relate to each role
  // even if the exact job title isn't in the skills list
  Map<String, List<String>> roleSkillMap = {
    'Design': [
      'UI/UX Design', 'Graphic Design', 'Figma', 'Canva',
      'HTML/CSS', 'JavaScript', 'React', 'Flutter',
      'Video Editing', 'Creative', 'Visual',
    ],
    'Software Development': [
      'Flutter', 'Python', 'JavaScript', 'React', 'Node.js',
      'HTML/CSS', 'Programming', 'Coding', 'Development',
      'UI/UX Design', 'Figma', 'Data Analysis',
    ],
    'Marketing': [
      'Marketing', 'Social Media', 'Content Writing',
      'Community Management', 'Canva', 'Video Editing',
      'Research', 'Business Analysis',
    ],
    'Business Analysis': [
      'Business Analysis', 'Research', 'Data Analysis',
      'Project Management', 'Operations', 'Excel',
      'Marketing', 'Community Management',
    ],
    'Content Creation': [
      'Content Writing', 'Video Editing', 'Canva',
      'Social Media', 'Marketing', 'Graphic Design',
      'Community Management',
    ],
    'Operations': [
      'Operations', 'Project Management', 'Business Analysis',
      'Research', 'Community Management',
    ],
    'Research': [
      'Research', 'Data Analysis', 'Business Analysis',
      'Content Writing', 'Python',
    ],
    'Community Management': [
      'Community Management', 'Social Media', 'Marketing',
      'Content Writing', 'Operations',
    ],
  };

  @override
  void initState() {
    super.initState();
    loadMySkills();
  }

  void loadMySkills() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.role != 'student') return;

    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.user!.uid)
        .get();

    if (doc.exists) {
      List skills = doc.data()?['skills'] ?? [];
      setState(() {
        mySkills = skills.map((s) => s.toString()).toList();
      });
    }
  }

  bool isMatch(String jobRole) {
    if (mySkills.isEmpty) return false;
    List<String> relatedSkills = roleSkillMap[jobRole] ?? [];
    for (var mySkill in mySkills) {
      // check direct match or partial match
      for (var related in relatedSkills) {
        if (related.toLowerCase().contains(mySkill.toLowerCase()) ||
            mySkill.toLowerCase().contains(related.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Opportunities',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9683EC),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                onChanged: (val) => setState(() => searchText = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search jobs, skills...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9683EC)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 12),

              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (context, i) {
                    bool active = selectedFilter == filters[i];
                    return GestureDetector(
                      onTap: () => setState(() => selectedFilter = filters[i]),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? Color(0xFF9683EC) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? Color(0xFF9683EC) : Colors.grey,
                          ),
                        ),
                        child: Text(
                          filters[i],
                          style: TextStyle(
                            color: active ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),

              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Color(0xFF9683EC)));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No jobs available yet!', style: TextStyle(color: Colors.grey)));
                    }

                    var jobs = snapshot.data!.docs.where((doc) {
                      var job = doc.data();
                      bool matchSearch = searchText.isEmpty ||
                          job['title'].toString().toLowerCase().contains(searchText) ||
                          job['description'].toString().toLowerCase().contains(searchText);
                      bool matchFilter = selectedFilter == 'All' || job['role'] == selectedFilter;
                      return matchSearch && matchFilter;
                    }).toList();

                    // sort matched jobs to the top
                    jobs.sort((a, b) {
                      bool aMatch = isMatch(a.data()['role'] ?? '');
                      bool bMatch = isMatch(b.data()['role'] ?? '');
                      if (aMatch && !bMatch) return -1;
                      if (!aMatch && bMatch) return 1;
                      return 0;
                    });

                    if (jobs.isEmpty) {
                      return Center(child: Text('No jobs match your search', style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, i) {
                        var job = jobs[i].data();
                        var jobId = jobs[i].id;
                        bool matched = isMatch(job['role'] ?? '');

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(jobId: jobId, jobData: job),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: matched
                                  ? Color(0xFF9683EC).withOpacity(0.15)
                                  : Color(0xFF9683EC).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: matched ? Color(0xFF9683EC) : Color(0xFF9683EC).withOpacity(0.2),
                                width: matched ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              job['title'] ?? '',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          if (matched) ...[
                                            SizedBox(width: 6),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF25D366),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '✓ Match',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
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
                                SizedBox(height: 6),
                                Text(
                                  job['startupName'] ?? '',
                                  style: TextStyle(color: Color(0xFF9683EC), fontSize: 13),
                                ),
                                SizedBox(height: 6),
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
                                    SizedBox(width: 12),
                                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(job['duration'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: job['workType'] == 'Remote'
                                            ? Colors.green.withOpacity(0.15)
                                            : job['workType'] == 'Hybrid'
                                                ? Colors.orange.withOpacity(0.15)
                                                : Colors.blue.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        job['workType'] ?? 'Remote',
                                        style: TextStyle(
                                          color: job['workType'] == 'Remote'
                                              ? Colors.green
                                              : job['workType'] == 'Hybrid'
                                                  ? Colors.orange
                                                  : Colors.blue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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