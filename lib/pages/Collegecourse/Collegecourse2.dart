// lib/pages/Collegecourse/Collegecourse2.dart
import 'package:flutter/material.dart';
import '../../Widgets/Footer.dart';
import 'dart:async';
import 'Collegecourse3.dart';

class Collegecourse2Screen extends StatefulWidget {
  final String? department; // Optional department parameter
  
  const Collegecourse2Screen({
    super.key,
    this.department,
  });

  @override
  State<Collegecourse2Screen> createState() => _Collegecourse2ScreenState();
}

class _Collegecourse2ScreenState extends State<Collegecourse2Screen> {
  int _footerIndex = 0;
  int _activeBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // Banner Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3',
  ];

  // Courses Data
  final List<Map<String, dynamic>> courses = [
    {
      'id': '1',
      'title': 'Full Stack Web Development',
      'tag': 'TRENDING',
      'tagColor': Color(0xFFE7F0FF),
      'tagText': Color(0xFF2563EB),
      'duration': '4-8 weeks • Online',
    },
    {
      'id': '2',
      'title': 'UI/UX Design Certification',
      'tag': 'RECOMMENDED',
      'tagColor': Color(0xFFE9F9EF),
      'tagText': Color(0xFF16A34A),
      'duration': '6 weeks • Offline',
    },
    {
      'id': '3',
      'title': 'Data Science',
      'tag': 'RECOMMENDED',
      'tagColor': Color(0xFFE9F9EF),
      'tagText': Color(0xFF16A34A),
      'duration': '6 weeks • Offline',
    },
    {
      'id': '4',
      'title': 'Cyber Security',
      'tag': 'RECOMMENDED',
      'tagColor': Color(0xFFE9F9EF),
      'tagText': Color(0xFF16A34A),
      'duration': '6 weeks • Offline',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll banners
    _bannerTimer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _activeBannerIndex + 1;
        if (nextPage >= bannerAds.length) nextPage = 0;
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

  // Responsive header height like IQ1
  double _getHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 64; // Desktop
    if (screenWidth >= 768) return 58; // Tablet
    return 52; // Mobile
  }

  // Responsive font size like IQ1
  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 19;
    if (screenWidth >= 768) return 18;
    return 17;
  }

  // Responsive horizontal padding like IQ1
  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 32;
    if (screenWidth >= 768) return 24;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive dimensions
    final double horizontalPadding = _getHorizontalPadding(context);
    final double bannerHeight = isDesktop ? 220 : (isTablet ? 300 : 180);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;
    final double videoHeight = isDesktop ? 320 : (isTablet ? 260 : 200);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER (Updated to match IQ1) =====
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
                borderRadius: isDesktop
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )
                    : null,
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: _getHeaderHeight(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button - Fixed size like IQ1
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24, // Fixed size like IQ1
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    
                    // Header Title - Centered like IQ1
                    Expanded(
                      child: Center(
                        child: Text(
                          'Extra-Value Courses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Spacer for symmetry like IQ1
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            // ===== MAIN CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== BANNER SLIDER =====
                        Container(
                          margin: EdgeInsets.only(
                            top: isDesktop ? 8 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: isDesktop
                                ? BorderRadius.circular(12)
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: isDesktop
                                ? BorderRadius.circular(12)
                                : BorderRadius.zero,
                            child: SizedBox(
                              height: bannerHeight,
                              child: Stack(
                                children: [
                                  // Banner PageView
                                  PageView.builder(
                                    controller: _bannerController,
                                    itemCount: bannerAds.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _activeBannerIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: screenWidth,
                                        color: const Color(0xFF4C73AC),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.school,
                                              size: 80,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Banner ${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              bannerAds[index],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  // Overlay gradient for better text readability
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.transparent,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ===== PAGINATION DOTS =====
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(bannerAds.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _activeBannerIndex == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _activeBannerIndex == index 
                                  ? const Color(0xFF0B5ED7) 
                                  : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // ===== COURSE CARDS =====
                        Container(
                          margin: EdgeInsets.only(
                            top: isTablet ? 24 : 20,
                            bottom: isTablet ? 30 : 20,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double availableWidth = constraints.maxWidth;
                              final int crossAxisCount = isDesktop ? 3 : 2;
                              final double spacing = isTablet ? 20 : 16;
                              final double totalSpacing = spacing * (crossAxisCount - 1);
                              final double itemWidth = (availableWidth - totalSpacing - (horizontalPadding * 2)) / crossAxisCount;
                              
                              return Wrap(
                                spacing: spacing,
                                runSpacing: isTablet ? 18 : 14,
                                alignment: WrapAlignment.center,
                                children: courses.map((course) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: _buildCourseCard(
                                      course: course,
                                      isTablet: isTablet,
                                      isDesktop: isDesktop,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        // ===== YOUTUBE VIDEO SECTION HEADER =====
                        Container(
                          margin: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: isDesktop ? 40 : (isTablet ? 32 : 24),
                            bottom: isDesktop ? 16 : (isTablet ? 12 : 8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Video',
                                style: TextStyle(
                                  fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== YOUTUBE VIDEO - EDGE TO EDGE WITH HORIZONTAL PADDING =====
                        Container(
                          margin: EdgeInsets.only(
                            top: 0,
                            bottom: 0,
                          ),
                          width: double.infinity,
                          height: videoHeight,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
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

                        // ===== MINIMAL SPACER FOR FOOTER =====
                        //SizedBox(height: isDesktop ? 30 : (isTablet ? 20 : 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== FOOTER =====
            Footer(
              currentIndex: _footerIndex,
              onItemTapped: (index) {
                setState(() {
                  _footerIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required Map<String, dynamic> course,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Collegecourse3 screen with selected course
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Collegecourse3Screen(
              course: course['title'],
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${course['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 18 : 14),
        padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 22 : (isTablet ? 20 : 18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 10,
                vertical: isTablet ? 5 : 4,
              ),
              decoration: BoxDecoration(
                color: course['tagColor'] as Color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                course['tag'] as String,
                style: TextStyle(
                  fontSize: isTablet ? 11 : 10,
                  fontWeight: FontWeight.w700,
                  color: course['tagText'] as Color,
                ),
              ),
            ),
            
            SizedBox(height: isDesktop ? 10 : (isTablet ? 10 : 8)),
            
            // Title
            Text(
              course['title'] as String,
              style: TextStyle(
                fontSize: isDesktop ? 17 : (isTablet ? 16 : 14),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: isDesktop ? 10 : (isTablet ? 10 : 8)),
            
            // Industry Skill Row
            Row(
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: isTablet ? 16 : 14,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  'Industry Skill',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: const Color(0xFF444444),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isTablet ? 6 : 4),
            
            // Duration Row
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: isTablet ? 16 : 14,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  course['duration'] as String,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: const Color(0xFF444444),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isDesktop ? 10 : (isTablet ? 10 : 8)),
            
            // Enroll Now Button
            ElevatedButton(
              onPressed: () {
                // Handle enroll action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Enrolling in ${course['title']}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052A2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isTablet ? 10 : 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                minimumSize: const Size(0, 0),
                elevation: 0,
              ),
              child: Text(
                'Enroll Now',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}