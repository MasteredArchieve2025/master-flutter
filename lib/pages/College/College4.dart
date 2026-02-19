// lib/pages/College/College4.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../Widgets/Footer.dart';
import 'College5.dart';

class College4Screen extends StatefulWidget {
  final String degree;
  
  const College4Screen({
    super.key,
    required this.degree,
  });

  @override
  State<College4Screen> createState() => _College4ScreenState();
}

class _College4ScreenState extends State<College4Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  String _activeTab = "All";
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Banner Ads Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  // Data
  final List<Map<String, dynamic>> allColleges = [
    {
      'id': '1',
      'name': 'Arunachala College of Engineering For Women',
      'location': 'Nagercoil · 2.4 km',
      'type': 'Private',
      'category': 'All',
    },
    {
      'id': '2',
      'name': 'Arunachala College of Engineering For Women',
      'location': 'Nagercoil · 3.1 km',
      'type': 'Private',
      'category': 'All',
    },
  ];

  final List<Map<String, dynamic>> govtUniversities = [
    {
      'id': '3',
      'name': 'Government College of Technology',
      'location': 'Coimbatore · 4.8 km',
      'type': 'Govt',
      'category': 'Govt',
    },
  ];

  final List<Map<String, dynamic>> autonomousUniversities = [
    {
      'id': '4',
      'name': 'PSG College of Technology',
      'location': 'Coimbatore · 5.2 km',
      'type': 'Autonomous',
      'category': 'Autonomous',
    },
  ];

  List<Map<String, dynamic>> get _colleges {
    if (_activeTab == "Govt") return govtUniversities;
    if (_activeTab == "Autonomous") return autonomousUniversities;
    return allColleges;
  }

  @override
  void initState() {
    super.initState();
    // Auto scroll ads
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adController.hasClients && mounted) {
        int nextPage = _activeAd + 1;
        if (nextPage >= bannerAds.length) nextPage = 0;
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

    return Scaffold(
      backgroundColor: Colors.white,
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
                          widget.degree,
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
                        // ===== TOP ADS =====
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
                              child: PageView.builder(
                                controller: _adController,
                                itemCount: bannerAds.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _activeAd = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: screenWidth,
                                    color: const Color(0xFFF0F0F0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 60,
                                            color: const Color(0xFF0B5ED7),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Advertisement ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Color(0xFF0B5ED7),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Dots Indicator
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(bannerAds.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _activeAd == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: _activeAd == index 
                                  ? const Color(0xFF0B5ED7) 
                                  : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // ===== FILTERS =====
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? horizontalPadding : (isTablet ? 24 : 12),
                            vertical: isTablet ? 20 : 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Filters Button
                              Container(
                                width: (screenWidth - (isDesktop ? 80 : (isTablet ? 48 : 24))) / 2,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 14 : 12,
                                  vertical: isTablet ? 10 : 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFCCCCCC),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Filters',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: isTablet ? 18 : 16,
                                      color: const Color(0xFF333333),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Select Button
                              Container(
                                width: (screenWidth - (isDesktop ? 80 : (isTablet ? 48 : 24))) / 2,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 14 : 12,
                                  vertical: isTablet ? 10 : 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFCCCCCC),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Select',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: isTablet ? 18 : 16,
                                      color: const Color(0xFF333333),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== TABS =====
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: const Color(0xFFEEEEEE),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['All', 'Govt', 'Autonomous'].map((tab) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activeTab = tab;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    bottom: isTablet ? 12 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _activeTab == tab 
                                          ? const Color(0xFF0052A2) 
                                          : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    tab == "Govt" 
                                      ? "Govt Universities" 
                                      : tab == "Autonomous" 
                                        ? "Autonomous Universities" 
                                        : "All",
                                    style: TextStyle(
                                      fontSize: isDesktop ? 15 : (isTablet ? 16 : 14),
                                      color: _activeTab == tab 
                                        ? const Color(0xFF0052A2) 
                                        : const Color(0xFF333333),
                                      fontWeight: _activeTab == tab 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // ===== COLLEGE LIST =====
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? horizontalPadding : horizontalPadding,
                            vertical: isTablet ? 16 : 12,
                          ),
                          child: Column(
                            children: _colleges.map((college) {
                              return _buildCollegeCard(
                                college: college,
                                isTablet: isTablet,
                                isDesktop: isDesktop,
                              );
                            }).toList(),
                          ),
                        ),

                        // ===== YOUTUBE VIDEO - EDGE TO EDGE =====
                        Container(
                          margin: EdgeInsets.only(
                            top: isTablet ? 40 : 30,
                            bottom: 0,
                          ),
                          width: double.infinity,
                          height: isDesktop ? 360 : (isTablet ? 280 : 220),
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

                        // ===== FOOTER SPACER =====
                        //SizedBox(height: isDesktop ? 40 : 60), // Reduced space
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

  Widget _buildCollegeCard({
    required Map<String, dynamic> college,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: () {
       Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => College5Screen(
        college: college,
      ),
    ),
  );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${college['name']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 18 : 14),
        padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 16 : 12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 20 : 16)),
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
            // College Logo/Icon
            Container(
              width: isDesktop ? 90 : (isTablet ? 85 : 70),
              height: isDesktop ? 90 : (isTablet ? 85 : 70),
              decoration: BoxDecoration(
                color: const Color(0xFF0052A2),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: Icon(
                Icons.school,
                size: isDesktop ? 40 : (isTablet ? 40 : 30),
                color: Colors.white,
              ),
            ),
            
            SizedBox(width: isTablet ? 16 : 12),
            
            // College Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // College Name
                  Text(
                    college['name'],
                    style: TextStyle(
                      fontSize: isDesktop ? 19 : (isTablet ? 18 : 15),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: isTablet ? 6 : 4),
                  
                  // Location
                  Text(
                    '📍 ${college['location']}',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: const Color(0xFF5F6F81),
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 10 : 8),
                  
                  // Type Tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                      vertical: isTablet ? 5 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                    ),
                    child: Text(
                      college['type'],
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: const Color(0xFF0B5ED7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: isTablet ? 16 : 12),
            
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