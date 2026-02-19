// lib/pages/College/College1.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Add this import for Timer
import '../../Widgets/Footer.dart';
import 'College2.dart';

class College1Screen extends StatefulWidget {
  const College1Screen({super.key});

  @override
  State<College1Screen> createState() => _College1ScreenState();
}

class _College1ScreenState extends State<College1Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Banner Ads Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  // Categories Data
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Engineering',
      'icon': Icons.engineering,
      'color': Color(0xFF0B5ED7),
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    },
    {
      'name': 'Arts & Science',
      'icon': Icons.palette,
      'color': Color(0xFFDC2626),
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    },
    {
      'name': 'Medical',
      'icon': Icons.medical_services,
      'color': Color(0xFF059669),
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    },
    {
      'name': 'Polytechnic',
      'icon': Icons.computer,
      'color': Color(0xFF7C3AED),
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    },
    {
      'name': 'Law',
      'icon': Icons.gavel,
      'color': Color(0xFFEA580C),
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    },
    {
      'name': 'Veterinary',
      'icon': Icons.pets,
      'color': Color(0xFF0891B2),
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    },
  ];

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
                        // ===== TOP AUTO SCROLL AD BANNER =====
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

                        // ===== BODY =====
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 0 : horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isTablet ? 20 : 16,
                                  bottom: isTablet ? 16 : 12,
                                  left: isDesktop ? horizontalPadding : 0,
                                  right: isDesktop ? horizontalPadding : 0,
                                ),
                                child: Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 26 : (isTablet ? 24 : 20),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0C2F63),
                                  ),
                                ),
                              ),

                              // Categories Grid
                              Padding(
                                padding: EdgeInsets.only(
                                  left: isDesktop ? horizontalPadding : (isTablet ? 20 : 10),
                                  right: isDesktop ? horizontalPadding : (isTablet ? 20 : 10),
                                  bottom: isTablet ? 40 : 30,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double availableWidth = constraints.maxWidth;
                                    final int crossAxisCount = isDesktop ? 3 : (isTablet ? 3 : 2);
                                    final double spacing = isTablet ? 20 : 16;
                                    final double runSpacing = isTablet ? 35 : 30;
                                    final double totalSpacing = spacing * (crossAxisCount - 1);
                                    final double itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
                                    
                                    return Wrap(
                                      spacing: spacing,
                                      runSpacing: runSpacing,
                                      alignment: WrapAlignment.center,
                                      children: categories.map((category) {
                                        return SizedBox(
                                          width: itemWidth,
                                          child: _buildCategoryCard(
                                            category: category,
                                            isTablet: isTablet,
                                            isDesktop: isDesktop,
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== VIDEO AD - EDGE TO EDGE =====
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

                        // Spacer for Footer
                        //SizedBox(height: isDesktop ? 80 : 120),
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

  Widget _buildCategoryCard({
    required Map<String, dynamic> category,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: () {
       Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => College2Screen(
        category: category,
      ),
    ),
  );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${category['name']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 15)),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon Container
            Container(
              width: isDesktop ? 80 : (isTablet ? 75 : 60),
              height: isDesktop ? 80 : (isTablet ? 75 : 60),
              margin: EdgeInsets.only(
                bottom: isDesktop ? 15 : (isTablet ? 12 : 10),
              ),
              decoration: BoxDecoration(
                color: category['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category['icon'] as IconData,
                size: isDesktop ? 40 : (isTablet ? 40 : 30),
                color: Colors.white,
              ),
            ),
            
            // Category Name
            Text(
              category['name'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0C2F63),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Text(
              category['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 14 : (isTablet ? 14 : 12),
                color: Colors.grey,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}