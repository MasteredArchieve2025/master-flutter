// lib/pages/Exam/Exam2.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/footer.dart'; // Import your footer - FIXED
import 'Exam3.dart';

class Exam2Screen extends StatefulWidget {
  final Map<String, dynamic>? examData; // Exam data passed from Exam1
  
  const Exam2Screen({
    super.key,
    this.examData,
  });

  @override
  State<Exam2Screen> createState() => _Exam2ScreenState();
}

class _Exam2ScreenState extends State<Exam2Screen> {
  int _activeAdIndex = 0;
  int _activeTabIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Advertisement banners data
  final List<Map<String, dynamic>> ads = [
    {
      'id': '1',
      'image': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=1200&h=400&fit=crop',
      'url': 'https://example.com/board-exams',
      'title': 'Board Exams',
    },
    {
      'id': '2',
      'image': 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=1200&h=400&fit=crop',
      'url': 'https://example.com/previous-papers',
      'title': 'Previous Papers',
    },
    {
      'id': '3',
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop',
      'url': 'https://example.com/study-package',
      'title': 'Study Package',
    },
  ];

  // Tab categories
  final List<Map<String, dynamic>> tabs = [
    {'id': 'all', 'label': 'All Exams'},
    {'id': 'board', 'label': 'Board Exams'},
    {'id': 'supplementary', 'label': 'Supplementary'},
    {'id': 'annual', 'label': 'Annual Exams'},
  ];

  // Exam types data with square cards
  final List<Map<String, dynamic>> examTypes = [
    {
      'id': '1',
      'title': 'Class 12 (HSC +2) Public Exams',
      'description': 'Higher Secondary Certificate Public Examinations',
      'icon': '📚',
      'type': 'board',
      'color': Color(0xFF4A90E2),
    },
    {
      'id': '2',
      'title': '12th Supplementary Exams',
      'description': 'Supplementary/Compartmental Examinations',
      'icon': '🔄',
      'type': 'supplementary',
      'color': Color(0xFF50C878),
    },
    {
      'id': '3',
      'title': 'Class 10 (SSLC) Public Exams',
      'description': 'Secondary School Leaving Certificate Exams',
      'icon': '🎓',
      'type': 'board',
      'color': Color(0xFFFF6B6B),
    },
    {
      'id': '4',
      'title': 'Class 12 Model Papers',
      'description': 'Model question papers with solutions',
      'icon': '📝',
      'type': 'board',
      'color': Color(0xFFFFA500),
    },
    {
      'id': '5',
      'title': 'Class 11 Exams',
      'description': 'Annual Examinations for Class 11 Students',
      'icon': '📖',
      'type': 'annual',
      'color': Color(0xFF9B59B6),
    },
    {
      'id': '6',
      'title': '2025–26 School Calendar',
      'description': 'Academic Calendar for Grades 1–12',
      'icon': '📅',
      'type': 'annual',
      'color': Color(0xFF1ABC9C),
    },
    {
      'id': '7',
      'title': '10th Supplementary Exams',
      'description': 'SSLC Supplementary Examinations',
      'icon': '📚',
      'type': 'supplementary',
      'color': Color(0xFF3498DB),
    },
    {
      'id': '8',
      'title': 'Practical Exams',
      'description': 'Laboratory and Practical Examinations',
      'icon': '🔬',
      'type': 'annual',
      'color': Color(0xFFE74C3C),
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
    if (screenWidth >= 1024) return 4; // Desktop
    if (screenWidth >= 768) return 3; // Tablet
    return 2; // Mobile
  }

  // Filter exams based on active tab
  List<Map<String, dynamic>> get _filteredExams {
    final activeTab = tabs[_activeTabIndex]['id'];
    if (activeTab == 'all') return examTypes;
    return examTypes.where((exam) => exam['type'] == activeTab).toList();
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
    final double adHeight = _responsiveValue(200, 300, 240);
    final int gridColumns = _getGridColumns();
    
    // Calculate card dimensions
    final double gap = _responsiveValue(8, 12, 16);
    final double availableWidth = screenWidth - (horizontalPadding * 2);
    final double totalGap = gap * (gridColumns - 1);
    final double cardWidth = (availableWidth - totalGap) / gridColumns;
    final double cardHeight = cardWidth * 0.9;
    
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    final String examTitle = widget.examData?['title'] ?? 'School Board Exams';

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
                          'Exam Types',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(18, 20, 22),
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
                          margin: EdgeInsets.only(bottom: _responsiveValue(16, 20, 24)),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
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
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                  ),
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(ads.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _activeAdIndex == index ? _scale(10) : _scale(6),
                                height: _scale(6),
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

                        // ===== EXAM CATEGORY HEADER =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            _responsiveValue(20, 24, 28),
                            horizontalPadding,
                            _responsiveValue(16, 20, 24),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: const Color(0xFFF0F0F0),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                examTitle,
                                style: TextStyle(
                                  fontSize: _responsiveValue(20, 22, 24),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF003366),
                                ),
                              ),
                              SizedBox(height: _scale(8)),
                              Text(
                                'Select exam type to view detailed syllabus, patterns, and resources',
                                style: TextStyle(
                                  fontSize: _responsiveValue(13, 14, 15),
                                  color: const Color(0xFF666666),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== TAB NAVIGATION =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: _responsiveValue(10, 12, 14),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(tabs.length, (index) {
                                final tab = tabs[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? horizontalPadding : 0,
                                    right: index < tabs.length - 1 
                                      ? _responsiveValue(12, 16, 20) 
                                      : horizontalPadding,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _activeTabIndex = index;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: _activeTabIndex == index 
                                              ? const Color(0xFF0B5ED7) 
                                              : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: _responsiveValue(12, 16, 20),
                                        vertical: _responsiveValue(8, 10, 12),
                                      ),
                                      child: Text(
                                        tab['label'] as String,
                                        style: TextStyle(
                                          fontSize: _responsiveValue(13, 14, 15),
                                          fontWeight: _activeTabIndex == index 
                                            ? FontWeight.w700 
                                            : FontWeight.w500,
                                          color: _activeTabIndex == index 
                                            ? const Color(0xFF0B5ED7) 
                                            : const Color(0xFF666666),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),

                        // ===== EXAM TYPES GRID =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            _responsiveValue(20, 24, 28),
                            horizontalPadding,
                            _responsiveValue(10, 15, 20),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: _filteredExams.map((exam) {
                              return _buildExamCard(
                                exam: exam,
                                width: cardWidth,
                                height: cardHeight,
                              );
                            }).toList(),
                          ),
                        ),

                        // ===== AVAILABLE BANNER =====
                        Container(
                          width: screenWidth,
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: _responsiveValue(16, 20, 24),
                          ),
                          padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
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
                                'Complete Exam Resources',
                                style: TextStyle(
                                  fontSize: _responsiveValue(16, 18, 20),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: _scale(8)),
                              Text(
                                'Access syllabus, model papers, answer keys, and preparation guides',
                                style: TextStyle(
                                  fontSize: _responsiveValue(13, 14, 15),
                                  color: const Color(0xFFDCE8FF),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== YOUTUBE VIDEO SECTION - LIKE EXAM1 PAGE =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _responsiveValue(20, 25, 30),
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
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }

  Widget _buildExamCard({
    required Map<String, dynamic> exam,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Exam3 screen when card is tapped
         Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Exam3Screen(
            examData: {
              'title': exam['title'],
              'description': exam['description'],
              'type': exam['type'],
            },
          ),
        ),
      );
      },
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
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
              width: _responsiveValue(40, 48, 56),
              height: _responsiveValue(40, 48, 56),
              decoration: BoxDecoration(
                color: (exam['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(_scale(10)),
              ),
              child: Center(
                child: Text(
                  exam['icon'] as String,
                  style: TextStyle(
                    fontSize: _responsiveValue(20, 24, 28),
                  ),
                ),
              ),
            ),
            SizedBox(height: _scale(8)),

            // Title
            Expanded(
              child: Text(
                exam['title'] as String,
                style: TextStyle(
                  fontSize: _responsiveValue(13, 15, 16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF003366),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: _scale(6)),

            // Description
            Text(
              exam['description'] as String,
              style: TextStyle(
                fontSize: _responsiveValue(11, 12, 13),
                color: const Color(0xFF666666),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: _scale(10)),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Type Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _scale(8),
                    vertical: _scale(4),
                  ),
                  decoration: BoxDecoration(
                    color: (exam['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(_scale(6)),
                  ),
                  child: Text(
                    (exam['type'] as String).toUpperCase(),
                    style: TextStyle(
                      fontSize: _responsiveValue(9, 10, 11),
                      fontWeight: FontWeight.w600,
                      color: exam['color'] as Color,
                    ),
                  ),
                ),

                // Arrow Icon
                Container(
                  width: _responsiveValue(20, 24, 28),
                  height: _responsiveValue(20, 24, 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(_scale(12)),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: _responsiveValue(14, 16, 18),
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