import 'package:flutter/material.dart';

class AuthLoadingScreen extends StatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  State<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<AuthLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Navigate directly to the login screen without delay or token check
    if (mounted) {
      await Future.delayed(Duration.zero); // Ensure frame is built
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0B66C3),
        ),
      ),
    );
  }
}