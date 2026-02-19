// lib/pages/IQ/IQ2.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/footer.dart';
import 'IQ3.dart'; // Add this import

class IQ2Screen extends StatefulWidget {
  const IQ2Screen({super.key});

  @override
  State<IQ2Screen> createState() => _IQ2ScreenState();
}

class _IQ2ScreenState extends State<IQ2Screen> {
  bool _modalVisible = false;
  int _timeLeft = 45 * 60; // 45 minutes in seconds
  bool _testStarted = false;
  bool _timerActive = false;
  Timer? _timer;

  // Format time function
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Start the timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && _timerActive) {
        setState(() {
          _timeLeft--;
        });
      } else if (_timeLeft == 0 && _timerActive) {
        _timerActive = false;
        _showTimeUpAlert();
      }
    });
  }

  // Show time up alert
  void _showTimeUpAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Time's Up!"),
        content: const Text("Your test time has expired."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Start test function
  void _startTest() {
    setState(() {
      _modalVisible = false;
      _testStarted = true;
      _timerActive = true;
    });
    
    _startTimer();
    
    // Navigate to IQ3 after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IQ3Screen(),
        ),
      );
    });
  }

  // Show exit confirmation
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Test?"),
        content: const Text("If you exit now, your progress will not be saved."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Scale function for responsive sizing
  double _scale(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return size * 1.2; // Desktop
    if (screenWidth >= 768) return size * 1.1; // Tablet
    return size; // Mobile
  }

  // Responsive value function
  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop; // Desktop
    if (screenWidth >= 768) return tablet; // Tablet
    return mobile; // Mobile
  }

  // Show URL dialog
  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTube Video'),
        content: Text('Would you like to open: $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening: $url')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // ===== HEADER =====
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0052A2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  height: _responsiveValue(52, 60, 70),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        width: _scale(40),
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            if (_testStarted) {
                              _showExitConfirmation();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            size: _scale(isTablet ? 28 : 24),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      // Title
                      Expanded(
                        child: Center(
                          child: Text(
                            'IQ Test',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _responsiveValue(17, 22, 24),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Spacer for symmetry
                      SizedBox(width: _scale(40)),
                    ],
                  ),
                ),
              ),

              // ===== MAIN CONTENT =====
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: _responsiveValue(20, 30, 40)),

                          // ===== TEST INSTRUCTIONS CARD =====
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_responsiveValue(16, 20, 24)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: _scale(12),
                                  offset: Offset(0, _scale(4)),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Card Header
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0072BC), Color(0xFF0052A2)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: _responsiveValue(18, 22, 26),
                                    horizontal: _responsiveValue(20, 24, 28),
                                  ),
                                  child: Text(
                                    'Test Instructions',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(20, 24, 28),
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Card Body
                                Padding(
                                  padding: EdgeInsets.all(_responsiveValue(20, 28, 32)),
                                  child: Column(
                                    children: [
                                      // Instructions Intro
                                      Text(
                                        'Please read the following instructions carefully before starting the IQ assessment. This test is designed to evaluate your logical reasoning and problem-solving skills.',
                                        style: TextStyle(
                                          fontSize: _responsiveValue(16, 18, 20),
                                          color: const Color(0xFF333333),
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: _responsiveValue(20, 28, 32)),

                                      // ===== INFO GRID =====
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final double infoCardWidth = isMobile
                                            ? (constraints.maxWidth - _scale(12)) / 2
                                            : (constraints.maxWidth - _scale(20) * 3) / 4;
                                          
                                          return Wrap(
                                            spacing: _scale(isMobile ? 12 : 20),
                                            runSpacing: _scale(isMobile ? 12 : 20),
                                            children: [
                                              // Number of Questions
                                              _buildInfoCard(
                                                icon: Icons.description,
                                                title: 'Number of Questions',
                                                value: '30',
                                                label: 'questions',
                                                width: infoCardWidth,
                                              ),
                                              
                                              // Time Limit
                                              _buildInfoCard(
                                                icon: Icons.timer,
                                                title: 'Time Limit',
                                                value: '45',
                                                label: 'minutes',
                                                width: infoCardWidth,
                                              ),
                                              
                                              // Marking Scheme
                                              _buildInfoCard(
                                                icon: Icons.check_circle,
                                                title: 'Marking Scheme',
                                                value: '+2',
                                                label: 'per correct answer',
                                                width: infoCardWidth,
                                              ),
                                              
                                              // Negative Marking
                                              _buildInfoCard(
                                                icon: Icons.close,
                                                title: 'Negative Marking',
                                                value: 'No',
                                                label: 'wrong answers',
                                                width: infoCardWidth,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(height: _responsiveValue(20, 28, 32)),

                                      // ===== KEY POINTS =====
                                      Container(
                                        padding: EdgeInsets.all(_responsiveValue(18, 24, 28)),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F7FF),
                                          borderRadius: BorderRadius.circular(_responsiveValue(12, 16, 20)),
                                          border: Border(
                                            left: BorderSide(
                                              color: const Color(0xFF0072BC),
                                              width: _scale(4),
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Key Points:',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(18, 20, 22),
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF003366),
                                              ),
                                            ),
                                            SizedBox(height: _scale(12)),
                                            
                                            _buildKeyPoint(
                                              'The test consists of 30 questions',
                                              highlightText: '30 questions',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            
                                            _buildKeyPoint(
                                              'You have 45 minutes to complete',
                                              highlightText: '45 minutes',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            
                                            _buildKeyPoint(
                                              'Each correct answer awards 2 points',
                                              highlightText: '2 points',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            
                                            _buildKeyPoint(
                                              'No negative marking for wrong answers',
                                              highlightText: 'No negative marking',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            
                                            _buildKeyPoint(
                                              'Answer all questions for accurate scoring',
                                              highlightText: 'Answer all questions',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: _responsiveValue(20, 28, 32)),

                                      // ===== TIMER DISPLAY =====
                                      if (_testStarted)
                                        Container(
                                          padding: EdgeInsets.all(_responsiveValue(18, 24, 28)),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0052A2),
                                            borderRadius: BorderRadius.circular(_responsiveValue(12, 16, 20)),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.timer,
                                                size: _scale(isTablet ? 28 : 22),
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: _scale(8)),
                                              Text(
                                                _formatTime(_timeLeft),
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(36, 42, 48),
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: _scale(4)),
                                              Text(
                                                'Time Remaining',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(16, 18, 20),
                                                  color: Colors.white.withOpacity(0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      SizedBox(height: _responsiveValue(20, 28, 32)),

                                      // ===== START BUTTON =====
                                      GestureDetector(
                                        onTap: () => setState(() => _modalVisible = true),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(_responsiveValue(16, 20, 24)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFF416C).withOpacity(0.3),
                                                blurRadius: _scale(8),
                                                offset: Offset(0, _scale(4)),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: _responsiveValue(18, 22, 26),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Start Test →',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(18, 22, 24),
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: _responsiveValue(16, 20, 24)),

                                      // ===== NOTE =====
                                      Text(
                                        'Make sure you have a stable internet connection and won\'t be interrupted during the test.',
                                        style: TextStyle(
                                          fontSize: _responsiveValue(14, 16, 18),
                                          color: const Color(0xFF666666),
                                          fontStyle: FontStyle.italic,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: _responsiveValue(20, 30, 40)),

                          // ===== PROGRESS SECTION =====
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            padding: EdgeInsets.all(_responsiveValue(20, 28, 32)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_responsiveValue(16, 20, 24)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: _scale(8),
                                  offset: Offset(0, _scale(2)),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Progress Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Test Progress',
                                      style: TextStyle(
                                        fontSize: _responsiveValue(16, 20, 22),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF003366),
                                      ),
                                    ),
                                    Text(
                                      '0%',
                                      style: TextStyle(
                                        fontSize: _responsiveValue(16, 20, 22),
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0072BC),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: _scale(12)),
                              
                                // Progress Bar
                                Container(
                                  height: _responsiveValue(8, 12, 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9ECEF),
                                    borderRadius: BorderRadius.circular(_responsiveValue(4, 6, 8)),
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: 0.0, // 0% progress
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0072BC),
                                        borderRadius: BorderRadius.circular(_responsiveValue(4, 6, 8)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: _scale(8)),
                              
                                // Progress Text
                                Text(
                                  '0 of 30 questions answered',
                                  style: TextStyle(
                                    fontSize: _responsiveValue(14, 16, 18),
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: _responsiveValue(20, 30, 40)),

                          // ===== YOUTUBE VIDEO SECTION - LIKE EXAM1 & EXAM2 =====
                          Container(
                            margin: EdgeInsets.only(
                              top: _responsiveValue(20, 30, 40),
                              bottom: 0,
                            ),
                            width: double.infinity,
                            height: isDesktop ? 360 : (isTablet ? 280 : 220),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://img.youtube.com/vi/L2zqTYgcpfg/maxresdefault.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: GestureDetector(
                                onTap: () => _showUrlDialog('https://www.youtube.com/embed/L2zqTYgcpfg'),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Modal overlay
          if (_modalVisible)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when clicking on modal
                  child: Container(
                    width: isMobile ? screenWidth * 0.9 : 400,
                    margin: EdgeInsets.all(_scale(20)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_responsiveValue(16, 20, 24)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Modal Header
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0072BC), Color(0xFF0052A2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: _responsiveValue(18, 22, 26),
                            horizontal: _responsiveValue(20, 24, 28),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ready to Begin?',
                                style: TextStyle(
                                  fontSize: _responsiveValue(18, 22, 24),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _modalVisible = false),
                                icon: Icon(
                                  Icons.close,
                                  size: _scale(24),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: _scale(36),
                                  minHeight: _scale(36),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Modal Body
                        Padding(
                          padding: EdgeInsets.all(_responsiveValue(20, 28, 32)),
                          child: Column(
                            children: [
                              // Modal Icon
                              Icon(
                                Icons.help,
                                size: _scale(isTablet ? 70 : 60),
                                color: const Color(0xFF0072BC),
                              ),
                              SizedBox(height: _scale(20)),
                              
                              // Modal Message
                              Text(
                                'Once you start, the timer will begin counting down from 45 minutes. Are you ready to begin the test?',
                                style: TextStyle(
                                  fontSize: _responsiveValue(16, 18, 20),
                                  color: const Color(0xFF333333),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: _scale(24)),
                              
                              // Modal Buttons
                              Row(
                                children: [
                                  // Cancel Button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => setState(() => _modalVisible = false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF8F9FA),
                                        foregroundColor: const Color(0xFF666666),
                                        padding: EdgeInsets.symmetric(
                                          vertical: _responsiveValue(14, 18, 22),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(_responsiveValue(12, 16, 20)),
                                          side: BorderSide(
                                            color: const Color(0xFFDEE2E6),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: _responsiveValue(16, 18, 20),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: _scale(12)),
                                  
                                  // Confirm Button
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(_responsiveValue(12, 16, 20)),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _startTest,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: _responsiveValue(14, 18, 22),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(_responsiveValue(12, 16, 20)),
                                          ),
                                        ),
                                        child: Text(
                                          'Yes, Start Test',
                                          style: TextStyle(
                                            fontSize: _responsiveValue(16, 18, 20),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const Footer(currentIndex: 0),
    );
  }

  // Helper Widget: Info Card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String label,
    required double width,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(_responsiveValue(12, 16, 20)),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: _responsiveValue(48, 60, 72),
            height: _responsiveValue(48, 60, 72),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2FF),
              borderRadius: BorderRadius.circular(_responsiveValue(24, 30, 36)),
            ),
            child: Icon(
              icon,
              size: _responsiveValue(24, 30, 36),
              color: const Color(0xFF0072BC),
            ),
          ),
          SizedBox(height: _scale(12)),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: _responsiveValue(14, 16, 18),
              color: const Color(0xFF666666),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _scale(4)),
          
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: _responsiveValue(24, 28, 32),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0072BC),
            ),
          ),
          SizedBox(height: _scale(2)),
          
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: _responsiveValue(12, 14, 16),
              color: const Color(0xFF888888),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Widget: Key Point
  Widget _buildKeyPoint(String text, {String? highlightText}) {
    final List<TextSpan> textSpans = [];
    final words = text.split(' ');
    
    for (final word in words) {
      if (highlightText != null && word.contains(highlightText.split(' ')[0])) {
        textSpans.add(TextSpan(
          text: '$word ',
          style: TextStyle(
            fontSize: _responsiveValue(16, 18, 20),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0052A2),
            height: 1.5,
          ),
        ));
      } else {
        textSpans.add(TextSpan(
          text: '$word ',
          style: TextStyle(
            fontSize: _responsiveValue(16, 18, 20),
            color: const Color(0xFF333333),
            height: 1.5,
          ),
        ));
      }
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bullet
        Container(
          width: _scale(20),
          padding: EdgeInsets.only(top: _scale(4)),
          child: Icon(
            Icons.circle,
            size: _scale(8),
            color: const Color(0xFF0072BC),
          ),
        ),
        SizedBox(width: _scale(4)),
        
        // Text
        Expanded(
          child: RichText(
            text: TextSpan(children: textSpans),
          ),
        ),
      ],
    );
  }
}