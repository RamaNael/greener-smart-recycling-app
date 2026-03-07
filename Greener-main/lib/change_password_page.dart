import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forget_password.dart';

// StatefulWidget for changing the password.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

// State class for the ChangePasswordPage.
class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // Text controllers for password fields.
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Error messages for validation errors.
  String? currentPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  // Visibility state for password fields.
  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // Validates the password format.
  bool validatePassword(String password) {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{6,}$').hasMatch(password);
  }

  // Method to update the user's password.
  void updatePassword() async {
    setState(() {
      // Reset errors before validation.
      currentPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
    });

    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validate new password and confirm password.
    if (!validatePassword(newPassword)) {
      setState(() => newPasswordError = 'Password must include numbers, letters & special characters.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => confirmPasswordError = 'Passwords do not match');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(email: user!.email!, password: currentPassword);

      // Re-authenticate user and update password.
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => currentPasswordError = 'Incorrect current password');
    }
  }

  @override
  void initState() {
    super.initState();
    // Listeners to validate password in real-time.
    newPasswordController.addListener(() {
      final password = newPasswordController.text;
      setState(() {
        newPasswordError =
        password.isEmpty || validatePassword(password) ? null : 'Invalid password format';
      });
    });
    confirmPasswordController.addListener(() {
      setState(() {
        confirmPasswordError =
        confirmPasswordController.text == newPasswordController.text ? null : 'Passwords do not match';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),  // Allows user to navigate back to the previous screen.
        ),
        title: Text("Change Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your password must be at least 6 characters and should include a combination of numbers, letters, and special characters (@\$%&).",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),

            // TextField for current password.
            _buildTextField("Current Password", currentPasswordController, isCurrentPasswordVisible, currentPasswordError, () {
              setState(() => isCurrentPasswordVisible = !isCurrentPasswordVisible);
            }),
            SizedBox(height: 16),

            // TextField for new password.
            _buildTextField("New Password", newPasswordController, isNewPasswordVisible, newPasswordError, () {
              setState(() => isNewPasswordVisible = !isNewPasswordVisible);
            }),
            SizedBox(height: 16),

            // TextField for confirming new password.
            _buildTextField("Confirm Password", confirmPasswordController, isConfirmPasswordVisible, confirmPasswordError, () {
              setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible);
            }),
            SizedBox(height: 16),

            // Provides a link to forget password screen.
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetPasswordScreen(email: '',)),
                  );
                },
                child: Text("Forget password?", style: TextStyle(color: Color(0xFF00BFFF))),
              ),
            ),

            Spacer(),

            // Row for Cancel and Change Password buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6E8C39),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: updatePassword,
                  child: Text("Change Password", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Builds text fields for password inputs.
  Widget _buildTextField(String hint, TextEditingController controller, bool isVisible, String? errorText, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,  // Controls visibility of password.
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,  // Displays error text dynamically based on validation.
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF6E8C39)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,  // Toggles password visibility.
        ),
      ),
    );
  }
}
