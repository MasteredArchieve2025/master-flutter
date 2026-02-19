// lib/pages/Exam/Exam1.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Add this import for kIsWeb
import 'Exam2.dart';

class Exam1Screen extends StatefulWidget {
  const Exam1Screen({super.key});

  @override
  State<Exam1Screen> createState() => _Exam1ScreenState();
}

class _Exam1ScreenState extends State<Exam1Screen> {
  int _activeAdIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Advertisement banners data
  final List<Map<String, dynamic>> ads = [
    {
      'id': '1',
      'image': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&h=300&fit=crop',
      'title': 'Exam Books',
      'description': 'Comprehensive study materials',
      'url': 'https://example.com/exam-books',
    },
    {
      'id': '2',
      'image': 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=300&fit=crop',
      'title': 'Test Series',
      'description': 'Practice with mock tests',
      'url': 'https://example.com/test-series',
    },
    {
      'id': '3',
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=300&fit=crop',
      'title': 'Coaching',
      'description': 'Expert guidance for exams',
      'url': 'https://example.com/coaching',
    },
  ];

  // Exam categories data
  final List<Map<String, dynamic>> examCategories = [
    {
      'id': '1',
      'title': 'School Board Exams',
      'description': 'Class 10 & 12 Board Exams (CBSE, ICSE, State Boards)',
      'icon': '🏫',
      'count': '2 Types',
      'color': Color(0xFF4A90E2),
    },
    {
      'id': '2',
      'title': 'Government Recruitment Exams',
      'description': 'UPSC, SSC, Banking, Railway, Defense Exams',
      'icon': '👮',
      'count': '15+ Exams',
      'color': Color(0xFF50C878),
    },
    {
      'id': '3',
      'title': 'Higher Education Exams',
      'description': 'JEE, NEET, CLAT, NDA, Design Entrance Exams',
      'icon': '🎓',
      'count': '10+ Exams',
      'color': Color(0xFFFF6B6B),
    },
    {
      'id': '4',
      'title': 'Professional Entrance Exams',
      'description': 'CAT, GATE, GMAT, CA, CS, Medical PG Exams',
      'icon': '💼',
      'count': '20+ Exams',
      'color': Color(0xFFFFA500),
    },
    {
      'id': '5',
      'title': 'International Exams',
      'description': 'SAT, GRE, GMAT, TOEFL, IELTS, PTE',
      'icon': '🌍',
      'count': '8+ Exams',
      'color': Color(0xFF9B59B6),
    },
    {
      'id': '6',
      'title': 'Skill Development Exams',
      'description': 'ITI, Polytechnic, Vocational Training Exams',
      'icon': '🔧',
      'count': '12+ Exams',
      'color': Color(0xFF1ABC9C),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll ads
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adController.hasClients && mounted) {
        int nextPage = _activeAdIndex + 1;
        if (nextPage >= ads.length) nextPage = 0;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
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

  // Calculate grid columns
  int _getGridColumns() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 3; // Desktop
    if (screenWidth >= 768) return 2; // Tablet
    return 2; // Mobile
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double adHeight = _responsiveValue(200, 300, 300);
    final int gridColumns = _getGridColumns();
    final double cardWidth = (screenWidth - (horizontalPadding * 2) - (_responsiveValue(12, 16, 20) * (gridColumns - 1))) / gridColumns;
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;

    // Calculate header height - simplified without Platform
    final double headerHeight = _responsiveValue(52, 72, 80);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: headerHeight,
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
                          'Exams',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(20, 22, 24),
                            fontWeight: FontWeight.w700,
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
                        // ===== ADVERTISEMENT BANNER =====
                        Container(
                          width: screenWidth,
                          height: adHeight,
                          child: PageView.builder(
                            controller: _adController,
                            itemCount: ads.length,
                            onPageChanged: (index) {
                              setState(() {
                                _activeAdIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final ad = ads[index];
                              return GestureDetector(
                                onTap: () => _showUrlDialog(ad['url']),
                                child: Container(
                                  width: screenWidth,
                                  color: Colors.black,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.campaign_outlined,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ad ${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ad['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // ===== PAGINATION DOTS =====
                        Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(ads.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _activeAdIndex == index ? _scale(20) : _scale(8),
                                height: _scale(8),
                                margin: EdgeInsets.symmetric(horizontal: _scale(4)),
                                decoration: BoxDecoration(
                                  color: _activeAdIndex == index 
                                    ? const Color(0xFF0B5ED7) 
                                    : const Color(0xFFCCCCCC),
                                  borderRadius: BorderRadius.circular(_scale(4)),
                                ),
                              );
                            }),
                          ),
                        ),

                        // ===== EXAM CATEGORIES SECTION =====
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            _responsiveValue(24, 28, 32),
                            horizontalPadding,
                            _responsiveValue(20, 24, 28),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Text(
                                'Exam Categories',
                                style: TextStyle(
                                  fontSize: _responsiveValue(20, 22, 24),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF003366),
                                ),
                              ),
                              SizedBox(height: _scale(8)),
                              // Section Subtitle
                              Text(
                                'Browse exams by category and find the right preparation resources',
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  color: const Color(0xFF666666),
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: _responsiveValue(20, 24, 28)),

                              // Grid View
                              Wrap(
                                spacing: _responsiveValue(12, 16, 20),
                                runSpacing: _responsiveValue(12, 16, 20),
                                children: examCategories.map((exam) {
                                  return _buildExamCard(
                                    exam: exam,
                                    width: cardWidth,
                                  );
                                }).toList(),
                          ),
                            ],
                          ),
                        ),

                        // ===== BANNER SECTION =====
                        Container(
                          width: screenWidth,
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: _responsiveValue(20, 24, 28),
                          ),
                          padding: EdgeInsets.all(_responsiveValue(20, 24, 28)),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C73AC),
                            borderRadius: BorderRadius.circular(_scale(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: _scale(6),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Comprehensive Exam Resources',
                                style: TextStyle(
                                  fontSize: _responsiveValue(18, 20, 22),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: _scale(10)),
                              Text(
                                'Get syllabus, previous papers, mock tests, and preparation tips',
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  color: const Color(0xFFDCE8FF),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== YOUTUBE VIDEO SECTION - LIKE COLLEGE1 PAGE =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _responsiveValue(20, 30, 40),
                            bottom: 0, // Reduced bottom margin
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
      ),
    );
  }

  Widget _buildExamCard({
    required Map<String, dynamic> exam,
    required double width,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Exam2 screen when card is tapped
 Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Exam2Screen(
            examData: exam,
          ),
        ),
      );

      
      },
      child: Container(
        width: width,
        padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_scale(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: _scale(8),
              offset: Offset(0, _scale(2)),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              width: _responsiveValue(56, 64, 72),
              height: _responsiveValue(56, 64, 72),
              decoration: BoxDecoration(
                color: (exam['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(_scale(12)),
              ),
              child: Center(
                child: Text(
                  exam['icon'] as String,
                  style: TextStyle(
                    fontSize: _responsiveValue(28, 32, 36),
                  ),
                ),
              ),
            ),
            SizedBox(height: _scale(12)),

            // Title
            Text(
              exam['title'] as String,
              style: TextStyle(
                fontSize: _responsiveValue(16, 17, 18),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF003366),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: _scale(8)),

            // Description
            Text(
              exam['description'] as String,
              style: TextStyle(
                fontSize: _responsiveValue(12, 13, 14),
                color: const Color(0xFF666666),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: _scale(12)),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Count Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _scale(10),
                    vertical: _scale(4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(_scale(12)),
                  ),
                  child: Text(
                    exam['count'] as String,
                    style: TextStyle(
                      fontSize: _responsiveValue(11, 12, 13),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0072BC),
                    ),
                  ),
                ),

                // Arrow Icon
                Container(
                  width: _scale(24),
                  height: _scale(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(_scale(12)),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: _scale(18),
                    color: exam['color'] as Color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}