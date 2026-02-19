// lib/pages/College/College3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../Widgets/Footer.dart';
import 'College4.dart';
import '../Collegecourse/Collegecourse1.dart';

class College3Screen extends StatefulWidget {
  final String? degree;
  
  const College3Screen({
    super.key,
    this.degree,
  });

  @override
  State<College3Screen> createState() => _College3ScreenState();
}

class _College3ScreenState extends State<College3Screen> {
  int _footerIndex = 0;
  int _activeIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // Banner Data
  final List<Map<String, dynamic>> bannerData = [
    {
      'title': 'Unlock Your Future at',
      'line1': 'ARUNACHALA MATRICULATION',
      'line2': 'SCHOOL',
      'info': 'Admissions Open for 2025-2026',
    },
    {
      'title': 'Build Your Career With',
      'line1': 'TOP TUTION CENTRE',
      'line2': 'PROGRAMS',
      'info': 'Apply Now',
    },
    {
      'title': 'Learn. Innovate. Lead.',
      'line1': 'QUALITY',
      'line2': 'EDUCATION',
      'info': 'Join Today',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll banners
    _bannerTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _activeIndex + 1;
        if (nextPage >= bannerData.length) nextPage = 0;
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
    final double bannerHeight = isDesktop ? 300 : (isTablet ? 300 : 200);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

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
                          'Colleges',
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
                            top: isDesktop ? 0 : 0,
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
                              child: PageView.builder(
                                controller: _bannerController,
                                itemCount: bannerData.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _activeIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final item = bannerData[index];
                                  return Stack(
                                    children: [
                                      // Background Image/Color
                                      Container(
                                        width: screenWidth,
                                        color: const Color(0xFF4C73AC),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.school,
                                                size: 80,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Banner ${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      // Overlay with text
                                      Container(
                                        width: screenWidth,
                                        color: Colors.black.withOpacity(0.45),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isTablet ? 40 : 20,
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Title
                                              Text(
                                                item['title'],
                                                style: TextStyle(
                                                  color: const Color(0xFFE8F0FF),
                                                  fontSize: isTablet ? 16 : 14,
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 6),
                                              
                                              // Line 1
                                              Text(
                                                item['line1'],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isTablet ? 28 : 22,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              
                                              // Line 2
                                              Text(
                                                item['line2'],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isTablet ? 28 : 22,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 10),
                                              
                                              // Info
                                              Text(
                                                item['info'],
                                                style: TextStyle(
                                                  color: const Color(0xFFFFD966),
                                                  fontSize: isTablet ? 16 : 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // ===== PAGINATION DOTS =====
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(bannerData.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _activeIndex == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _activeIndex == index 
                                  ? const Color(0xFF0B5ED7) 
                                  : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // ===== 2 COLUMN GRID =====
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? horizontalPadding : horizontalPadding,
                            vertical: isTablet ? 24 : 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // View Colleges Card
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: isTablet ? 12 : 8,
                                    top: isTablet ? 20 : 15,
                                  ),
                                  child: _buildGridCard(
                                    icon: Icons.business,
                                    title: 'View Colleges',
                                    subtitle: 'Explore Colleges for you',
                                    isTablet: isTablet,
                                    isDesktop: isDesktop,
                                    onTap: () {
                                        Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => College4Screen(
        degree: 'All Colleges',
      ),
    ),
  );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Navigate to College4 - ${widget.degree ?? 'All Colleges'}'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              // View Courses Card
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: isTablet ? 12 : 8,
                                    top: isTablet ? 20 : 15,
                                  ),
                                  child: _buildGridCard(
                                    icon: Icons.book,
                                    title: 'View Courses',
                                    subtitle: 'Explore Colleges for all Degrees',
                                    isTablet: isTablet,
                                    isDesktop: isDesktop,
                                    onTap: () {
                                      // Navigate to Collegecourse1
                                       Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const Collegecourse1Screen(),
    ),
  );

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Navigate to Collegecourse1'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== YOUTUBE VIDEO - EDGE TO EDGE =====
                        Container(
                          margin: EdgeInsets.only(
                            top: isTablet ? 70 : 55,
                            bottom: 0,
                          ),
                          width: double.infinity,
                          height: isDesktop ? 400 : (isTablet ? 320 : 250),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://img.youtube.com/vi/qYapc_bkfxw/maxresdefault.jpg',
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

                        // Spacer for Footer
                       // SizedBox(height: isDesktop ? 60 : 80),
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

  Widget _buildGridCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isTablet,
    required bool isDesktop,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 32 : 27)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              size: isDesktop ? 48 : (isTablet ? 48 : 40),
              color: const Color(0xFF0B5ED7),
            ),
            
            SizedBox(height: isDesktop ? 12 : (isTablet ? 12 : 10)),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 22 : (isTablet ? 20 : 16),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            
            SizedBox(height: isDesktop ? 6 : (isTablet ? 6 : 4)),
            
            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 15 : (isTablet ? 14 : 12),
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}