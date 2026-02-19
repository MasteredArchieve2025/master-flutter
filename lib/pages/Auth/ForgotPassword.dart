import 'package:flutter/material.dart';
import 'Authapi.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  Future<void> handleResetPassword() async {
    // Validation
    if (phoneController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showAlert("Error", "All fields are required");
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showAlert("Error", "Password must be at least 6 characters");
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showAlert("Error", "Passwords do not match");
      return;
    }

    try {
      setState(() => loading = true);

      final res = await AuthApi.forgotPasswordApi({
        "phone": phoneController.text.trim(),
        "newPassword": newPasswordController.text,
        "confirmPassword": confirmPasswordController.text,
      });

      _showAlert(
        "Success",
        res['message'] ?? "Password reset successful",
        onOk: () {
          Navigator.pushReplacementNamed(context, '/auth');
        },
      );
    } catch (err) {
      print("FORGOT PASSWORD ERROR 👉 $err");
      
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
    phoneController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
                    // Top Wave
                    SizedBox(
                      width: size.width * 1.5,
                      height: 160,
                      child: const CustomPaint(
                        painter: ForgotTopWavePainter(),
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Don’t worry, reset your password below",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF777777),
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Form
                            Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Column(
                                children: [
                                  // Phone Number
                                  ForgotInputField(
                                    icon: Icons.call_outlined,
                                    placeholder: "Phone Number",
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  
                                  // New Password
                                  ForgotInputField(
                                    icon: Icons.lock_outline,
                                    placeholder: "New Password",
                                    controller: newPasswordController,
                                    isPassword: true,
                                    obscureText: obscureNewPassword,
                                    onToggleObscure: () {
                                      setState(() {
                                        obscureNewPassword = !obscureNewPassword;
                                      });
                                    },
                                  ),
                                  
                                  // Confirm Password
                                  ForgotInputField(
                                    icon: Icons.lock_outline,
                                    placeholder: "Confirm Password",
                                    controller: confirmPasswordController,
                                    isPassword: true,
                                    obscureText: obscureConfirmPassword,
                                    onToggleObscure: () {
                                      setState(() {
                                        obscureConfirmPassword = !obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  
                                  const SizedBox(height: 14),
                                  
                                  // Reset Button
                                  GestureDetector(
                                    onTap: loading ? null : handleResetPassword,
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
                                            : const Text(
                                                "Reset Password",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 18),
                                  
                                  // Back to Login
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.arrow_back,
                                          size: 18,
                                          color: Color(0xFF0B66C3),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "Back to Login",
                                          style: TextStyle(
                                            color: Color(0xFF0B66C3),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                        painter: ForgotBottomWavePainter(),
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

// Custom Input Field for Forgot Password
class ForgotInputField extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;

  const ForgotInputField({
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

// Top Wave Painter for Forgot Password
class ForgotTopWavePainter extends CustomPainter {
  const ForgotTopWavePainter();

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

// Bottom Wave Painter for Forgot Password
class ForgotBottomWavePainter extends CustomPainter {
  const ForgotBottomWavePainter();

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