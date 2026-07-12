import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bioInput = TextEditingController();
  final yearInput = TextEditingController();
  final fieldOfStudyInput = TextEditingController();
  final startupDescInput = TextEditingController();
  final customSkillInput = TextEditingController();
  bool editing = false;
  bool loading = false;

  List<String> allSkills = [
    'UI/UX Design',
    'Flutter',
    'Python',
    'JavaScript',
    'HTML/CSS',
    'React',
    'Node.js',
    'Marketing',
    'Content Writing',
    'Business Analysis',
    'Research',
    'Community Management',
    'Operations',
    'Graphic Design',
    'Data Analysis',
    'Social Media',
    'Project Management',
    'Figma',
    'Canva',
    'Video Editing',
  ];

  List<String> selectedSkills = [];

  // startup info loaded from firestore
  String startupName = '';
  String startupOneLiner = '';
  String startupWebsite = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.user!.uid)
        .get();

    if (doc.exists) {
      var data = doc.data()!;
      bioInput.text = data['bio'] ?? '';
      yearInput.text = data['year'] ?? '';
      fieldOfStudyInput.text = data['fieldOfStudy'] ?? '';
      startupDescInput.text = data['startupDesc'] ?? '';
      List skills = data['skills'] ?? [];
      List customSkills = data['customSkills'] ?? [];

      setState(() {
        startupName = data['startupName'] ?? '';
        startupOneLiner = data['startupOneLiner'] ?? '';
        startupWebsite = data['startupWebsite'] ?? '';
        selectedSkills = skills.map((s) => s.toString()).toList();
        for (var cs in customSkills) {
          if (!allSkills.contains(cs.toString())) {
            allSkills.add(cs.toString());
          }
          if (!selectedSkills.contains(cs.toString())) {
            selectedSkills.add(cs.toString());
          }
        }
      });
    }
  }

  void addCustomSkill() {
    String skill = customSkillInput.text.trim();
    if (skill.isEmpty) return;
    if (allSkills.contains(skill)) {
      customSkillInput.clear();
      return;
    }
    setState(() {
      allSkills.add(skill);
      selectedSkills.add(skill);
      customSkillInput.clear();
    });
  }

  void saveProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => loading = true);

    List<String> defaultSkillsList = [
      'UI/UX Design', 'Flutter', 'Python', 'JavaScript', 'HTML/CSS',
      'React', 'Node.js', 'Marketing', 'Content Writing', 'Business Analysis',
      'Research', 'Community Management', 'Operations', 'Graphic Design',
      'Data Analysis', 'Social Media', 'Project Management', 'Figma', 'Canva', 'Video Editing'
    ];

    List<String> customSkills = selectedSkills
        .where((s) => !defaultSkillsList.contains(s))
        .toList();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.user!.uid)
        .update({
      'bio': bioInput.text.trim(),
      'year': yearInput.text.trim(),
      'fieldOfStudy': fieldOfStudyInput.text.trim(),
      'skills': selectedSkills,
      'customSkills': customSkills,
      'startupDesc': startupDescInput.text.trim(),
    });

    setState(() {
      loading = false;
      editing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated!'),
        backgroundColor: Color(0xFF9683EC),
      ),
    );
  }

  void openLink(String url) async {
    if (url.isEmpty) return;
    if (!url.startsWith('http')) url = 'https://$url';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void deleteAccount() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure? This will permanently delete your account and all your data. This cannot be undone!',
        ),
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
      try {
        String uid = auth.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        await auth.user!.delete();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log out and log back in before deleting your account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDark;
    bool isStartup = auth.role == 'startup';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9683EC),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => editing = !editing),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF9683EC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF9683EC)),
                      ),
                      child: Text(
                        editing ? 'Cancel' : 'Edit',
                        style: TextStyle(color: Color(0xFF9683EC)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // profile card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF9683EC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF9683EC),
                      radius: 30,
                      child: Text(
                        auth.name.isNotEmpty ? auth.name[0].toUpperCase() : '?',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          if (isStartup && startupName.isNotEmpty)
                            Text(
                              startupName,
                              style: TextStyle(color: Color(0xFF9683EC), fontSize: 13),
                            ),
                          Text(
                            auth.role.toUpperCase(),
                            style: TextStyle(color: Color(0xFF9683EC), fontSize: 12),
                          ),
                          if (!isStartup && fieldOfStudyInput.text.isNotEmpty)
                            Text(
                              fieldOfStudyInput.text,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              if (editing) ...[
                if (!isStartup) ...[
                  TextField(
                    controller: bioInput,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell startups about yourself...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9683EC)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: fieldOfStudyInput,
                    decoration: InputDecoration(
                      labelText: 'Field of Study',
                      hintText: 'e.g. Computer Science, Business...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9683EC)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: yearInput,
                    decoration: InputDecoration(
                      labelText: 'Year of Study',
                      hintText: 'e.g. Year 2',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9683EC)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text('My Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customSkillInput,
                          decoration: InputDecoration(
                            hintText: 'Add a custom skill...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF9683EC)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: addCustomSkill,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF9683EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allSkills.map((skill) {
                      bool selected = selectedSkills.contains(skill);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedSkills.remove(skill);
                            } else {
                              selectedSkills.add(skill);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? Color(0xFF9683EC) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? Color(0xFF9683EC) : Colors.grey,
                            ),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  TextField(
                    controller: startupDescInput,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Startup Description',
                      hintText: 'Tell students more about your startup...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9683EC)),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9683EC),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),

              ] else ...[
                if (!isStartup) ...[
                  if (bioInput.text.isNotEmpty) ...[
                    Text('Bio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(bioInput.text, style: TextStyle(color: Colors.grey, height: 1.5)),
                    SizedBox(height: 16),
                  ],
                  if (yearInput.text.isNotEmpty) ...[
                    Text('Year of Study', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(yearInput.text, style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 16),
                  ],
                  if (selectedSkills.isNotEmpty) ...[
                    Text('My Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedSkills.map((skill) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF9683EC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Color(0xFF9683EC)),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(color: Color(0xFF9683EC), fontSize: 13),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                  ],
                ] else ...[
                  // startup view mode
                  if (startupOneLiner.isNotEmpty) ...[
                    Text('What we do', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(startupOneLiner, style: TextStyle(color: Colors.grey, height: 1.5)),
                    SizedBox(height: 16),
                  ],
                  if (startupDescInput.text.isNotEmpty) ...[
                    Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(startupDescInput.text, style: TextStyle(color: Colors.grey, height: 1.5)),
                    SizedBox(height: 16),
                  ],
                  if (startupWebsite.isNotEmpty) ...[
                    Text('Website', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => openLink(startupWebsite),
                      child: Row(
                        children: [
                          Icon(Icons.language, size: 16, color: Color(0xFF9683EC)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              startupWebsite,
                              style: TextStyle(
                                color: Color(0xFF9683EC),
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ],
              ],

              SizedBox(height: 8),

              // dark mode toggle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: Color(0xFF9683EC),
                        ),
                        SizedBox(width: 12),
                        Text(
                          isDark ? 'Dark Mode' : 'Light Mode',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeColor: Color(0xFF9683EC),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await auth.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SizedBox(height: 12),

              // delete account
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: deleteAccount,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Delete Account', style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}