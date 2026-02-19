// lib/pages/IQ/Iq_result.dart
import 'package:flutter/material.dart';

class IQResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<int?> answers;
  final List<Map<String, dynamic>> questions;
  final int timeTaken;

  const IQResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.questions,
    required this.timeTaken,
  });

  int get totalScore => totalQuestions * 2;
  double get percentage => (score / totalScore) * 100;
  int get correctAnswers => score ~/ 2;

  @override
  Widget build(BuildContext context) {
    final iqScore = _calculateIQ();
    final performance = _getPerformance();
    final categoryScores = _calculateCategoryScores();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    // IQ Score Card
                    _buildIQCard(iqScore, performance),
                    const SizedBox(height: 20),
                    
                    // Score Breakdown
                    _buildScoreCard(),
                    const SizedBox(height: 20),
                    
                    // Category Performance
                    _buildCategoryCard(categoryScores),
                    const SizedBox(height: 20),
                    
                    // Detailed Analysis
                    _buildAnalysisCard(performance),
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Helper Methods =====

  int _calculateIQ() {
    // Simplified IQ calculation
    return (85 + (percentage / 100) * 40).floor();
  }

  String _getPerformance() {
    if (percentage >= 90) return "Exceptional";
    if (percentage >= 75) return "Excellent";
    if (percentage >= 60) return "Above Average";
    if (percentage >= 40) return "Average";
    return "Below Average";
  }

  Color _getPerformanceColor(String performance) {
    switch (performance) {
      case "Exceptional": return const Color(0xFF4CAF50);
      case "Excellent": return const Color(0xFF2196F3);
      case "Above Average": return const Color(0xFF00BCD4);
      case "Average": return const Color(0xFFFF9800);
      case "Below Average": return const Color(0xFFF44336);
      default: return const Color(0xFF0072BC);
    }
  }

  Map<String, Map<String, int>> _calculateCategoryScores() {
    final categories = {
      'numerical': {'correct': 0, 'total': 0},
      'verbal': {'correct': 0, 'total': 0},
      'logical': {'correct': 0, 'total': 0},
      'spatial': {'correct': 0, 'total': 0},
    };

    for (int i = 0; i < questions.length; i++) {
      final type = questions[i]['type'] as String;
      categories[type]!['total'] = categories[type]!['total']! + 1;
      if (answers[i] == questions[i]['correctAnswer']) {
        categories[type]!['correct'] = categories[type]!['correct']! + 1;
      }
    }

    return categories;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _shareResults(BuildContext context) {
    // Simplified share - show a dialog instead
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Results'),
        content: Text(
          'I scored $score/$totalScore (${_calculateIQ()} IQ) on the IQ Test! Can you beat my score?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _retakeTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retake Test'),
        content: const Text('Are you sure you want to retake the test?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to test list
            },
            child: const Text(
              'Retake',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Widget Builders =====

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0052A2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Title
            Expanded(
              child: Center(
                child: Text(
                  'Test Results',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            
            // Share Button
            GestureDetector(
              onTap: () => _shareResults(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.share,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIQCard(int iqScore, String performance) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0072BC), Color(0xFF0052A2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072BC).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            'Your IQ Score',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            '$iqScore',
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          // Performance Badge
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              performance,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _getPerformanceColor(performance),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Based on your performance across $totalQuestions questions',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Score Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 20),
          
          // Score Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreItem('$score/$totalScore', 'Total Score'),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE9ECEF),
              ),
              _buildScoreItem('$correctAnswers/$totalQuestions', 'Correct Answers'),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE9ECEF),
              ),
              _buildScoreItem(_formatTime(timeTaken), 'Time Taken'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Progress Circle
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE9ECEF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0072BC)),
                    ),
                  ),
                  Text(
                    '${percentage.round()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0072BC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Accuracy',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0072BC),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, Map<String, int>> categoryScores) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Performance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 20),
          
          ...categoryScores.entries.map((entry) {
            final category = entry.key;
            final data = entry.value;
            final catPercentage = data['total']! > 0 
                ? (data['correct']! / data['total']!) * 100 
                : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category[0].toUpperCase() + category.substring(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${data['correct']}/${data['total']} correct',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9ECEF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: catPercentage / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0072BC),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 35,
                              child: Text(
                                '${catPercentage.round()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0072BC),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String performance) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildAnalysisRow(
            Icons.check_circle,
            const Color(0xFF4CAF50),
            'You answered $correctAnswers questions correctly',
          ),
          const SizedBox(height: 14),
          
          _buildAnalysisRow(
            Icons.access_time,
            const Color(0xFFFF9800),
            'Average time per question: ${(timeTaken / totalQuestions).round()} seconds',
          ),
          const SizedBox(height: 14),
          
          _buildAnalysisRow(
            Icons.emoji_events,
            const Color(0xFFFFC107),
            'Your performance is $performance compared to average',
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Retake Button
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF416C).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _retakeTest(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Retake Test',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Home Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0072BC),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Color(0xFF0072BC),
                  width: 2,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 20),
                SizedBox(width: 8),
                Text(
                  'Back to Tests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}