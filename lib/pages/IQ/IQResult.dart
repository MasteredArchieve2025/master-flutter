// lib/pages/IQ/IQResult.dart
import 'package:flutter/material.dart';

class IQResultScreen extends StatelessWidget {
  final Map<String, dynamic> testData;
  final Map<String, dynamic> resultData;

  const IQResultScreen({
    super.key,
    required this.testData,
    required this.resultData,
  });

  // Direct access to summary and data
  Map<String, dynamic> get _summary {
    if (resultData.containsKey('summary') && resultData['summary'] is Map) {
      return Map<String, dynamic>.from(resultData['summary']);
    }
    return {};
  }

  Map<String, dynamic> get _data {
    if (resultData.containsKey('data') && resultData['data'] is Map) {
      return Map<String, dynamic>.from(resultData['data']);
    }
    return resultData;
  }

  // Use the actual values from the API response
  int get totalQuestions {
    // First try from summary (this has the correct value: 5)
    if (_summary.containsKey('totalQuestions')) {
      final val = _summary['totalQuestions'];
      if (val != null) {
        debugPrint('✅ totalQuestions from summary.totalQuestions: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 5;
      }
    }
    
    // Then try from data
    if (_data.containsKey('total_questions')) {
      final val = _data['total_questions'];
      if (val != null) {
        debugPrint('✅ totalQuestions from data.total_questions: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 5;
      }
    }
    
    // Fallback to testData
    if (testData.containsKey('total_questions')) {
      final val = testData['total_questions'];
      if (val != null) {
        debugPrint('⚠️ totalQuestions from testData: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 5;
      }
    }
    
    debugPrint('❌ totalQuestions default: 5');
    return 5;
  }

  int get pointsPerQuestion {
    if (testData.containsKey('points_per_question')) {
      final val = testData['points_per_question'];
      if (val != null) {
        return val is int ? val : int.tryParse(val.toString()) ?? 2;
      }
    }
    return 2;
  }

  int get maxScore {
    // Try from data.max_score first (this has value 10)
    if (_data.containsKey('max_score')) {
      final val = _data['max_score'];
      if (val != null) {
        debugPrint('✅ maxScore from data.max_score: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 10;
      }
    }
    
    // Then from summary.maxScore
    if (_summary.containsKey('maxScore')) {
      final val = _summary['maxScore'];
      if (val != null) {
        debugPrint('✅ maxScore from summary.maxScore: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 10;
      }
    }
    
    // Calculate as fallback
    return totalQuestions * pointsPerQuestion;
  }

  int get score {
    // Try from data.total_score (this has value 6)
    if (_data.containsKey('total_score')) {
      final val = _data['total_score'];
      if (val != null) {
        debugPrint('✅ score from data.total_score: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    // Try from summary.score
    if (_summary.containsKey('score')) {
      final val = _summary['score'];
      if (val != null) {
        debugPrint('✅ score from summary.score: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    debugPrint('❌ score default: 0');
    return 0;
  }

  int get correctAnswers {
    // Try from summary.correctAnswers (THIS IS WHERE YOUR DATA IS)
    if (_summary.containsKey('correctAnswers')) {
      final val = _summary['correctAnswers'];
      if (val != null) {
        debugPrint('✅ correctAnswers from summary.correctAnswers: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    // Try from data.correct_answers
    if (_data.containsKey('correct_answers')) {
      final val = _data['correct_answers'];
      if (val != null) {
        debugPrint('✅ correctAnswers from data.correct_answers: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    debugPrint('❌ correctAnswers default: 0');
    return 0;
  }

  int get incorrectAnswers {
    // Try from summary.wrongAnswers (THIS IS WHERE YOUR DATA IS)
    if (_summary.containsKey('wrongAnswers')) {
      final val = _summary['wrongAnswers'];
      if (val != null) {
        debugPrint('✅ incorrectAnswers from summary.wrongAnswers: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    // Try from data.wrong_answers
    if (_data.containsKey('wrong_answers')) {
      final val = _data['wrong_answers'];
      if (val != null) {
        debugPrint('✅ incorrectAnswers from data.wrong_answers: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    debugPrint('❌ incorrectAnswers default: 0');
    return 0;
  }

  int get unanswered {
    // Try from summary.unanswered (THIS IS WHERE YOUR DATA IS)
    if (_summary.containsKey('unanswered')) {
      final val = _summary['unanswered'];
      if (val != null) {
        debugPrint('✅ unanswered from summary.unanswered: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    // Try from data.unanswered
    if (_data.containsKey('unanswered')) {
      final val = _data['unanswered'];
      if (val != null) {
        debugPrint('✅ unanswered from data.unanswered: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    debugPrint('❌ unanswered default: 0');
    return 0;
  }

  int get timeTaken {
    // Try from data.time_taken
    if (_data.containsKey('time_taken')) {
      final val = _data['time_taken'];
      if (val != null) {
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    // Try from summary.timeTaken
    if (_summary.containsKey('timeTaken')) {
      final val = _summary['timeTaken'];
      if (val != null) {
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    return 0;
  }

  int get iqScore {
    // Try from data.iq_score (this has value 109)
    if (_data.containsKey('iq_score')) {
      final val = _data['iq_score'];
      if (val != null) {
        debugPrint('✅ iqScore from data.iq_score: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    // Try from summary.iqScore
    if (_summary.containsKey('iqScore')) {
      final val = _summary['iqScore'];
      if (val != null) {
        debugPrint('✅ iqScore from summary.iqScore: $val');
        return val is int ? val : int.tryParse(val.toString()) ?? 0;
      }
    }
    
    debugPrint('❌ iqScore default: 0');
    return 0;
  }

  double get percentage {
    // Try from data.percentage (this has value "60.00")
    if (_data.containsKey('percentage')) {
      final val = _data['percentage'];
      if (val != null) {
        debugPrint('✅ percentage from data.percentage: $val');
        if (val is double) return val;
        if (val is int) return val.toDouble();
        if (val is String) {
          return double.tryParse(val) ?? 0.0;
        }
      }
    }
    
    // Try from summary.percentage
    if (_summary.containsKey('percentage')) {
      final val = _summary['percentage'];
      if (val != null) {
        debugPrint('✅ percentage from summary.percentage: $val');
        if (val is double) return val;
        if (val is int) return val.toDouble();
        if (val is String) {
          return double.tryParse(val) ?? 0.0;
        }
      }
    }
    
    // Calculate from score and maxScore
    if (maxScore > 0) {
      final calcPercentage = (score / maxScore) * 100;
      debugPrint('✅ percentage calculated: $calcPercentage');
      return calcPercentage;
    }
    
    debugPrint('❌ percentage default: 0.0');
    return 0.0;
  }

  String get performance {
    // Try from data.performance_level (this has value "Above Average")
    if (_data.containsKey('performance_level')) {
      final val = _data['performance_level'];
      if (val != null) {
        debugPrint('✅ performance from data.performance_level: $val');
        return val.toString();
      }
    }
    
    // Try from summary.performanceLevel
    if (_summary.containsKey('performanceLevel')) {
      final val = _summary['performanceLevel'];
      if (val != null) {
        debugPrint('✅ performance from summary.performanceLevel: $val');
        return val.toString();
      }
    }
    
    // Calculate from percentage
    if (percentage >= 90) return "Exceptional";
    if (percentage >= 75) return "Excellent";
    if (percentage >= 60) return "Above Average";
    if (percentage >= 40) return "Average";
    return "Below Average";
  }

  Map<String, dynamic> get categoryScores {
    if (_data.containsKey('category_scores') && _data['category_scores'] is Map) {
      final catScores = Map<String, dynamic>.from(_data['category_scores']);
      debugPrint('✅ categoryScores found: ${catScores.keys}');
      return catScores;
    }
    debugPrint('❌ No category scores found');
    return {};
  }

  Color getPerformanceColor(String performance) {
    switch (performance) {
      case "Exceptional":
        return const Color(0xFF4CAF50);
      case "Excellent":
        return const Color(0xFF2196F3);
      case "Above Average":
        return const Color(0xFF00BCD4);
      case "Average":
        return const Color(0xFFFF9800);
      case "Below Average":
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF0072BC);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _shareResults(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Results'),
          content: Text(
            'I scored $score/$maxScore (${percentage.round()}%) on the IQ Test! '
            '${iqScore > 0 ? 'IQ Score: $iqScore. ' : ''}Can you beat my score?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _retakeTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                Navigator.pop(context); // Go back to IQ3
                Navigator.pop(context); // Go back to IQ2
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Retake'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force re-evaluation of getters by accessing them
    final int totalQ = totalQuestions;
    final int correct = correctAnswers;
    final int incorrect = incorrectAnswers;
    final int unans = unanswered;
    final int scoreVal = score;
    final int maxScoreVal = maxScore;
    final double percentVal = percentage;
    final int iqScoreVal = iqScore;
    final String perfVal = performance;
    final Map<String, dynamic> catScores = categoryScores;

    // Debug prints to see what's being extracted
    debugPrint('\n========== IQ RESULT DEBUG ==========');
    debugPrint('ResultData keys: ${resultData.keys}');
    debugPrint('Summary keys: ${_summary.keys}');
    debugPrint('Data keys: ${_data.keys}');
    debugPrint('-----------------------------------');
    debugPrint('Total Questions: $totalQ');
    debugPrint('Correct Answers: $correct');
    debugPrint('Incorrect Answers: $incorrect');
    debugPrint('Unanswered: $unans');
    debugPrint('Score: $scoreVal');
    debugPrint('Max Score: $maxScoreVal');
    debugPrint('Percentage: $percentVal');
    debugPrint('IQ Score: $iqScoreVal');
    debugPrint('Performance: $perfVal');
    debugPrint('Category Scores: ${catScores.keys}');
    debugPrint('=====================================\n');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
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
                    GestureDetector(
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          testData['title'] ?? 'Test Results',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
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
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    // Score Card
                    Container(
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
                          const Text(
                            'Your Score',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$scoreVal/$maxScoreVal',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              perfVal,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: getPerformanceColor(perfVal),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${percentVal.round()}% Accuracy',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          if (iqScoreVal > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'IQ Score: $iqScoreVal',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Grid
                    Container(
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
                            'Detailed Statistics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Correct',
                                  '$correct',
                                  Icons.check_circle,
                                  const Color(0xFF4CAF50),
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'Incorrect',
                                  '$incorrect',
                                  Icons.cancel,
                                  const Color(0xFFF44336),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Unanswered',
                                  '$unans',
                                  Icons.help_outline,
                                  const Color(0xFFFF9800),
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'Time Taken',
                                  _formatTime(timeTaken),
                                  Icons.timer,
                                  const Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Performance
                    if (catScores.isNotEmpty) ...[
                      Container(
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
                            ...catScores.entries.map((entry) {
                              final category = entry.key;
                              final Map<String, dynamic> data = entry.value is Map 
                                  ? Map<String, dynamic>.from(entry.value) 
                                  : {'total': 0, 'correct': 0};
                              final total = data['total'] is int 
                                  ? data['total'] as int 
                                  : (data['total'] is num ? (data['total'] as num).toInt() : 0);
                              final correct = data['correct'] is int 
                                  ? data['correct'] as int 
                                  : (data['correct'] is num ? (data['correct'] as num).toInt() : 0);
                              final catPercentage = total > 0 ? (correct / total) * 100 : 0.0;

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
                                                '$correct/$total correct',
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
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Performance Analysis
                    Container(
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
                            'Performance Analysis',
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
                            'You answered $correct questions correctly',
                          ),
                          const SizedBox(height: 14),
                          _buildAnalysisRow(
                            Icons.timer,
                            const Color(0xFFFF9800),
                            'Average time per question: '
                            '${totalQ > 0 ? (timeTaken / totalQ).round() : 0} seconds',
                          ),
                          const SizedBox(height: 14),
                          _buildAnalysisRow(
                            Icons.emoji_events,
                            const Color(0xFFFFC107),
                            'Your performance is $perfVal compared to average',
                          ),
                          if (iqScoreVal > 0) ...[
                            const SizedBox(height: 14),
                            _buildAnalysisRow(
                              Icons.psychology,
                              const Color(0xFF0072BC),
                              'Your estimated IQ score is $iqScoreVal',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
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
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
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
            style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }
}