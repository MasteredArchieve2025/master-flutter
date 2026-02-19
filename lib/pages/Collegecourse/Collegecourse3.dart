// lib/pages/Collegecourse/Collegecourse3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../Widgets/Footer.dart';
import 'Collegecourse4.dart';

class Collegecourse3Screen extends StatefulWidget {
  final String? course; // Optional course parameter
  
  const Collegecourse3Screen({
    super.key,
    this.course,
  });

  @override
  State<Collegecourse3Screen> createState() => _Collegecourse3ScreenState();
}

class _Collegecourse3ScreenState extends State<Collegecourse3Screen> {
  int _footerIndex = 0;
  int _activeBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  bool _showAllInstitutes = false;

  // Banner Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3',
  ];

  // Institutes Data
  final List<Map<String, dynamic>> institutes = [
    {
      'name': 'Global Tech Academy',
      'location': 'London, UK · Online',
      'rating': 4.9,
      'subtitle': 'Certified Partner',
      'image': 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f',
    },
    {
      'name': 'Modern Skills Institute',
      'location': 'New York, USA · Offline',
      'rating': 4.7,
      'subtitle': '2.4k Students',
      'image': 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
    },
    {
      'name': 'EduStream University',
      'location': 'Global · Online',
      'rating': 4.5,
      'subtitle': 'Flexible Schedule',
      'image': 'https://images.unsplash.com/photo-1509062522246-3755977927d7',
    },
    {
      'name': 'Data Science Center',
      'location': 'Singapore · Hybrid',
      'rating': 4.8,
      'subtitle': 'Fast Track',
      'image': 'https://images.unsplash.com/photo-1551650975-87deedd944c3',
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

  // Add these header helper methods like Collegecourse2
  double _getHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 64; // Desktop
    if (screenWidth >= 768) return 58; // Tablet
    return 52; // Mobile
  }

  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 19;
    if (screenWidth >= 768) return 18;
    return 17;
  }

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
    
    // Responsive dimensions using helper methods
    final double horizontalPadding = _getHorizontalPadding(context);
    final double bannerHeight = isDesktop ? 220 : (isTablet ? 300 : 180);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;
    final double videoHeight = isDesktop ? 320 : (isTablet ? 260 : 200);
    
    // Get visible institutes based on showAll state
    final visibleInstitutes = _showAllInstitutes 
        ? institutes 
        : institutes.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // ===== UPDATED HEADER (Matches Collegecourse2) =====
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
                    // Back Button - Fixed size like Collegecourse2
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24, // Fixed size like Collegecourse2
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    
                    // Header Title - Centered like Collegecourse2
                    Expanded(
                      child: Center(
                        child: Text(
                          'Institutes', // You can change this title as needed
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Spacer for symmetry like Collegecourse2
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? horizontalPadding : 0,
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
                                  
                                  // Overlay gradient
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

                        // ===== BLUE INFO BANNER =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            isDesktop ? 0 : horizontalPadding,
                            isTablet ? 20 : 16,
                            isDesktop ? 0 : horizontalPadding,
                            isTablet ? 20 : 16,
                          ),
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C73AC),
                            borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Course Institutes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find the best institutes near you',
                                style: TextStyle(
                                  color: const Color(0xFFDCE8FF),
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== INSTITUTE LIST =====
                        Column(
                          children: visibleInstitutes.map((institute) {
                            return _buildInstituteCard(
                              institute: institute,
                              isTablet: isTablet,
                              isDesktop: isDesktop,
                              horizontalPadding: horizontalPadding,
                            );
                          }).toList(),
                        ),

                        // ===== SEE ALL / SEE LESS BUTTON =====
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 0 : horizontalPadding,
                            vertical: isTablet ? 12 : 10,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAllInstitutes = !_showAllInstitutes;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _showAllInstitutes ? 'See less' : 'See all',
                                    style: TextStyle(
                                      color: const Color(0xFF0B5ED7),
                                      fontSize: isTablet ? 16 : 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _showAllInstitutes 
                                        ? Icons.expand_less 
                                        : Icons.chevron_right,
                                    size: isTablet ? 18 : 16,
                                    color: const Color(0xFF0B5ED7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ===== VIDEO SECTION HEADER =====
                        Container(
                          margin: EdgeInsets.only(
                            left: isDesktop ? 0 : horizontalPadding,
                            right: isDesktop ? 0 : horizontalPadding,
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

                        // ===== YOUTUBE VIDEO =====
                        Container(
                          margin: EdgeInsets.only(
                            left: isDesktop ? 0 : horizontalPadding,
                            right: isDesktop ? 0 : horizontalPadding,
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

                        // ===== SPACER FOR FOOTER =====
                       // SizedBox(height: isDesktop ? 30 : (isTablet ? 20 : 16)),
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

  Widget _buildInstituteCard({
    required Map<String, dynamic> institute,
    required bool isTablet,
    required bool isDesktop,
    required double horizontalPadding,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Collegecourse4 with selected institute
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Collegecourse4Screen(
              institute: institute['name'],
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${institute['name']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isDesktop ? 0 : horizontalPadding,
          isTablet ? 0 : 0,
          isDesktop ? 0 : horizontalPadding,
          isTablet ? 18 : 14,
        ),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Institute Image
            Container(
              width: isTablet ? (isDesktop ? 90 : 85) : 70,
              height: isTablet ? (isDesktop ? 90 : 85) : 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                color: const Color(0xFFE0E0E0),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1524995997946-a1c2e315a42f'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            SizedBox(width: isTablet ? 16 : 12),
            
            // Institute Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institute['name'] as String,
                    style: TextStyle(
                      fontSize: isTablet ? (isDesktop ? 19 : 18) : 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 6 : 4),
                  
                  Text(
                    institute['location'] as String,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: const Color(0xFF5F6F81),
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 8 : 6),
                  
                  Row(
                    children: [
                      // Rating
                      Text(
                        '⭐ ${institute['rating']}',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.black,
                        ),
                      ),
                      
                      SizedBox(width: isTablet ? 10 : 8),
                      
                      // Subtitle
                      Text(
                        institute['subtitle'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? (isDesktop ? 14 : 13) : 12,
                          color: const Color(0xFF0B5ED7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Chevron Icon
            Icon(
              Icons.chevron_right,
              size: isTablet ? 22 : 18,
              color: const Color(0xFF0B5ED7),
            ),
          ],
        ),
      ),
    );
  }
}