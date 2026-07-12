import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameInput = TextEditingController();
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();
  final startupNameInput = TextEditingController();
  final startupOneLinerInput = TextEditingController();
  final startupWebsiteInput = TextEditingController();
  String selectedRole = 'student';
  bool showPassword = false;

  bool isValidEmail(String email) {
    if (selectedRole == 'student') {
      return email.endsWith('@alustudent.com');
    } else {
      return email.endsWith('@alustudent.com') ||
          email.endsWith('@alueducation.com');
    }
  }

  void register() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (nameInput.text.isEmpty ||
        emailInput.text.isEmpty ||
        passwordInput.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // startup extra validation
    if (selectedRole == 'startup' && startupNameInput.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your startup name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedRole == 'startup' && startupOneLinerInput.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please tell us what your startup does'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isValidEmail(emailInput.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedRole == 'student'
                ? 'Students must use their @alustudent.com email!'
                : 'Startups must use @alustudent.com or @alueducation.com email!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool success = await auth.register(
      nameInput.text.trim(),
      emailInput.text.trim(),
      passwordInput.text.trim(),
      selectedRole,
      startupName: startupNameInput.text.trim(),
      startupOneLiner: startupOneLinerInput.text.trim(),
      startupWebsite: startupWebsiteInput.text.trim(),
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, color: Color(0xFF9683EC)),
            ),
            SizedBox(height: 24),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9683EC),
              ),
            ),
            SizedBox(height: 8),
            Text('Join ALU Grid today', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 32),

            // role picker first so email hint updates
            Text('I am a...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedRole = 'student'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedRole == 'student'
                            ? Color(0xFF9683EC)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedRole == 'student'
                              ? Color(0xFF9683EC)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Student',
                          style: TextStyle(
                            color: selectedRole == 'student'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedRole = 'startup'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedRole == 'startup'
                            ? Color(0xFF9683EC)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedRole == 'startup'
                              ? Color(0xFF9683EC)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Startup',
                          style: TextStyle(
                            color: selectedRole == 'startup'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            TextField(
              controller: nameInput,
              decoration: InputDecoration(
                labelText: selectedRole == 'startup' ? 'Your Full Name' : 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF9683EC)),
                ),
              ),
            ),
            SizedBox(height: 16),

            // extra startup fields
            if (selectedRole == 'startup') ...[
              TextField(
                controller: startupNameInput,
                decoration: InputDecoration(
                  labelText: 'Startup Name *',
                  hintText: 'e.g. EduTech Rwanda',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: startupOneLinerInput,
                decoration: InputDecoration(
                  labelText: 'What does your startup do? *',
                  hintText: 'e.g. We help farmers sell crops online',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: startupWebsiteInput,
                decoration: InputDecoration(
                  labelText: 'Website / Domain (optional)',
                  hintText: 'e.g. mystartup.com or github.com/mystartup',
                  prefixIcon: Icon(Icons.language, color: Color(0xFF9683EC)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9683EC)),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            TextField(
              controller: emailInput,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF9683EC)),
                ),
              ),
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Color(0xFF9683EC)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selectedRole == 'student'
                        ? 'Only @alustudent.com emails accepted'
                        : 'Only @alustudent.com or @alueducation.com emails accepted',
                    style: TextStyle(color: Color(0xFF9683EC), fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            TextField(
              controller: passwordInput,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF9683EC)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
              ),
            ),
            SizedBox(height: 8),

            if (auth.error.isNotEmpty)
              Text(auth.error, style: TextStyle(color: Colors.red)),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.loading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9683EC),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: auth.loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create Account',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Color(0xFF9683EC)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}