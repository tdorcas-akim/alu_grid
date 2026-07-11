import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'browse_screen.dart';
import 'applications_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'startup_dashboard_screen.dart';
import 'post_job_screen.dart';
import 'all_applicants_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTab = 0;

  List<Widget> studentScreens = [
    BrowseScreen(),
    ApplicationsScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  List<Widget> startupScreens = [
    StartupDashboardScreen(),
    PostJobScreen(),
    AllApplicantsScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    bool isStartup = auth.role == 'startup';

    List<Widget> screens = isStartup ? startupScreens : studentScreens;

    return Scaffold(
      body: screens[currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (i) => setState(() => currentTab = i),
        selectedItemColor: Color(0xFF9683EC),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: isStartup
            ? [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post Job'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Applicants'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ]
            : [
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
                BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Applications'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
      ),
    );
  }
}