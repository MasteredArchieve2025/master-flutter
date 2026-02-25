import 'package:flutter/material.dart';
import 'dart:convert';
import 'Authapi.dart';
import '../../services/auth_token_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  String mode = "login";
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Form controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void switchTo(String type) {
    if (mode == type) return;
    setState(() {
      mode = type;
    });
    if (type == "login") {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Future<void> handleAuth() async {
    try {
      if (mode == "login") {
        if (usernameController.text.trim().isEmpty || passwordController.text.isEmpty) {
          _showAlert("Error", "User name and password are required");
          return;
        }
      } else {
        if (usernameController.text.trim().isEmpty ||
            phoneController.text.trim().isEmpty ||
            emailController.text.trim().isEmpty ||
            passwordController.text.isEmpty) {
          _showAlert("Error", "All fields are required");
          return;
        }
        if (passwordController.text.length < 6) {
          _showAlert("Error", "Password must be at least 6 characters");
          return;
        }
      }

      setState(() => loading = true);

      if (mode == "login") {
        final res = await AuthApi.loginApi({
          "username": usernameController.text.trim(),
          "password": passwordController.text,
        });

        final token = res['token']?.toString() ?? '';
        await AuthTokenManager.instance.saveToken(token);

        Map<String, dynamic> userData = {};
        if (res['user'] != null) {
          if (res['user'] is Map) {
            userData = Map<String, dynamic>.from(res['user']);
          } else if (res['user'] is String) {
            try {
              userData = jsonDecode(res['user']);
            } catch (e) {
              userData = {'username': res['user'].toString()};
            }
          }
        }

        if (userData.isEmpty) {
          userData = Map<String, dynamic>.from(res);
        }

        await AuthTokenManager.instance.saveUserData(userData);

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        final res = await AuthApi.signupApi({
          "username": usernameController.text.trim(),
          "phone": phoneController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
        });

        _showAlert("Success", "Registration successful. Please login.",
            onOk: () => switchTo("login"));
      }
    } catch (err) {
      String message = "Something went wrong";
      if (err is String) message = err;
      _showAlert("Error", message);
    } finally {
      setState(() => loading = false);
    }
  }

  void _showAlert(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onOk != null) onOk();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // Header with Tabs
              Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return ClipPath(
                        clipper: TopWaveClipper(_animation.value),
                        child: Container(
                          height: 220,
                          width: size.width,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0066BE), Color(0xFF005DAE)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => switchTo("login"),
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    color: Color.lerp(
                                      const Color(0xFF1E1E1E),
                                      Colors.white,
                                      _animation.value,
                                    ),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                );
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () => switchTo("register"),
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Text(
                                  "REGISTER",
                                  style: TextStyle(
                                    color: Color.lerp(
                                      Colors.white,
                                      const Color(0xFF1E1E1E),
                                      _animation.value,
                                    ),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Form content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  children: [
                    InputField(
                      icon: Icons.person,
                      placeholder: "User Name",
                      controller: usernameController,
                    ),

                    if (mode == "register") ...[
                      InputField(
                        icon: Icons.phone,
                        placeholder: "Phone Number",
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      InputField(
                        icon: Icons.email,
                        placeholder: "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],

                    InputField(
                      icon: Icons.lock,
                      placeholder: "Password",
                      controller: passwordController,
                      isPassword: true,
                      obscureText: obscurePassword,
                      onToggleObscure: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),

                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: loading ? null : handleAuth,
                      child: Container(
                        height: 52,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066BE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  mode == "login" ? "Login" : "Register",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (mode == "login") ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF0066BE),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't you have an account yet? ",
                            style: TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => switchTo("register"),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xFF0066BE),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Wave
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: BottomWaveClipper(_animation.value),
                    child: Container(
                      height: 140,
                      width: size.width,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF005DAE), Color(0xFF0066BE)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;

  const InputField({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black.withOpacity(0.2),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  final double value;
  TopWaveClipper(this.value);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;

    // Semicircle with flat top, curving below
    if (value < 0.5) {
      // Login mode: Semicircle on the right (covers REGISTER)
      path.addArc(
        Rect.fromLTWH(w * 0.4, -h, w * 1.2, h * 2), 
        3.14, 
        -3.14
      );
    } else {
      // Register mode: Semicircle on the left (covers LOGIN)
      path.addArc(
        Rect.fromLTWH(-w * 0.6, -h, w * 1.2, h * 2), 
        0, 
        3.14
      );
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TopWaveClipper oldClipper) => oldClipper.value != value;
}

class BottomWaveClipper extends CustomClipper<Path> {
  final double value;
  BottomWaveClipper(this.value);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;

    // Semicircle with flat bottom, curving above
    path.addArc(
      Rect.fromLTWH(-w * 0.1, 0, w * 1.2, h * 2), 
      3.14, 
      3.14
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(BottomWaveClipper oldClipper) => oldClipper.value != value;
}

