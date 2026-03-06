import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();

    // Navigate after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacementNamed(context, '/loading');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    // Responsive dimensions
    final logoSize = isTablet ? size.width * 0.15 : size.width * 0.25;
    final fontSize = isTablet ? size.width * 0.04 : size.width * 0.06;
    final spacing = isTablet ? size.height * 0.02 : size.height * 0.015;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0066BE),
              Color(0xFF004C8C),
              Color(0xFF003366),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Minimal background effect
            Positioned.fill(
              child: CustomPaint(
                painter: MinimalBackgroundPainter(),
              ),
            ),

            // Main content - Centered vertically and horizontally
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/master_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white,
                                child: Icon(
                                  Icons.archive,
                                  size: logoSize * 0.5,
                                  color: const Color(0xFF0066BE),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: spacing),

                      // App name - Smaller letters
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MASTER',
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 2,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'ARCHIEVE',
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 2,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Version number at bottom - Smaller and compact
            Positioned(
              bottom: size.height * 0.03,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Minimal background painter
class MinimalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw minimal circles
    for (int i = 0; i < 5; i++) {
      double x = (i * 80) % size.width;
      double y = (i * 60) % size.height;

      canvas.drawCircle(
        Offset(x, y),
        30,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
