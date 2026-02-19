// lib/pages/Exam/Exam3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/footer.dart';
import 'Exam_details.dart';
import 'Exam_institution_list.dart';

class Exam3Screen extends StatefulWidget {
  final Map<String, dynamic>? examData;
  
  const Exam3Screen({
    super.key,
    this.examData,
  });

  @override
  State<Exam3Screen> createState() => _Exam3ScreenState();
}

class _Exam3ScreenState extends State<Exam3Screen> {
  int _activeBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // Banner data
  final List<Map<String, dynamic>> banners = [
    {
      'title': 'Build Your Career With',
      'line1': 'TOP TUITION CENTRE',
      'line2': 'PROGRAMS',
      'info': 'Apply Now',
      'color': Color(0xFF4A90E2),
    },
    {
      'title': 'Exam Preparation Made Easy',
      'line1': 'EXPERT GUIDANCE',
      'line2': '& SUPPORT',
      'info': 'Enroll Today',
      'color': Color(0xFF50C878),
    },
    {
      'title': 'Learn. Innovate. Succeed.',
      'line1': 'QUALITY',
      'line2': 'EDUCATION',
      'info': 'Join Now',
      'color': Color(0xFFFF6B6B),
    },
  ];

  // Grid items
  final List<Map<String, dynamic>> gridItems = [
    {
      'title': 'Exam Details',
      'subtitle': 'Explore complete exam information',
      'icon': Icons.description,
      'color': Color(0xFF4A90E2),
      'route': 'ExamDetailsFull',
    },
    {
      'title': 'Institutions',
      'subtitle': 'Explore top tuition centers',
      'icon': Icons.business,
      'color': Color(0xFF50C878),
      'route': 'InstitutionsList',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll banners
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _activeBannerIndex + 1;
        if (nextPage >= banners.length) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
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
    final double bannerHeight = _responsiveValue(200, 260, 300);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;

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
                          'Exam Details',
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
                        // ===== BANNER SLIDER =====
                        SizedBox(
                          width: screenWidth,
                          height: bannerHeight,
                          child: PageView.builder(
                            controller: _bannerController,
                            itemCount: banners.length,
                            onPageChanged: (index) {
                              setState(() {
                                _activeBannerIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final banner = banners[index];
                              return Container(
                                width: screenWidth,
                                height: bannerHeight,
                                decoration: BoxDecoration(
                                  color: banner['color'] as Color,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      (banner['color'] as Color).withOpacity(0.9),
                                      (banner['color'] as Color).withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Decorative pattern
                                    Positioned(
                                      top: 20,
                                      right: 20,
                                      child: Opacity(
                                        opacity: 0.1,
                                        child: Icon(
                                          Icons.school,
                                          size: _scale(120),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Padding(
                                      padding: EdgeInsets.all(horizontalPadding),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            banner['title'] as String,
                                            style: TextStyle(
                                              color: const Color(0xFFE8F0FF),
                                              fontSize: _responsiveValue(12, 14, 16),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: _scale(8)),
                                          Text(
                                            banner['line1'] as String,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: _responsiveValue(20, 22, 24),
                                              fontWeight: FontWeight.w800,
                                              height: 1.1,
                                            ),
                                          ),
                                          Text(
                                            banner['line2'] as String,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: _responsiveValue(20, 22, 24),
                                              fontWeight: FontWeight.w800,
                                              height: 1.1,
                                            ),
                                          ),
                                          SizedBox(height: _scale(12)),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: _scale(16),
                                              vertical: _scale(8),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(_scale(20)),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              banner['info'] as String,
                                              style: TextStyle(
                                                color: const Color(0xFFFFD966),
                                                fontSize: _responsiveValue(12, 14, 15),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // ===== PAGINATION DOTS =====
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8FF),
                          ),
                          padding: EdgeInsets.symmetric(vertical: _scale(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(banners.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _activeBannerIndex == index ? _scale(16) : _scale(8),
                                height: _scale(8),
                                margin: EdgeInsets.symmetric(horizontal: _scale(4)),
                                decoration: BoxDecoration(
                                  color: _activeBannerIndex == index 
                                    ? const Color(0xFF0B5ED7) 
                                    : const Color(0xFFCCCCCC),
                                  borderRadius: BorderRadius.circular(_scale(4)),
                                ),
                              );
                            }),
                          ),
                        ),

                        // ===== 2 COLUMN GRID =====
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: gridItems.map((item) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: item == gridItems.first 
                                      ? _scale(8) 
                                      : 0,
                                    left: item == gridItems.last 
                                      ? _scale(8) 
                                      : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (item['route'] == 'ExamDetailsFull') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ExamDetailsFullScreen(
                                              examData: widget.examData,
                                            ),
                                          ),
                                        );
                                      } else if (item['route'] == 'InstitutionsList') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => InstitutionsListScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(_scale(22)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: _scale(8),
                                            offset: Offset(0, _scale(4)),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(_responsiveValue(20, 24, 28)),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: _scale(50),
                                            height: _scale(50),
                                            decoration: BoxDecoration(
                                              color: (item['color'] as Color).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(_scale(12)),
                                            ),
                                            child: Icon(
                                              item['icon'] as IconData,
                                              size: _scale(30),
                                              color: item['color'] as Color,
                                            ),
                                          ),
                                          SizedBox(height: _scale(12)),
                                          Text(
                                            item['title'] as String,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: _responsiveValue(14, 16, 18),
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF003366),
                                              height: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: _scale(6)),
                                          Text(
                                            item['subtitle'] as String,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: _responsiveValue(11, 12, 13),
                                              color: const Color(0xFF666666),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
}