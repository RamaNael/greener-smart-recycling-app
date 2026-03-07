/*import 'package:flutter/material.dart';
import 'package:greener/AdminPage.dart';
import 'package:greener/login_page.dart';
import 'package:greener/register_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/greener_text.png', height: 100),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(role: 'admin'),
                    ),
                  );
                },
                child: const Text('Login as Admin'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(role: 'user'),
                    ),
                  );
                },
                child: const Text('Login as User'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(role: 'organization'),
                    ),
                  );
                },
                child: const Text('Login as Organization'),
              ),
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(role: 'user'),
                    ),
                  );
                },
                child: const Text('Register as User'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(role: 'organization'),
                    ),
                  );
                },
                child: const Text('Register as Organization'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
