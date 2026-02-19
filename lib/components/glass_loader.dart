import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GlassLoader extends StatelessWidget {
  final String? message;
  final double size;

  const GlassLoader({
    super.key,
    this.message,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/loader/Loading_40_Paperplane.json',
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircularProgressIndicator(
                      color: Colors.white,
                    );
                  },
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}