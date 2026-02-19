// lib/pages/Exam/ExamDetailsFull.dart
import 'package:flutter/material.dart';
import '../../widgets/footer.dart';

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
  // Exam data
  final Map<String, dynamic> examData = {
    'title': 'Class 12 (HSC +2) Public Exams',
    'description': 'Higher Secondary Certificate Public Examinations',
    'board': 'State Board',
    'year': '2025',
    'subjects': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'Computer Science'],
    'syllabus': [
      'Mathematics: Algebra, Calculus, Geometry, Statistics',
      'Physics: Mechanics, Thermodynamics, Electromagnetism, Optics',
      'Chemistry: Organic, Inorganic, Physical Chemistry',
      'Biology: Botany, Zoology, Genetics, Ecology',
      'English: Language & Literature',
      'Computer Science: Programming, Database, Networking'
    ],
    'examPattern': {
      'duration': '3 hours per subject',
      'totalMarks': 600,
      'passingMarks': 210,
      'questionTypes': ['MCQ (20%)', 'Short Answer (30%)', 'Long Answer (50%)'],
      'practical': 'Yes (30 marks per subject)'
    },
    'importantDates': [
      'Application Start: January 15, 2025',
      'Last Date: February 28, 2025',
      'Admit Card: March 15, 2025',
      'Theory Exams: March 25 - April 15, 2025',
      'Practical Exams: April 20 - 30, 2025',
      'Result Declaration: June 15, 2025'
    ]
  };

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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
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
                          examData['title'] as String,
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
              child: SingleChildScrollView(
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
                                // Overview Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: _scale(50),
                                      height: _scale(50),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(_scale(12)),
                                      ),
                                      child: Icon(
                                        Icons.school,
                                        size: _scale(30),
                                        color: const Color(0xFF4A90E2),
                                      ),
                                    ),
                                    SizedBox(width: _scale(16)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            examData['title'] as String,
                                            style: TextStyle(
                                              fontSize: _responsiveValue(18, 20, 22),
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF003366),
                                            ),
                                          ),
                                          SizedBox(height: _scale(4)),
                                          Text(
                                            examData['description'] as String,
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
                                      value: examData['board'] as String,
                                    ),
                                    _buildStatItem(
                                      icon: Icons.calendar_today,
                                      label: 'Year',
                                      value: examData['year'] as String,
                                    ),
                                    _buildStatItem(
                                      icon: Icons.timer,
                                      label: 'Duration',
                                      value: examData['examPattern']['duration'] as String,
                                    ),
                                    _buildStatItem(
                                      icon: Icons.score,
                                      label: 'Total Marks',
                                      value: examData['examPattern']['totalMarks'].toString(),
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
                            children: (examData['subjects'] as List).map<Widget>((subject) {
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
                            children: (examData['syllabus'] as List).map<Widget>((item) {
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
                                    value: examData['examPattern']['duration'] as String,
                                  ),
                                  _buildPatternItem(
                                    label: 'Total Marks',
                                    value: examData['examPattern']['totalMarks'].toString(),
                                  ),
                                  _buildPatternItem(
                                    label: 'Passing Marks',
                                    value: examData['examPattern']['passingMarks'].toString(),
                                  ),
                                  _buildPatternItem(
                                    label: 'Practical Exam',
                                    value: examData['examPattern']['practical'] as String,
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
                                children: (examData['examPattern']['questionTypes'] as List).map<Widget>((type) {
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (examData['importantDates'] as List).map<Widget>((date) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: _scale(16)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: _scale(8),
                                      height: _scale(8),
                                      margin: EdgeInsets.only(top: _scale(6)),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A90E2),
                                        borderRadius: BorderRadius.circular(_scale(4)),
                                      ),
                                    ),
                                    SizedBox(width: _scale(12)),
                                    Expanded(
                                      child: Text(
                                        date,
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

                        // ===== YOUTUBE VIDEO SECTION - LIKE EXAM1 & EXAM2 =====
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
                                    content: Text('Watch detailed guide for ${examData['title']} preparation'),
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