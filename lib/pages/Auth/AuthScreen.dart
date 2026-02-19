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
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  
  // Initialize these later in didChangeDependencies
  double _screenWidth = 0;

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
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(begin: 0, end: -350)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.ease));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidth = MediaQuery.of(context).size.width;
    _slideAnimation = Tween<double>(begin: 0, end: -_screenWidth * 0.35)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.ease));
  }

  void switchTo(String type) {
    setState(() {
      mode = type;
    });
    if (type == "login") {
      _slideController.reverse();
    } else {
      _slideController.forward();
    }
  }

  Future<void> handleAuth() async {
    try {
      // Validation
      if (mode == "login") {
        if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
          _showAlert("Error", "Phone and password are required");
          return;
        }
      } else {
        if (usernameController.text.isEmpty ||
            phoneController.text.isEmpty ||
            emailController.text.isEmpty ||
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
          "phone": phoneController.text.trim(),
          "password": passwordController.text,
        });

        // ── Securely save access token ──────────────────────────────────────
        final token = res['token']?.toString() ?? '';
        await AuthTokenManager.instance.saveToken(token);

        // ── Extract and securely save user data ─────────────────────────────
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

        // If user data is directly in response root
        if (userData.isEmpty) {
          userData = Map<String, dynamic>.from(res);
        }

        // Ensure phone is present
        if (userData['phone'] == null) {
          userData['phone'] = phoneController.text.trim();
        }

        // Save user data securely (no plain-text storage, no logging)
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
      // Error is shown to user via dialog — not logged to avoid leaking data.
      
      String message = "Something went wrong";
      if (err is String) {
        message = err;
      }

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
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Wave with Animation
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_slideAnimation.value, 0),
                          child: SizedBox(
                            width: size.width * 1.5,
                            height: 160,
                            child: CustomPaint(
                              painter: TopWavePainter(),
                            ),
                          ),
                        );
                      },
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Tabs
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => switchTo("login"),
                                    child: Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: mode == "login"
                                            ? const Color(0xFF0B66C3)
                                            : Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => switchTo("register"),
                                    child: Text(
                                      "REGISTER",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: mode == "register"
                                            ? const Color(0xFF0B66C3)
                                            : Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Form
                            Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Column(
                                children: [
                                  // Username - Register only
                                  if (mode == "register")
                                    InputField(
                                      icon: Icons.person_outline,
                                      placeholder: "User Name",
                                      controller: usernameController,
                                    ),
                                  
                                  // Phone
                                  InputField(
                                    icon: Icons.call_outlined,
                                    placeholder: "Phone Number",
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  
                                  // Email - Register only
                                  if (mode == "register")
                                    InputField(
                                      icon: Icons.mail_outline,
                                      placeholder: "Email",
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                  
                                  // Password
                                  InputField(
                                    icon: Icons.lock_outline,
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
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Button
                                  GestureDetector(
                                    onTap: loading ? null : handleAuth,
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B66C3),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: loading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                mode == "login" ? "Login" : "Register",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  
                                  if (mode == "login") ...[
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/forgot-password');
                                      },
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: Color(0xFF0B66C3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Don't you have an account? ",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        GestureDetector(
                                          onTap: () => switchTo("register"),
                                          child: const Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              color: Color(0xFF0B66C3),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Wave
                    SizedBox(
                      width: size.width,
                      height: 140,
                      child: const CustomPaint(
                        painter: BottomWavePainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Input Field Widget
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
      height: 52,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? obscureText : false,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Colors.grey,
              ),
              onPressed: onToggleObscure,
            ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}

// Top Wave Painter
class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B66C3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 96);
    path.lineTo(120, 128);
    path.cubicTo(240, 160, 480, 224, 720, 218.7);
    path.cubicTo(960, 213, 1200, 139, 1320, 112);
    path.lineTo(1440, 96);
    path.lineTo(1440, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bottom Wave Painter
class BottomWavePainter extends CustomPainter {
  const BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B66C3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 256);
    path.lineTo(120, 224);
    path.cubicTo(240, 192, 480, 128, 720, 117.3);
    path.cubicTo(960, 107, 1200, 149, 1320, 170.7);
    path.lineTo(1440, 192);
    path.lineTo(1440, 320);
    path.lineTo(0, 320);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}