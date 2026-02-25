import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Authapi.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String selectedCountryCode = "+91";
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  Future<void> handleResetPassword() async {
    if (phoneController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showAlert("Error", "All fields are required");
      return;
    }

    if (phoneController.text.trim().length != 10) {
      _showAlert("Error", "Phone number must be 10 digits");
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
        "phone": selectedCountryCode + phoneController.text.trim(),
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: SemicircleTopClipper(),
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
                  ),
                  const Positioned(
                    top: 80,
                    left: 40,
                    child: Text(
                      "RESET",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              // Form content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter your details to reset your password",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),

                    InputField(
                      icon: Icons.phone,
                      placeholder: "Phone Number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      prefixWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF0066BE).withOpacity(0.2)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCountryCode,
                                isDense: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0066BE)),
                                items: ["+91", "+1", "+44", "+971"].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      "IND $value",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0066BE),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedCountryCode = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      maxLength: 10,
                    ),

                    InputField(
                      icon: Icons.lock,
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

                    InputField(
                      icon: Icons.lock_clock,
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

                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: loading ? null : handleResetPassword,
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
                              : const Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Back to Login",
                          style: TextStyle(
                            color: Color(0xFF0066BE),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Semicircle
              ClipPath(
                clipper: SemicircleBottomClipper(),
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
  final Widget? prefixWidget;
  final int? maxLength;

  const InputField({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.prefixWidget,
    this.maxLength,
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
        maxLength: maxLength,
        inputFormatters: maxLength != null
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maxLength)
              ]
            : null,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          counterText: "",
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black, size: 28),
                if (prefixWidget != null) ...[
                  const SizedBox(width: 10),
                  prefixWidget!,
                ],
              ],
            ),
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

class SemicircleTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;

    // Semicircle sitting on top, flat top
    path.addArc(
      Rect.fromLTWH(-w * 0.1, -h, w * 1.2, h * 2), 
      3.14, 
      -3.14
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SemicircleBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;

    // Semicircle sitting at bottom, flat bottom
    path.addArc(
      Rect.fromLTWH(-w * 0.1, 0, w * 1.2, h * 2), 
      3.14, 
      3.14
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}