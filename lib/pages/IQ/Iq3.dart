// lib/pages/IQ/IQ3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'Iq_result.dart';

class IQ3Screen extends StatefulWidget {
  const IQ3Screen({super.key});

  @override
  State<IQ3Screen> createState() => _IQ3ScreenState();
}

class _IQ3ScreenState extends State<IQ3Screen> {
  int _currentQuestion = 1; // Start from question 2 as per image
  List<int?> _answers = List.filled(30, null);
  int _timeLeft = 44 * 60 + 17; // 44:17 as per image
  bool _testCompleted = false;
  bool _showSubmitModal = false;
  bool _loading = false;
  int? _selectedOption;
  List<int> _visitedQuestions = [0, 1]; // Questions 1 and 2 visited
  Timer? _timer;

  // Sample questions data (30 questions)
  final List<Map<String, dynamic>> _sampleQuestions = [
    {
      'id': 1,
      'question': "Complete the sequence: 2, 4, 8, 16, ?",
      'options': ["24", "32", "28", "20"],
      'correctAnswer': 1,
      'type': "numerical",
      'difficulty': "medium",
    },
    {
      'id': 2,
      'question': "Which word does NOT belong with the others?",
      'options': ["Apple", "Banana", "Carrot", "Orange"],
      'correctAnswer': 2,
      'type': "verbal",
      'difficulty': "easy",
    },
    // Add more questions here (total 30)
    for (int i = 3; i <= 30; i++)
      {
        'id': i,
        'question': "Sample question $i?",
        'options': ["Option A", "Option B", "Option C", "Option D"],
        'correctAnswer': 0,
        'type': i % 3 == 0 ? "spatial" : i % 3 == 1 ? "numerical" : "verbal",
        'difficulty': i % 3 == 0 ? "hard" : i % 3 == 1 ? "medium" : "easy",
      }
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _selectedOption = _answers[_currentQuestion];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && !_testCompleted) {
        setState(() {
          _timeLeft--;
        });
      } else if (_timeLeft == 0 && !_testCompleted) {
        _handleAutoSubmit();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleAnswerSelect(int optionIndex) {
    setState(() {
      _answers[_currentQuestion] = optionIndex;
      _selectedOption = optionIndex;
    });
  }

  void _handleNextQuestion() {
    if (_currentQuestion < _sampleQuestions.length - 1) {
      final nextQuestion = _currentQuestion + 1;
      setState(() {
        _currentQuestion = nextQuestion;
        _selectedOption = _answers[nextQuestion];
        if (!_visitedQuestions.contains(nextQuestion)) {
          _visitedQuestions.add(nextQuestion);
        }
      });
    }
  }

  void _handlePreviousQuestion() {
    if (_currentQuestion > 0) {
      final prevQuestion = _currentQuestion - 1;
      setState(() {
        _currentQuestion = prevQuestion;
        _selectedOption = _answers[prevQuestion];
        if (!_visitedQuestions.contains(prevQuestion)) {
          _visitedQuestions.add(prevQuestion);
        }
      });
    }
  }

  void _handleQuestionSelect(int index) {
    setState(() {
      _currentQuestion = index;
      _selectedOption = _answers[index];
      if (!_visitedQuestions.contains(index)) {
        _visitedQuestions.add(index);
      }
    });
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _answers.length; i++) {
      if (_answers[i] == _sampleQuestions[i]['correctAnswer']) {
        score += 2;
      }
    }
    return score;
  }

  void _handleAutoSubmit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Time's Up!"),
        content: const Text("Your test time has expired. Submitting your answers..."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitAndNavigate();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleSubmitTest() {
    final answeredCount = _answers.where((answer) => answer != null).length;
    final unansweredCount = _sampleQuestions.length - answeredCount;

    if (unansweredCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Unanswered Questions"),
          content: Text(
            "You have $unansweredCount unanswered question${unansweredCount > 1 ? 's' : ''}. Are you sure you want to submit?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Test'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _submitAndNavigate();
              },
              child: const Text('Submit Anyway'),
            ),
          ],
        ),
      );
    } else {
      _submitAndNavigate();
    }
  }

  void _submitAndNavigate() {
    setState(() {
      _loading = true;
    });

    // Calculate results
    final score = _calculateScore();
    final timeTaken = 45 * 60 - _timeLeft; // Total time - time left
    
    // Cancel timer
    _timer?.cancel();

    // Small delay for better UX
    Future.delayed(const Duration(milliseconds: 800), () {
      // Navigate to result screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IQResultScreen(
            score: score,
            totalQuestions: _sampleQuestions.length,
            answers: _answers,
            questions: _sampleQuestions,
            timeTaken: timeTaken,
          ),
        ),
      );
    });
  }

  int _getProgressPercentage() {
    return ((_currentQuestion + 1) / _sampleQuestions.length * 100).round();
  }

  int _getAnsweredCount() {
    return _answers.where((answer) => answer != null).length;
  }

  // Responsive value function
  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop; // Desktop
    if (screenWidth >= 768) return tablet; // Tablet
    return mobile; // Mobile
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    
    final currentQuestionData = _sampleQuestions[_currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
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
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    height: _responsiveValue(64, 72, 80),
                    child: Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Exit Test?"),
                                content: const Text(
                                    "Are you sure you want to exit? Your progress will be lost."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _timer?.cancel();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Exit',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_back,
                              size: _responsiveValue(24, 26, 28),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Center Title
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'IQ Test',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _responsiveValue(18, 20, 22),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Question ${_currentQuestion + 1} of ${_sampleQuestions.length}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: _responsiveValue(14, 15, 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Timer
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _responsiveValue(12, 14, 16),
                            vertical: _responsiveValue(6, 7, 8),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _formatTime(_timeLeft),
                            style: TextStyle(
                              fontSize: _responsiveValue(16, 17, 18),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== PROGRESS SECTION =====
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE9ECEF),
                      width: 1,
                    ),
                  ),
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: _responsiveValue(12, 14, 16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_getAnsweredCount()} of ${_sampleQuestions.length} answered',
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              color: const Color(0xFF666666),
                            ),
                          ),
                          Text(
                            '${_getProgressPercentage()}%',
                            style: TextStyle(
                              fontSize: _responsiveValue(16, 17, 18),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0072BC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Progress Bar
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9ECEF),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: _getProgressPercentage() / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00C9FF), Color(0xFF0072BC)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== MAIN CONTENT AREA =====
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: _responsiveValue(16, 20, 24)),

                          // ===== QUESTION HEADER =====
                          Row(
                            children: [
                              // Question Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _responsiveValue(16, 18, 20),
                                  vertical: _responsiveValue(8, 9, 10),
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Q${_currentQuestion + 1}',
                                  style: TextStyle(
                                    fontSize: _responsiveValue(16, 17, 18),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: _responsiveValue(12, 14, 16)),
                              
                              // Difficulty Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _responsiveValue(12, 13, 14),
                                  vertical: _responsiveValue(6, 7, 8),
                                ),
                                decoration: BoxDecoration(
                                  color: currentQuestionData['difficulty'] == 'easy'
                                      ? const Color(0xFFF0FFF4)
                                      : currentQuestionData['difficulty'] == 'medium'
                                          ? const Color(0xFFFFFAF0)
                                          : const Color(0xFFFFF5F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: currentQuestionData['difficulty'] == 'easy'
                                        ? const Color(0xFF48BB78)
                                        : currentQuestionData['difficulty'] == 'medium'
                                            ? const Color(0xFFED8936)
                                            : const Color(0xFFF56565),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  (currentQuestionData['difficulty'] as String).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: _responsiveValue(12, 13, 14),
                                    fontWeight: FontWeight.w700,
                                    color: currentQuestionData['difficulty'] == 'easy'
                                        ? const Color(0xFF48BB78)
                                        : currentQuestionData['difficulty'] == 'medium'
                                            ? const Color(0xFFED8936)
                                            : const Color(0xFFF56565),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _responsiveValue(20, 24, 28)),

                          // ===== QUESTION CARD =====
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(_responsiveValue(20, 22, 24)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              currentQuestionData['question'],
                              style: TextStyle(
                                fontSize: _responsiveValue(18, 20, 22),
                                color: const Color(0xFF003366),
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                          SizedBox(height: _responsiveValue(20, 24, 28)),

                          // ===== OPTIONS LIST =====
                          Column(
                            children: (currentQuestionData['options'] as List<String>)
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final option = entry.value;
                              
                              return GestureDetector(
                                onTap: () => _handleAnswerSelect(index),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: _responsiveValue(12, 13, 14)),
                                  padding: EdgeInsets.all(_responsiveValue(16, 17, 18)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedOption == index
                                          ? const Color(0xFF0072BC)
                                          : const Color(0xFFE9ECEF),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Option Letter
                                      Container(
                                        width: _responsiveValue(36, 38, 40),
                                        height: _responsiveValue(36, 38, 40),
                                        decoration: BoxDecoration(
                                          color: _selectedOption == index
                                              ? const Color(0xFF0072BC)
                                              : const Color(0xFFF8F9FA),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: _selectedOption == index
                                                ? const Color(0xFF0072BC)
                                                : const Color(0xFFE9ECEF),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontSize: _responsiveValue(16, 17, 18),
                                              fontWeight: FontWeight.w700,
                                              color: _selectedOption == index
                                                  ? Colors.white
                                                  : const Color(0xFF666666),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: _responsiveValue(16, 17, 18)),
                                      
                                      // Option Text
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: _responsiveValue(16, 17, 18),
                                            color: _selectedOption == index
                                                ? const Color(0xFF0052A2)
                                                : const Color(0xFF333333),
                                            fontWeight: _selectedOption == index
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      
                                      // Check Icon
                                      if (_selectedOption == index)
                                        Icon(
                                          Icons.check_circle,
                                          size: _responsiveValue(24, 25, 26),
                                          color: const Color(0xFF00B09B),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: _responsiveValue(24, 28, 32)),

                          // ===== NAVIGATION BUTTONS =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous Button
                              ElevatedButton(
                                onPressed: _currentQuestion == 0 ? null : _handlePreviousQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0072BC),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _responsiveValue(24, 26, 28),
                                    vertical: _responsiveValue(14, 15, 16),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFF0072BC),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_left,
                                      size: _responsiveValue(20, 21, 22),
                                      color: const Color(0xFF0072BC),
                                    ),
                                    SizedBox(width: _responsiveValue(8, 9, 10)),
                                    Text(
                                      'Previous',
                                      style: TextStyle(
                                        fontSize: _responsiveValue(16, 17, 18),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Next/Submit Button
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _currentQuestion == _sampleQuestions.length - 1
                                        ? [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]
                                        : [const Color(0xFF0072BC), const Color(0xFF0052A2)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: _currentQuestion == _sampleQuestions.length - 1
                                      ? _handleSubmitTest
                                      : _handleNextQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _responsiveValue(24, 26, 28),
                                      vertical: _responsiveValue(14, 15, 16),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _currentQuestion == _sampleQuestions.length - 1
                                            ? 'Submit Test'
                                            : 'Next Question',
                                        style: TextStyle(
                                          fontSize: _responsiveValue(16, 17, 18),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_currentQuestion != _sampleQuestions.length - 1)
                                        Row(
                                          children: [
                                            SizedBox(width: _responsiveValue(8, 9, 10)),
                                            Icon(
                                              Icons.chevron_right,
                                              size: _responsiveValue(20, 21, 22),
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _responsiveValue(20, 24, 28)),
                          
                          // ===== YOUTUBE VIDEO SECTION - UPDATED =====
                          Container(
                            margin: EdgeInsets.only(
                              top: _responsiveValue(20, 24, 28),
                              bottom: 0, // Reduced bottom margin
                            ),
                            width: double.infinity,
                            height: isDesktop ? 360 : (isTablet ? 280 : 220), // Same height as Exam1
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

              // ===== QUESTION PALETTE =====
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(
                      color: Color(0xFFE9ECEF),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: _responsiveValue(12, 14, 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question Palette',
                          style: TextStyle(
                            fontSize: _responsiveValue(16, 17, 18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF003366),
                          ),
                        ),
                        SizedBox(height: _responsiveValue(8, 9, 10)),

                        // Question Grids (3 rows of 10)
                        for (int row = 0; row < 3; row++) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(10, (col) {
                              final index = row * 10 + col;
                              if (index >= _sampleQuestions.length) return Container();
                              
                              return GestureDetector(
                                onTap: () => _handleQuestionSelect(index),
                                child: Container(
                                  width: _responsiveValue(28, 30, 32),
                                  height: _responsiveValue(28, 30, 32),
                                  margin: EdgeInsets.all(_responsiveValue(2, 2.5, 3)),
                                  decoration: BoxDecoration(
                                    color: _getButtonColor(index),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _getBorderColor(index),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: _responsiveValue(12, 13, 14),
                                        fontWeight: FontWeight.w600,
                                        color: _getTextColor(index),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: _responsiveValue(4, 5, 6)),
                        ],

                        // Legend
                        SizedBox(height: _responsiveValue(8, 9, 10)),
                        Wrap(
                          spacing: _responsiveValue(12, 14, 16),
                          runSpacing: _responsiveValue(4, 5, 6),
                          children: [
                            _buildLegend('Current', const Color(0xFF0072BC)),
                            _buildLegend('Answered', const Color(0xFF00B09B)),
                            _buildLegend('Visited', const Color(0xFFE6F2FF)),
                            _buildLegend('Not Visited', const Color(0xFFF8F9FA)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Loading Overlay
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for palette button colors
  Color _getButtonColor(int index) {
    if (index == _currentQuestion) return const Color(0xFF0072BC);
    if (_answers[index] != null) return const Color(0xFF00B09B);
    if (_visitedQuestions.contains(index)) return const Color(0xFFE6F2FF);
    return const Color(0xFFF8F9FA);
  }

  Color _getBorderColor(int index) {
    if (index == _currentQuestion) return const Color(0xFF0072BC);
    if (_answers[index] != null) return const Color(0xFF00B09B);
    if (_visitedQuestions.contains(index)) return const Color(0xFF0072BC);
    return const Color(0xFFE9ECEF);
  }

  Color _getTextColor(int index) {
    if (index == _currentQuestion || _answers[index] != null) {
      return Colors.white;
    }
    return const Color(0xFF666666);
  }

  // Helper Widget: Legend Item
  Widget _buildLegend(String text, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 12 : 14,
          height: isMobile ? 12 : 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: color == const Color(0xFFF8F9FA) 
                  ? const Color(0xFFE9ECEF) 
                  : color,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  // Show URL dialog
  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External Link'),
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
}