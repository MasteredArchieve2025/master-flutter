// lib/pages/IQ/IQ2.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../api/baseurl.dart';
import './Iq3.dart';

class IQ2Screen extends StatefulWidget {
  final Map<String, dynamic> testData;

  const IQ2Screen({super.key, required this.testData});

  @override
  State<IQ2Screen> createState() => _IQ2ScreenState();
}

class _IQ2ScreenState extends State<IQ2Screen> {
  bool _modalVisible = false;
  int _timeLeft = 0;
  bool _testStarted = false;
  bool _timerActive = false;
  Timer? _timer;

  late Map<String, dynamic> _testData;
  bool _isStarting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeTestData();
  }

  void _initializeTestData() {
    _testData = widget.testData;
    final int timeLimitMinutes = _testData['time_limit_minutes'] ?? 45;
    _timeLeft = timeLimitMinutes * 60;
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && _timerActive) {
        setState(() => _timeLeft--);
      } else if (_timeLeft == 0 && _timerActive) {
        _timerActive = false;
        _showTimeUpAlert();
      }
    });
  }

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

  // ✅ FIX: Accept both 200 (resume existing) and 201 (new session created)
  Future<void> _startTestSession() async {
    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Starting test session for test ID: ${_testData['id']}');

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/iq/sessions/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'testId': _testData['id'],
          'userId': 1, // Replace with actual user ID from auth
        }),
      );

      debugPrint('Session start response status: ${response.statusCode}');
      debugPrint('Session start response body: ${response.body}');

      // ✅ FIX: Backend returns 201 for new session, 200 for resumed session
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // ✅ FIX: Backend returns sessionToken at top level (not inside data)
          final String sessionToken =
              responseData['sessionToken']?.toString() ?? '';

          if (sessionToken.isNotEmpty) {
            debugPrint('Session token obtained: $sessionToken');
            await _getSessionQuestions(sessionToken);
          } else {
            setState(() {
              _errorMessage = 'No session token received';
              _isStarting = false;
            });
          }
        } else {
          setState(() {
            _errorMessage =
                responseData['message'] ?? 'Failed to start session';
            _isStarting = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to start session: ${response.statusCode}';
          _isStarting = false;
        });
      }
    } catch (e) {
      debugPrint('Error starting session: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isStarting = false;
      });
    }
  }

  Future<void> _getSessionQuestions(String sessionToken) async {
    try {
      debugPrint('Fetching questions for session: $sessionToken');

      final response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/iq/sessions/$sessionToken/questions'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Questions response status: ${response.statusCode}');

      setState(() => _isStarting = false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && mounted) {
          setState(() {
            _modalVisible = false;
            _testStarted = true;
            _timerActive = true;
          });

          _startTimer();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IQ3Screen(
                testData: _testData,
                sessionToken: sessionToken,
                questionsData: responseData,
              ),
            ),
          );
        } else {
          _showErrorDialog(
              'Failed to load questions: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        _showErrorDialog(
            'Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      setState(() => _isStarting = false);
      _showErrorDialog('Error loading questions: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startTest() => _startTestSession();

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Test?"),
        content:
            const Text("If you exit now, your progress will not be saved."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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

  double _scale(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return size * 1.2;
    if (screenWidth >= 768) return size * 1.1;
    return size;
  }

  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop;
    if (screenWidth >= 768) return tablet;
    return mobile;
  }

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
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    final String testTitle = _testData['title'] ?? 'IQ Test';
    final int totalQuestions = _testData['total_questions'] ?? 0;
    final int timeLimitMinutes = _testData['time_limit_minutes'] ?? 45;
    final int pointsPerQuestion = _testData['points_per_question'] ?? 2;
    final int negativeMarking = _testData['negative_marking'] ?? 0;
    final String difficultyLevel = _testData['difficulty_level'] ?? 'medium';
    final String description = _testData['description'] ?? '';
    final String instructions = _testData['instructions'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
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
                  padding:
                      EdgeInsets.symmetric(horizontal: horizontalPadding),
                  height: _responsiveValue(52, 60, 70),
                  child: Row(
                    children: [
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
                      Expanded(
                        child: Center(
                          child: Text(
                            testTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _responsiveValue(17, 22, 24),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: _scale(40)),
                    ],
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: _responsiveValue(20, 30, 40)),

                          // Instructions Card
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  _responsiveValue(16, 20, 24)),
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
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0072BC),
                                        Color(0xFF0052A2)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                          _responsiveValue(16, 20, 24)),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: _responsiveValue(18, 22, 26),
                                    horizontal: _responsiveValue(20, 24, 28),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Test Instructions',
                                        style: TextStyle(
                                          fontSize:
                                              _responsiveValue(20, 24, 28),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: _scale(8)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          difficultyLevel.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Card Body
                                Padding(
                                  padding: EdgeInsets.all(
                                      _responsiveValue(20, 28, 32)),
                                  child: Column(
                                    children: [
                                      if (description.isNotEmpty) ...[
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize:
                                                _responsiveValue(16, 18, 20),
                                            color: const Color(0xFF333333),
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                            height: _responsiveValue(
                                                20, 28, 32)),
                                      ],

                                      if (instructions.isNotEmpty) ...[
                                        Container(
                                          padding: EdgeInsets.all(
                                              _responsiveValue(12, 16, 20)),
                                          decoration: BoxDecoration(
                                            color:
                                                const Color(0xFFF0F7FF),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    _responsiveValue(
                                                        8, 12, 16)),
                                          ),
                                          child: Text(
                                            instructions,
                                            style: TextStyle(
                                              fontSize: _responsiveValue(
                                                  14, 16, 18),
                                              color:
                                                  const Color(0xFF0052A2),
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                            height: _responsiveValue(
                                                20, 28, 32)),
                                      ],

                                      // Info Grid
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final double infoCardWidth =
                                              isMobile
                                                  ? (constraints.maxWidth -
                                                          _scale(12)) /
                                                      2
                                                  : (constraints.maxWidth -
                                                          _scale(20) * 3) /
                                                      4;

                                          return Wrap(
                                            spacing: _scale(
                                                isMobile ? 12 : 20),
                                            runSpacing: _scale(
                                                isMobile ? 12 : 20),
                                            children: [
                                              _buildInfoCard(
                                                icon: Icons.description,
                                                title: 'Questions',
                                                value:
                                                    totalQuestions.toString(),
                                                label: 'total',
                                                width: infoCardWidth,
                                              ),
                                              _buildInfoCard(
                                                icon: Icons.timer,
                                                title: 'Time Limit',
                                                value: timeLimitMinutes
                                                    .toString(),
                                                label: 'minutes',
                                                width: infoCardWidth,
                                              ),
                                              _buildInfoCard(
                                                icon: Icons.emoji_events,
                                                title: 'Points',
                                                value:
                                                    '+$pointsPerQuestion',
                                                label: 'per correct',
                                                width: infoCardWidth,
                                              ),
                                              _buildInfoCard(
                                                icon: Icons.warning,
                                                title: 'Negative',
                                                value: negativeMarking > 0
                                                    ? '-$negativeMarking'
                                                    : 'No',
                                                label: negativeMarking > 0
                                                    ? 'per wrong'
                                                    : 'marking',
                                                width: infoCardWidth,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(
                                          height:
                                              _responsiveValue(20, 28, 32)),

                                      // Key Points
                                      Container(
                                        padding: EdgeInsets.all(
                                            _responsiveValue(18, 24, 28)),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F7FF),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  _responsiveValue(
                                                      12, 16, 20)),
                                          border: Border(
                                            left: BorderSide(
                                              color:
                                                  const Color(0xFF0072BC),
                                              width: _scale(4),
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Key Points:',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(
                                                    18, 20, 22),
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    const Color(0xFF003366),
                                              ),
                                            ),
                                            SizedBox(height: _scale(12)),
                                            _buildKeyPoint(
                                              'The test consists of $totalQuestions questions',
                                              highlightText:
                                                  '$totalQuestions questions',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            _buildKeyPoint(
                                              'You have $timeLimitMinutes minutes to complete',
                                              highlightText:
                                                  '$timeLimitMinutes minutes',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            _buildKeyPoint(
                                              'Each correct answer awards $pointsPerQuestion points',
                                              highlightText:
                                                  '$pointsPerQuestion points',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            _buildKeyPoint(
                                              negativeMarking > 0
                                                  ? '$negativeMarking point deducted for wrong answers'
                                                  : 'No negative marking for wrong answers',
                                              highlightText: negativeMarking >
                                                      0
                                                  ? '$negativeMarking point deducted'
                                                  : 'No negative marking',
                                            ),
                                            SizedBox(height: _scale(8)),
                                            _buildKeyPoint(
                                              'Answer all questions for accurate scoring',
                                              highlightText:
                                                  'Answer all questions',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              _responsiveValue(20, 28, 32)),

                                      // Timer Display (shown after test started)
                                      if (_testStarted)
                                        Container(
                                          padding: EdgeInsets.all(
                                              _responsiveValue(18, 24, 28)),
                                          decoration: BoxDecoration(
                                            color:
                                                const Color(0xFF0052A2),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    _responsiveValue(
                                                        12, 16, 20)),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.timer,
                                                size: _scale(
                                                    isTablet ? 28 : 22),
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: _scale(8)),
                                              Text(
                                                _formatTime(_timeLeft),
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(
                                                      36, 42, 48),
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: _scale(4)),
                                              Text(
                                                'Time Remaining',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(
                                                      16, 18, 20),
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      SizedBox(
                                          height:
                                              _responsiveValue(20, 28, 32)),

                                      // Start Button
                                      GestureDetector(
                                        onTap: _isStarting
                                            ? null
                                            : () => setState(
                                                () => _modalVisible = true),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFF416C),
                                                Color(0xFFFF4B2B)
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    _responsiveValue(
                                                        16, 20, 24)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                        0xFFFF416C)
                                                    .withOpacity(0.3),
                                                blurRadius: _scale(8),
                                                offset:
                                                    Offset(0, _scale(4)),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical:
                                                _responsiveValue(18, 22, 26),
                                          ),
                                          child: Center(
                                            child: _isStarting
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    'Start Test →',
                                                    style: TextStyle(
                                                      fontSize:
                                                          _responsiveValue(
                                                              18, 22, 24),
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              _responsiveValue(16, 20, 24)),

                                      // Note
                                      Text(
                                        'Make sure you have a stable internet connection and won\'t be interrupted during the test.',
                                        style: TextStyle(
                                          fontSize:
                                              _responsiveValue(14, 16, 18),
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

                          // Progress Section
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            padding: EdgeInsets.all(
                                _responsiveValue(20, 28, 32)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  _responsiveValue(16, 20, 24)),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Test Progress',
                                      style: TextStyle(
                                        fontSize:
                                            _responsiveValue(16, 20, 22),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF003366),
                                      ),
                                    ),
                                    Text(
                                      '0%',
                                      style: TextStyle(
                                        fontSize:
                                            _responsiveValue(16, 20, 22),
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0072BC),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: _scale(12)),
                                Container(
                                  height: _responsiveValue(8, 12, 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9ECEF),
                                    borderRadius: BorderRadius.circular(
                                        _responsiveValue(4, 6, 8)),
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: 0.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0072BC),
                                        borderRadius: BorderRadius.circular(
                                            _responsiveValue(4, 6, 8)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: _scale(8)),
                                Text(
                                  '0 of $totalQuestions questions answered',
                                  style: TextStyle(
                                    fontSize: _responsiveValue(14, 16, 18),
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: _responsiveValue(20, 30, 40)),

                          // YouTube Video
                          Container(
                            margin: EdgeInsets.only(
                                top: _responsiveValue(20, 30, 40),
                                bottom: 0),
                            width: double.infinity,
                            height:
                                isDesktop ? 400 : (isTablet ? 320 : 250),
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
                                onTap: () => _showUrlDialog(
                                    'https://www.youtube.com/embed/L2zqTYgcpfg'),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.3),
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

          // Confirmation Modal
          if (_modalVisible)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: isMobile ? screenWidth * 0.9 : 400,
                    margin: EdgeInsets.all(_scale(20)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          _responsiveValue(16, 20, 24)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Modal Header
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0072BC),
                                Color(0xFF0052A2)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                  _responsiveValue(16, 20, 24)),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: _responsiveValue(18, 22, 26),
                            horizontal: _responsiveValue(20, 24, 28),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                                onPressed: () =>
                                    setState(() => _modalVisible = false),
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
                          padding:
                              EdgeInsets.all(_responsiveValue(20, 28, 32)),
                          child: Column(
                            children: [
                              Icon(
                                Icons.help,
                                size: _scale(isTablet ? 70 : 60),
                                color: const Color(0xFF0072BC),
                              ),
                              SizedBox(height: _scale(20)),
                              Text(
                                'Once you start, the timer will begin counting down from $timeLimitMinutes minutes. Are you ready to begin the test?',
                                style: TextStyle(
                                  fontSize: _responsiveValue(16, 18, 20),
                                  color: const Color(0xFF333333),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: _scale(24)),
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: _scale(16)),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => setState(
                                          () => _modalVisible = false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFF8F9FA),
                                        foregroundColor:
                                            const Color(0xFF666666),
                                        padding: EdgeInsets.symmetric(
                                          vertical: _responsiveValue(
                                              14, 18, 22),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  _responsiveValue(
                                                      12, 16, 20)),
                                          side: const BorderSide(
                                            color: Color(0xFFDEE2E6),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize:
                                              _responsiveValue(16, 18, 20),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: _scale(12)),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF00B09B),
                                            Color(0xFF96C93D)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                                _responsiveValue(
                                                    12, 16, 20)),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isStarting
                                            ? null
                                            : _startTest,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: _responsiveValue(
                                                14, 18, 22),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    _responsiveValue(
                                                        12, 16, 20)),
                                          ),
                                        ),
                                        child: _isStarting
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                'Yes, Start Test',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(
                                                      16, 18, 20),
                                                  fontWeight:
                                                      FontWeight.w700,
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
        borderRadius:
            BorderRadius.circular(_responsiveValue(12, 16, 20)),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: _responsiveValue(48, 60, 72),
            height: _responsiveValue(48, 60, 72),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2FF),
              borderRadius:
                  BorderRadius.circular(_responsiveValue(24, 30, 36)),
            ),
            child: Icon(
              icon,
              size: _responsiveValue(24, 30, 36),
              color: const Color(0xFF0072BC),
            ),
          ),
          SizedBox(height: _scale(12)),
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
          Text(
            value,
            style: TextStyle(
              fontSize: _responsiveValue(24, 28, 32),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0072BC),
            ),
          ),
          SizedBox(height: _scale(2)),
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

  Widget _buildKeyPoint(String text, {String? highlightText}) {
    final List<TextSpan> textSpans = [];
    final words = text.split(' ');

    for (final word in words) {
      if (highlightText != null &&
          word.contains(highlightText.split(' ')[0])) {
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
        Container(
          width: _scale(20),
          padding: EdgeInsets.only(top: _scale(4)),
          child: Icon(Icons.circle,
              size: _scale(8), color: const Color(0xFF0072BC)),
        ),
        SizedBox(width: _scale(4)),
        Expanded(child: RichText(text: TextSpan(children: textSpans))),
      ],
    );
  }
}