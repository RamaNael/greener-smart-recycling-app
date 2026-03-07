import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final bool isUser;
  const RegisterPage({super.key, this.isUser = false});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? nameError;
  String? phoneError;
  String? cityError;

  String? selectedCity;
  bool obscurePassword = true;
  bool isLoading = false;

  bool validatePassword(String password) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(password);
  }

  bool validateEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Create an account to continue!",
                  style: TextStyle(fontSize: 14, color: Color(0xFF6C7278)),
                ),
                const SizedBox(height: 24),
                _buildLabel("Full Name"),
                _buildInputField(
                  controller: nameController,
                  hint: "Enter your Full Name",
                  errorText: nameError,
                ),
                const SizedBox(height: 16),
                _buildLabel("Email"),
                _buildInputField(
                  controller: emailController,
                  hint: "email@example.com",
                  errorText: emailError,
                ),
                const SizedBox(height: 16),
                _buildLabel("City"),
                _buildDropdownField(),
                if (cityError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 8),
                    child: Text(
                      cityError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildLabel("Phone Number"),
                _buildPhoneField(),
                if (phoneError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 8),
                    child: Text(
                      phoneError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildLabel("Set Password"),
                _buildInputField(
                  controller: passwordController,
                  hint: "Enter new password",
                  obscure: true,
                  errorText: passwordError,
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E8C39),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _handleRegister,
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF6C7278)),
                    ),
                    GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF00BFFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    setState(() {
      isLoading = true;
      emailError = null;
      passwordError = null;
      nameError = null;
      phoneError = null;
      cityError = null;
    });

    if (nameController.text.trim().isEmpty) nameError = 'Full name is required';
    if (emailController.text.trim().isEmpty) {
      emailError = 'Email is required';
    } else if (!validateEmail(emailController.text.trim())) {
      emailError = 'Enter a valid email';
    }
    if (phoneController.text.trim().isEmpty)
      phoneError = 'Phone number is required';
    if (selectedCity == null) cityError = 'City is required';
    if (passwordController.text.trim().isEmpty) {
      passwordError = 'Password is required';
    } else if (!validatePassword(passwordController.text.trim())) {
      passwordError = 'Password must contain only letters and numbers';
    }

    if ([
      emailError,
      passwordError,
      nameError,
      phoneError,
      cityError,
    ].any((e) => e != null)) {
      setState(() => isLoading = false);
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await userCredential.user?.sendEmailVerification();

      final userData = {
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'city': selectedCity,
        'phone': phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userCredential.user!.uid,
      };

      if (widget.isUser) {
        userData['role'] = 'user';
        userData['started'] = false;
        userData['points'] = 0;
      } else {
        userData['role'] = 'organization';
        userData['status'] = 'pending';
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful! Please verify your email."),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          emailError =
              'The email address is already in use by another account.';
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      }
      setState(() => isLoading = false);
    }
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6C7278),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    String? errorText,
  }) {
    bool isPasswordField = hint.toLowerCase().contains("password");
    return TextField(
      controller: controller,
      obscureText: isPasswordField ? obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6E8C39)),
        ),
        suffixIcon:
            isPasswordField
                ? IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFBFBFBF),
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                )
                : null,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(
          "Select City",
          style: TextStyle(color: Colors.grey.withOpacity(0.6)),
        ),
        value: selectedCity,
        items:
            ["Amman", "Irbid", "Zarqa"]
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
        onChanged: (value) {
          setState(() {
            selectedCity = value;
            cityError = null;
          });
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Image.asset("images/flag.png", width: 24, height: 24),
          const SizedBox(width: 8),
          const Text("(962)", style: TextStyle(color: Color(0xFF6C7278))),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "70 000 0000",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
