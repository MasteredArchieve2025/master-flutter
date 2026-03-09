// lib/pages/IQ/IQ3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/baseurl.dart';
import './IQResult.dart';

class IQ3Screen extends StatefulWidget {
  final Map<String, dynamic> testData;
  final String sessionToken;
  final Map<String, dynamic> questionsData;

  const IQ3Screen({
    super.key,
    required this.testData,
    required this.sessionToken,
    required this.questionsData,
  });

  @override
  State<IQ3Screen> createState() => _IQ3ScreenState();
}

class _IQ3ScreenState extends State<IQ3Screen> {
  int _currentQuestion = 0;
  int? _selectedOption;
  final Map<int, int> _answers = {};
  int _timeLeft = 0;
  bool _timerActive = true;
  Timer? _timer;
  bool _isSubmitting = false;
  final List<int> _visitedQuestions = [0];

  late List<dynamic> _questions;
  late int _totalQuestions;   // ✅ FIX: was undefined in original — declared here
  late int _timeLimitMinutes;

  @override
  void initState() {
    super.initState();
    _initializeTestData();
    _startTimer();
  }

  void _initializeTestData() {
    _timeLimitMinutes = widget.testData['time_limit_minutes'] ?? 45;
    _timeLeft = _timeLimitMinutes * 60;

    // ✅ Parse questions from: { success, data: { questions: [...] } }
    final raw = widget.questionsData;
    if (raw['success'] == true && raw['data'] != null) {
      final data = raw['data'];
      if (data is Map && data['questions'] != null) {
        _questions = List<dynamic>.from(data['questions']);
      } else if (data is List) {
        _questions = List<dynamic>.from(data);
      } else {
        _questions = [];
      }
    } else if (raw['questions'] != null) {
      _questions = List<dynamic>.from(raw['questions']);
    } else {
      _questions = [];
    }

    _totalQuestions = _questions.length;
    debugPrint('✅ Loaded $_totalQuestions questions'); // ✅ FIX: was _totalQuestions (undefined)
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft > 0 && _timerActive) {
        setState(() => _timeLeft--);
      } else if (_timeLeft == 0 && _timerActive) {
        _timerActive = false;
        _submitTest(autoSubmit: true);
      }
    });
  }

  // ✅ FIX: Backend expects camelCase body keys: questionId, selectedOption, timeSpent
  Future<void> _saveAnswer(int questionIndex, int selectedOption) async {
    try {
      final questionId = _questions[questionIndex]['id'];
      final int timeSpent = (_timeLimitMinutes * 60) - _timeLeft;

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/iq/sessions/${widget.sessionToken}/answer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'questionId': questionId,       // ✅ was: question_id
          'selectedOption': selectedOption, // ✅ was: selected_option
          'timeSpent': timeSpent,          // ✅ was: missing entirely
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('⚠️ Save answer failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ saveAnswer error: $e');
    }
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _selectedOption = optionIndex;
      _answers[_currentQuestion] = optionIndex;
    });
    _saveAnswer(_currentQuestion, optionIndex);
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      final next = _currentQuestion + 1;
      setState(() {
        _currentQuestion = next;
        _selectedOption = _answers[next];
        if (!_visitedQuestions.contains(next)) _visitedQuestions.add(next);
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      final prev = _currentQuestion - 1;
      setState(() {
        _currentQuestion = prev;
        _selectedOption = _answers[prev];
        if (!_visitedQuestions.contains(prev)) _visitedQuestions.add(prev);
      });
    }
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestion = index;
      _selectedOption = _answers[index];
      if (!_visitedQuestions.contains(index)) _visitedQuestions.add(index);
    });
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Test?"),
        content: const Text("Are you sure? Your progress will be lost."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest({bool autoSubmit = false}) async {
    if (_isSubmitting) return;

    if (!autoSubmit && _answers.length < _questions.length) {
      _showConfirmSubmitDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _timerActive = false;
    });

    try {
      final int timeSpent = (_timeLimitMinutes * 60) - _timeLeft;
      debugPrint('▶️ POST submit | token=${widget.sessionToken} | timeSpent=$timeSpent');

      // ✅ FIX: Pass timeSpent in body — backend reads req.body.timeSpent
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/iq/sessions/${widget.sessionToken}/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'timeSpent': timeSpent}),
      );

      debugPrint('📥 Submit status: ${response.statusCode}');
      debugPrint('📥 Submit body:   ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> resp = jsonDecode(response.body);

        if (resp['success'] == true && mounted) {
          // ✅ Backend returns: { success, data: { id, ... }, summary: { ... } }
          final data = resp['data'];
          final int? resultId = data is Map ? (data['id'] as int?) : null;

          if (resultId != null) {
            await _fetchResult(resultId);
          } else {
            // Fallback: build result from summary block
            _goToResultScreen(resp);
          }
        } else {
          _showErrorDialog('Submit failed: ${resp['message'] ?? 'Unknown error'}');
        }
      } else {
        _showErrorDialog('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Submit error: $e');
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  Future<void> _fetchResult(int resultId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/iq/results/$resultId'),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          final resultData = resp['data'] ?? resp;
          _navigateToResult(resultData);
        } else {
          _showErrorDialog('Failed to get results: ${resp['message']}');
        }
      } else {
        _showErrorDialog('Results HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showErrorDialog('Error fetching results: $e');
    }
  }

  // Builds result map from the submit response summary block
  void _goToResultScreen(Map<String, dynamic> resp) {
    setState(() => _isSubmitting = false);
    final summary = resp['summary'] ?? {};
    final data = resp['data'] ?? {};

    final resultData = <String, dynamic>{
      'total_score':      summary['score'] ?? data['total_score'] ?? 0,
      'max_score':        summary['maxScore'] ?? data['max_score'] ?? 0,
      'correct_answers':  summary['correctAnswers'] ?? data['correct_answers'] ?? 0,
      'wrong_answers':    summary['wrongAnswers'] ?? data['wrong_answers'] ?? 0,
      'unanswered':       summary['unanswered'] ?? data['unanswered'] ?? 0,
      'percentage':       (summary['percentage'] ?? data['percentage'] ?? 0.0).toDouble(),
      'iq_score':         summary['iqScore'] ?? data['iq_score'] ?? 0,
      'performance_level': summary['performanceLevel'] ?? data['performance_level'] ?? '',
      'time_taken':       summary['timeTaken'] ?? data['time_taken'] ?? 0,
    };

    _navigateToResult(resultData);
  }

  void _navigateToResult(Map<String, dynamic> resultData) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IQResultScreen(
          testData: widget.testData,
          resultData: resultData,
        ),
      ),
    );
  }

  void _showConfirmSubmitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Submit Test?"),
        content: Text(
          'You answered ${_answers.length} of ${_questions.length} questions. '
          'Unanswered will be marked wrong. Submit anyway?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Review')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTest(autoSubmit: true);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double _rv(double m, double t, double d) {
    final sw = MediaQuery.of(context).size.width;
    if (sw >= 1024) return d;
    if (sw >= 768) return t;
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 1024;
    final double hp = _rv(16, 24, 32);
    final double maxW = isDesktop ? 1400 : double.infinity;

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0052A2),
          title: const Text('IQ Test', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('No questions available for this test.',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    final q = _questions[_currentQuestion];
    final List<dynamic> options = q['options'] ?? [];

    // ✅ FIX: was q['question'] — backend returns 'question_text'
    final String questionText = q['question_text'] ?? q['question'] ?? 'No question text';
    final String difficulty = (q['difficulty'] ?? 'medium').toString().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                color: const Color(0xFF0052A2),
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: _rv(64, 72, 80),
                    child: Row(
                      children: [
                        SizedBox(width: hp),
                        GestureDetector(
                          onTap: _showExitConfirmation,
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('IQ Test',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _rv(18, 20, 22),
                                        fontWeight: FontWeight.w700)),
                                Text(
                                  'Question ${_currentQuestion + 1} of ${_questions.length}',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: _rv(13, 14, 15)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: hp),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(
                            _formatTime(_timeLeft),
                            style: TextStyle(
                                fontSize: _rv(15, 16, 17),
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Progress Bar ────────────────────────────────────────
              Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hp, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_answers.length} of ${_questions.length} answered',
                              style: TextStyle(
                                  fontSize: _rv(13, 14, 15), color: const Color(0xFF666666))),
                          Text(
                              '${((_currentQuestion + 1) / _questions.length * 100).round()}%',
                              style: TextStyle(
                                  fontSize: _rv(15, 16, 17),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0072BC))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (_currentQuestion + 1) / _questions.length,
                          backgroundColor: const Color(0xFFE9ECEF),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0072BC)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE9ECEF)),

              // ── Questions ────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Padding(
                        padding: EdgeInsets.all(hp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: _rv(16, 20, 24)),

                            // Q tag + difficulty
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)]),
                                    borderRadius: BorderRadius.circular(16)),
                                child: Text('Q${_currentQuestion + 1}',
                                    style: TextStyle(
                                        fontSize: _rv(15, 16, 17),
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF0F7FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF0072BC))),
                                child: Text(difficulty,
                                    style: TextStyle(
                                        fontSize: _rv(11, 12, 13),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0072BC))),
                              ),
                            ]),

                            SizedBox(height: _rv(16, 20, 24)),

                            // Question text card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(_rv(18, 20, 22)),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ]),
                              child: Text(
                                questionText,
                                style: TextStyle(
                                    fontSize: _rv(17, 19, 21),
                                    color: const Color(0xFF003366),
                                    fontWeight: FontWeight.w600,
                                    height: 1.5),
                              ),
                            ),

                            SizedBox(height: _rv(16, 20, 24)),

                            // Options
                            ...List.generate(options.length, (i) {
                              final opt = options[i]?.toString() ?? '';
                              final selected = _selectedOption == i;
                              return GestureDetector(
                                onTap: () => _selectOption(i),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: _rv(10, 12, 14)),
                                  padding: EdgeInsets.all(_rv(14, 16, 18)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: selected
                                            ? const Color(0xFF0072BC)
                                            : const Color(0xFFE9ECEF),
                                        width: 2),
                                  ),
                                  child: Row(children: [
                                    // Letter circle
                                    Container(
                                      width: _rv(34, 36, 38),
                                      height: _rv(34, 36, 38),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFF0072BC)
                                            : const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                            color: selected
                                                ? const Color(0xFF0072BC)
                                                : const Color(0xFFE9ECEF),
                                            width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + i),
                                          style: TextStyle(
                                              fontSize: _rv(14, 15, 16),
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? Colors.white
                                                  : const Color(0xFF666666)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: _rv(14, 16, 18)),
                                    Expanded(
                                      child: Text(opt,
                                          style: TextStyle(
                                              fontSize: _rv(15, 16, 17),
                                              color: selected
                                                  ? const Color(0xFF0052A2)
                                                  : const Color(0xFF333333),
                                              fontWeight: selected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal)),
                                    ),
                                    if (selected)
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFF00B09B), size: 22),
                                  ]),
                                ),
                              );
                            }),

                            SizedBox(height: _rv(20, 24, 28)),

                            // Navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Previous
                                OutlinedButton.icon(
                                  onPressed: _currentQuestion == 0 ? null : _previousQuestion,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0072BC),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: _rv(20, 24, 28), vertical: _rv(12, 14, 16)),
                                    side: const BorderSide(color: Color(0xFF0072BC), width: 2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.chevron_left),
                                  label: const Text('Previous',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                ),

                                // Next / Submit
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _currentQuestion == _questions.length - 1
                                          ? [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]
                                          : [const Color(0xFF0072BC), const Color(0xFF0052A2)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _currentQuestion == _questions.length - 1
                                        ? () => _submitTest()
                                        : _nextQuestion,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: _rv(20, 24, 28), vertical: _rv(12, 14, 16)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text(
                                        _currentQuestion == _questions.length - 1
                                            ? 'Submit Test'
                                            : 'Next',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      if (_currentQuestion != _questions.length - 1)
                                        const Icon(Icons.chevron_right, size: 20),
                                    ]),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: _rv(16, 20, 24)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Question Palette ─────────────────────────────────────
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    const Divider(height: 1, color: Color(0xFFE9ECEF)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Question Palette',
                              style: TextStyle(
                                  fontSize: _rv(14, 15, 16),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF003366))),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(_questions.length, (i) {
                              return GestureDetector(
                                onTap: () => _goToQuestion(i),
                                child: Container(
                                  width: _rv(34, 36, 38),
                                  height: _rv(34, 36, 38),
                                  decoration: BoxDecoration(
                                    color: _btnColor(i),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _btnBorder(i)),
                                  ),
                                  child: Center(
                                    child: Text('${i + 1}',
                                        style: TextStyle(
                                            fontSize: _rv(11, 12, 13),
                                            fontWeight: FontWeight.w600,
                                            color: _btnText(i))),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 14,
                            runSpacing: 4,
                            children: [
                              _legend('Current', const Color(0xFF0072BC)),
                              _legend('Answered', const Color(0xFF00B09B)),
                              _legend('Visited', const Color(0xFFE6F2FF)),
                              _legend('Not Visited', const Color(0xFFF8F9FA)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Submitting overlay ───────────────────────────────────────
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Submitting...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _btnColor(int i) {
    if (i == _currentQuestion) return const Color(0xFF0072BC);
    if (_answers.containsKey(i)) return const Color(0xFF00B09B);
    if (_visitedQuestions.contains(i)) return const Color(0xFFE6F2FF);
    return const Color(0xFFF8F9FA);
  }

  Color _btnBorder(int i) {
    if (i == _currentQuestion) return const Color(0xFF0072BC);
    if (_answers.containsKey(i)) return const Color(0xFF00B09B);
    if (_visitedQuestions.contains(i)) return const Color(0xFF0072BC);
    return const Color(0xFFE9ECEF);
  }

  Color _btnText(int i) {
    if (i == _currentQuestion || _answers.containsKey(i)) return Colors.white;
    return const Color(0xFF666666);
  }

  Widget _legend(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: color == const Color(0xFFF8F9FA)
                  ? const Color(0xFFE9ECEF)
                  : color),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
    ]);
  }
}