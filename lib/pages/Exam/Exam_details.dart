// lib/pages/Exam/ExamDetailsFull.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';

class ExamDetailsFullScreen extends StatefulWidget {
  final Map<String, dynamic>? examData;
  
  const ExamDetailsFullScreen({
    super.key,
    this.examData,
  });

  @override
  State<ExamDetailsFullScreen> createState() => _ExamDetailsFullScreenState();
}

class _ExamDetailsFullScreenState extends State<ExamDetailsFullScreen> {
  // Loading states
  bool _isLoading = true;
  String? _errorMessage;

  // API Data
  Map<String, dynamic>? examDetails;

  // Fallback data in case API fails
  final Map<String, dynamic> _fallbackData = {
    'title': 'Exam Details',
    'description': 'Complete exam information',
    'board': 'State Board',
    'year': '2025',
    'duration': '3 Hours',
    'totalMarks': 600,
    'subjects': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'Computer Science'],
    'detailedSyllabus': 'Full detailed syllabus will be available soon...',
    'examPattern': {
      'duration': '3 Hours',
      'totalMarks': 600,
      'passingMark': 210,
    },
    'questionTypes': ['MCQ (20%)', 'Short Answer (30%)', 'Long Answer (50%)'],
    'importantDates': 'Application: Jan 2025, Exam: Mar 2025, Results: Jun 2025',
    'image': null,
  };

  @override
  void initState() {
    super.initState();
    _fetchExamDetails();
  }

  Future<void> _fetchExamDetails() async {
    debugPrint('🔄 Loading exam details...');
    
    // Get typeId from examData if available
    final typeId = widget.examData?['id'];
    
    try {
      String apiUrl;
      if (typeId != null) {
        // Fetch specific exam detail by typeId
        apiUrl = '${BaseUrl.baseUrl}/api/exam-details?typeId=$typeId';
      } else {
        // Fetch all and take first (fallback)
        apiUrl = '${BaseUrl.baseUrl}/api/exam-details';
      }
      
      debugPrint('📡 Fetching exam details from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Exam Details API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} exam details');

        if (data.isNotEmpty) {
          // If we have typeId, find matching record, otherwise use first
          Map<String, dynamic> selectedDetail;
          
          if (typeId != null) {
            // Try to find exact match
            try {
              selectedDetail = data.firstWhere(
                (item) => item['typeId'] == typeId,
                orElse: () => data.first,
              );
            } catch (e) {
              selectedDetail = data.first;
            }
          } else {
            selectedDetail = data.first;
          }
          
          setState(() {
            examDetails = _mapApiDataToModel(selectedDetail);
            _isLoading = false;
          });
        } else {
          // No data found, use fallback
          setState(() {
            examDetails = _fallbackData;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load exam details. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading exam details: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _mapApiDataToModel(Map<String, dynamic> apiData) {
    // Parse examPattern if it's a string
    Map<String, dynamic> examPattern = {};
    if (apiData['examPattern'] is String) {
      try {
        examPattern = json.decode(apiData['examPattern']);
      } catch (e) {
        examPattern = {
          'duration': apiData['duration'] ?? '3 Hours',
          'totalMarks': apiData['totalMarks'] ?? 600,
          'passingMark': apiData['passingMark'] ?? 210,
        };
      }
    } else if (apiData['examPattern'] is Map) {
      examPattern = Map<String, dynamic>.from(apiData['examPattern']);
    } else {
      examPattern = {
        'duration': apiData['duration'] ?? '3 Hours',
        'totalMarks': apiData['totalMarks'] ?? 600,
        'passingMark': apiData['passingMark'] ?? 210,
      };
    }

    // Parse questionTypes if it's a string
    List<String> questionTypes = [];
    if (apiData['questionTypes'] is String) {
      try {
        questionTypes = List<String>.from(json.decode(apiData['questionTypes']));
      } catch (e) {
        questionTypes = ['MCQ', 'Descriptive'];
      }
    } else if (apiData['questionTypes'] is List) {
      questionTypes = List<String>.from(apiData['questionTypes']);
    } else {
      questionTypes = ['MCQ', 'Descriptive'];
    }

    // Parse subjects if it's a string
    List<String> subjects = [];
    if (apiData['subjects'] is String) {
      try {
        subjects = List<String>.from(json.decode(apiData['subjects']));
      } catch (e) {
        subjects = [apiData['name'] ?? 'General'];
      }
    } else if (apiData['subjects'] is List) {
      subjects = List<String>.from(apiData['subjects']);
    } else {
      subjects = [apiData['name'] ?? 'General Studies'];
    }

    // Create syllabus list from detailedSyllabus
    List<String> syllabus = [];
    String detailedSyllabus = apiData['detailedSyllabus'] ?? '';
    if (detailedSyllabus.isNotEmpty) {
      // Split by newlines or periods to create bullet points
      syllabus = detailedSyllabus
          .split(RegExp(r'[.\n]'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    if (syllabus.isEmpty) {
      syllabus = ['Complete syllabus will be updated soon'];
    }

    return {
      'id': apiData['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'title': apiData['name'] ?? widget.examData?['title'] ?? 'Exam Details',
      'description': apiData['shortDescription'] ?? widget.examData?['description'] ?? 'Complete exam information',
      'board': apiData['board'] ?? 'Board',
      'year': apiData['year'] ?? '2025',
      'duration': apiData['duration'] ?? '3 Hours',
      'totalMarks': apiData['totalMarks'] ?? 600,
      'passingMarks': examPattern['passingMark'] ?? 210,
      'subjects': subjects,
      'syllabus': syllabus,
      'detailedSyllabus': detailedSyllabus,
      'examPattern': examPattern,
      'questionTypes': questionTypes,
      'importantDates': apiData['importantDates'] ?? 'Dates will be announced soon',
      'image': apiData['image'],
    };
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchExamDetails();
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

    // Use API data or fallback
    final Map<String, dynamic> displayData = examDetails ?? _fallbackData;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ===== HEADER =====
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052A2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    height: _responsiveValue(52, 72, 80),
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            size: _scale(24),
                            color: Colors.white,
                          ),
                        ),
                        // Title
                        Expanded(
                          child: Center(
                            child: Text(
                              displayData['title'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(16, 18, 20),
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  child: _isLoading
                      ? const Center(
                          child: GlassLoader(
                            message: 'Loading exam details...',
                          ),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading exam details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _retryLoading,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B5ED7),
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Center(
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: _responsiveValue(16, 20, 24)),

                                      // ===== EXAM OVERVIEW CARD =====
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(_scale(16)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: _scale(8),
                                              offset: Offset(0, _scale(2)),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Overview Header with Image if available
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: _scale(50),
                                                    height: _scale(50),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(_scale(12)),
                                                      image: displayData['image'] != null
                                                          ? DecorationImage(
                                                              image: NetworkImage(displayData['image']),
                                                              fit: BoxFit.cover,
                                                              onError: (exception, stackTrace) {},
                                                            )
                                                          : null,
                                                    ),
                                                    child: displayData['image'] == null
                                                        ? Icon(
                                                            Icons.school,
                                                            size: _scale(30),
                                                            color: const Color(0xFF4A90E2),
                                                          )
                                                        : null,
                                                  ),
                                                  SizedBox(width: _scale(16)),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          displayData['title'] as String,
                                                          style: TextStyle(
                                                            fontSize: _responsiveValue(18, 20, 22),
                                                            fontWeight: FontWeight.w700,
                                                            color: const Color(0xFF003366),
                                                          ),
                                                        ),
                                                        SizedBox(height: _scale(4)),
                                                        Text(
                                                          displayData['description'] as String,
                                                          style: TextStyle(
                                                            fontSize: _responsiveValue(13, 14, 15),
                                                            color: const Color(0xFF666666),
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: _scale(16)),

                                              // Divider
                                              Container(
                                                height: 1,
                                                color: const Color(0xFFE0E0E0),
                                              ),

                                              SizedBox(height: _scale(16)),

                                              // Quick Stats Grid
                                              Wrap(
                                                spacing: _scale(12),
                                                runSpacing: _scale(12),
                                                children: [
                                                  _buildStatItem(
                                                    icon: Icons.business,
                                                    label: 'Board',
                                                    value: displayData['board'] as String,
                                                  ),
                                                  _buildStatItem(
                                                    icon: Icons.calendar_today,
                                                    label: 'Year',
                                                    value: displayData['year'] as String,
                                                  ),
                                                  _buildStatItem(
                                                    icon: Icons.timer,
                                                    label: 'Duration',
                                                    value: displayData['duration'] as String,
                                                  ),
                                                  _buildStatItem(
                                                    icon: Icons.score,
                                                    label: 'Total Marks',
                                                    value: displayData['totalMarks'].toString(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: _responsiveValue(16, 20, 24)),

                                      // ===== SUBJECTS SECTION =====
                                      _buildSectionCard(
                                        icon: Icons.subject,
                                        title: 'Subjects',
                                        child: Wrap(
                                          spacing: _scale(12),
                                          runSpacing: _scale(12),
                                          children: (displayData['subjects'] as List).map<Widget>((subject) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: _scale(16),
                                                vertical: _scale(12),
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF0F7FF),
                                                borderRadius: BorderRadius.circular(_scale(10)),
                                              ),
                                              child: Text(
                                                subject,
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(13, 14, 15),
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF4A90E2),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),

                                      // ===== SYLLABUS SECTION =====
                                      _buildSectionCard(
                                        icon: Icons.book,
                                        title: 'Detailed Syllabus',
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: (displayData['syllabus'] as List).map<Widget>((item) {
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: _scale(12)),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(top: _scale(8)),
                                                    child: Container(
                                                      width: _scale(6),
                                                      height: _scale(6),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF4A90E2),
                                                        borderRadius: BorderRadius.circular(_scale(3)),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: _scale(12)),
                                                  Expanded(
                                                    child: Text(
                                                      item,
                                                      style: TextStyle(
                                                        fontSize: _responsiveValue(13, 14, 15),
                                                        color: const Color(0xFF444444),
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),

                                      // ===== EXAM PATTERN SECTION =====
                                      _buildSectionCard(
                                        icon: Icons.pattern,
                                        title: 'Exam Pattern',
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Pattern Grid
                                            Wrap(
                                              spacing: _scale(12),
                                              runSpacing: _scale(12),
                                              children: [
                                                _buildPatternItem(
                                                  label: 'Duration',
                                                  value: displayData['duration'] as String,
                                                ),
                                                _buildPatternItem(
                                                  label: 'Total Marks',
                                                  value: displayData['totalMarks'].toString(),
                                                ),
                                                _buildPatternItem(
                                                  label: 'Passing Marks',
                                                  value: displayData['passingMarks'].toString(),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: _scale(20)),

                                            // Question Types
                                            Text(
                                              'Question Types:',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(14, 16, 18),
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF003366),
                                              ),
                                            ),

                                            SizedBox(height: _scale(12)),

                                            Wrap(
                                              spacing: _scale(8),
                                              runSpacing: _scale(8),
                                              children: (displayData['questionTypes'] as List).map<Widget>((type) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: _scale(16),
                                                    vertical: _scale(8),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE8F4FF),
                                                    borderRadius: BorderRadius.circular(_scale(20)),
                                                  ),
                                                  child: Text(
                                                    type,
                                                    style: TextStyle(
                                                      fontSize: _responsiveValue(12, 13, 14),
                                                      color: const Color(0xFF4A90E2),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ===== IMPORTANT DATES SECTION =====
                                      _buildSectionCard(
                                        icon: Icons.calendar_month,
                                        title: 'Important Dates',
                                        child: Text(
                                          displayData['importantDates'] as String,
                                          style: TextStyle(
                                            fontSize: _responsiveValue(13, 14, 15),
                                            color: const Color(0xFF444444),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),

                                      // ===== YOUTUBE VIDEO SECTION =====
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: _responsiveValue(40, 50, 60),
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
                                            onTap: () {
                                              // Show dialog for video play
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text('Exam Preparation Video'),
                                                  content: Text('Watch detailed guide for ${displayData['title']} preparation'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
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
          ),
          
          // Full screen loader for initial loading
          if (_isLoading && examDetails == null)
            const GlassLoader(
              message: 'Loading exam details...',
            ),
        ],
      ),
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }

  // Build Stat Item Widget
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: _scale(120),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(_scale(12)),
      ),
      padding: EdgeInsets.all(_scale(16)),
      child: Column(
        children: [
          Icon(
            icon,
            size: _scale(20),
            color: const Color(0xFF666666),
          ),
          SizedBox(height: _scale(8)),
          Text(
            label,
            style: TextStyle(
              fontSize: _responsiveValue(11, 12, 13),
              color: const Color(0xFF999999),
            ),
          ),
          SizedBox(height: _scale(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: _responsiveValue(14, 16, 18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF003366),
            ),
          ),
        ],
      ),
    );
  }

  // Build Pattern Item Widget
  Widget _buildPatternItem({
    required String label,
    required String value,
  }) {
    return Container(
      width: _scale(150),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(_scale(10)),
      ),
      padding: EdgeInsets.all(_scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _responsiveValue(11, 12, 13),
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: _scale(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: _responsiveValue(14, 16, 18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF003366),
            ),
          ),
        ],
      ),
    );
  }

  // Build Section Card Widget
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _responsiveValue(16, 24, 32),
        vertical: _responsiveValue(8, 12, 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_scale(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: _scale(6),
            offset: Offset(0, _scale(2)),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  icon,
                  size: _scale(24),
                  color: const Color(0xFF4A90E2),
                ),
                SizedBox(width: _scale(12)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _responsiveValue(16, 18, 20),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF003366),
                  ),
                ),
              ],
            ),
            SizedBox(height: _scale(20)),
            // Section Content
            child,
          ],
        ),
      ),
    );
  }
}