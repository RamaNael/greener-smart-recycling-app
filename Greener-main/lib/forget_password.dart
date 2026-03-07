import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greener/MainLoginPage.dart';
import 'package:greener/login_page.dart';

// StatefulWidget for the Forget Password Screen
class ForgetPasswordScreen extends StatefulWidget {
  final String email; // Initial email to prefill the form if provided
  const ForgetPasswordScreen({super.key, required this.email});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

// State class for ForgetPasswordScreen
class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController =
      TextEditingController(); // Controller for email input
  String? emailError; // To store email validation error
  bool isButtonDisabled = false; // State to manage the button's enabled status

  @override
  void initState() {
    super.initState();
    // Set the initial email if provided
    emailController.text = widget.email;
  }

  // Validates the email using a regex pattern
  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  // Handles password reset logic
  Future<void> handlePasswordReset() async {
    final email = emailController.text.trim();

    setState(() {
      emailError = null; // Reset error before validation
    });

    if (!isValidEmail(email)) {
      setState(() {
        emailError =
            'Please enter a valid email address'; // Set error if email is invalid
      });
      return;
    }

    setState(() {
      isButtonDisabled = true; // Disable the button while processing
    });

    try {
      // Request Firebase to send a password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reset link sent to $email')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }

    // Wait for 3 seconds before re-enabling the button (simulating processing time)
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      setState(() => isButtonDisabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(
          context,
        ).size.width; // Calculate screen width for responsive padding

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
          ), // Responsive horizontal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),

              SizedBox(height: 20),

              Text(
                "Forget password?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12),

              Text(
                "Email Address",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),

              SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  errorText: emailError, // Show email validation error if any
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF6E8C39)),
                  ),
                ),
              ),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isButtonDisabled ? null : handlePasswordReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonDisabled ? Colors.grey : Color(0xFF6E8C39),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Color(0xFF6E8C39)),
                    ),
                  ),
                  child: Text(
                    'Reset password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
