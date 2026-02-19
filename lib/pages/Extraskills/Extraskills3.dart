// lib/pages/Extraskills/Extraskills3.dart
import 'package:flutter/material.dart';
import '../../widgets/footer.dart';
import 'Extraskills4.dart';

class Extraskills3Screen extends StatefulWidget {
  final String skillTitle;
  final String skillDescription;

  const Extraskills3Screen({
    super.key,
    required this.skillTitle,
    required this.skillDescription,
  });

  @override
  State<Extraskills3Screen> createState() => _Extraskills3ScreenState();
}

class _Extraskills3ScreenState extends State<Extraskills3Screen> {
  int _currentCarouselIndex = 0;
  final PageController _pageController = PageController();

  // Banner Ads
  final List<String> _bannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  // Studio Data
  final List<Map<String, dynamic>> _studios = [
    {
      'id': 1,
      'name': 'eMotion Dance Studio',
      'location': 'Nagercoil, Tamil Nadu',
      'features': ['Certified Trainers', 'Practical Sessions', '5.0 Rating'],
    },
    {
      'id': 2,
      'name': 'StepUp Dance Academy',
      'location': 'Marthandam, Tamil Nadu',
      'features': ['Expert Trainers', 'Modern Facilities', 'Flexible Timing'],
    },
    {
      'id': 3,
      'name': 'Rhythm & Beats Studio',
      'location': 'Kanyakumari, Tamil Nadu',
      'features': ['Professional Setup', 'Group Classes', 'Performance Opportunities'],
    },
    {
      'id': 4,
      'name': 'Grace Fine Arts Center',
      'location': 'Thuckalay, Tamil Nadu',
      'features': ['Art & Dance Combo', 'Stage Training', 'Competition Prep'],
    },
    {
      'id': 5,
      'name': 'Creative Movement Academy',
      'location': 'Colachel, Tamil Nadu',
      'features': ['Beginner Friendly', 'Online Classes', 'Certification'],
    },
    {
      'id': 6,
      'name': 'Traditional Arts Institute',
      'location': 'Padmanabhapuram, Tamil Nadu',
      'features': ['Heritage Styles', 'Cultural Events', 'Workshops'],
    },
  ];

  // YouTube Video URL
  final String _youtubeVideoUrl = "https://www.youtube.com/embed/NONufn3jgXI?rel=0&modestbranding=1";

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients && mounted) {
        int nextPage = _currentCarouselIndex + 1;
        if (nextPage >= _bannerAds.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
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
    final screenHeight = MediaQuery.of(context).size.height;
    
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;

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
                height: _responsiveValue(52, 72, 80),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: _responsiveValue(24, 26, 28),
                        color: Colors.white,
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.skillTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(18, 22, 24),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Spacer for symmetry
                    SizedBox(width: _responsiveValue(40, 44, 48)),
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
                        // ===== BANNER CAROUSEL =====
                        Padding(
                          padding: EdgeInsets.only(
                            top: _responsiveValue(16, 20, 24),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: _responsiveValue(200, 280, 300),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _bannerAds.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentCarouselIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: horizontalPadding,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(_bannerAds[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                              // Dots Indicator
                              SizedBox(height: _responsiveValue(12, 16, 20)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _bannerAds.asMap().entries.map((entry) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: _currentCarouselIndex == entry.key 
                                      ? _responsiveValue(20, 22, 24) 
                                      : _responsiveValue(8, 9, 10),
                                    height: _responsiveValue(8, 9, 10),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: _responsiveValue(4, 5, 6),
                                    ),
                                    decoration: BoxDecoration(
                                      color: _currentCarouselIndex == entry.key
                                        ? const Color(0xFF0B5ED7)
                                        : const Color(0xFFCCCCCC),
                                      borderRadius: BorderRadius.circular(_responsiveValue(4, 5, 6)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // ===== SKILL DESCRIPTION =====
                        if (widget.skillDescription.isNotEmpty)
                          Container(
                            margin: EdgeInsets.all(horizontalPadding),
                            padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F8FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE3F2FD),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: _responsiveValue(20, 22, 24),
                                  color: const Color(0xFF1976D2),
                                ),
                                SizedBox(width: _responsiveValue(12, 14, 16)),
                                Expanded(
                                  child: Text(
                                    widget.skillDescription,
                                    style: TextStyle(
                                      fontSize: _responsiveValue(14, 15, 16),
                                      color: const Color(0xFF333333),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ===== STUDIOS HEADER =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            _responsiveValue(24, 28, 32),
                            horizontalPadding,
                            _responsiveValue(12, 16, 20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Studios',
                                style: TextStyle(
                                  fontSize: _responsiveValue(20, 22, 24),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF004780),
                                ),
                              ),
                              Text(
                                '${_studios.length} studios found',
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== STUDIOS LIST =====
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Column(
                            children: _studios.map((studio) {
                              return _buildStudioCard(studio: studio);
                            }).toList(),
                          ),
                        ),

                        // ===== YOUTUBE VIDEO SECTION - UPDATED LIKE EXAM1 =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _responsiveValue(20, 30, 40),
                            bottom: 0, // Reduced bottom margin
                          ),
                          width: double.infinity,
                          height: isDesktop ? 360 : (isTablet ? 280 : 220), // Same height as Exam1
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

                        // Footer Spacer
                       // SizedBox(height: _responsiveValue(100, 120, 140)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildStudioCard({
    required Map<String, dynamic> studio,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Extraskills4Screen(
              studio: studio,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: EdgeInsets.only(bottom: _responsiveValue(16, 18, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Studio Logo/Icon
              Container(
                width: _responsiveValue(70, 80, 90),
                height: _responsiveValue(70, 80, 90),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD1E9FF),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.business,
                    size: _responsiveValue(40, 45, 50),
                    color: const Color(0xFF0052A2),
                  ),
                ),
              ),
              
              SizedBox(width: _responsiveValue(16, 18, 20)),
              
              // Studio Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Studio Name
                    Text(
                      studio['name'] as String,
                      style: TextStyle(
                        fontSize: _responsiveValue(18, 20, 22),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007BFF),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: _responsiveValue(8, 9, 10)),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: _responsiveValue(16, 17, 18),
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            studio['location'] as String,
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              color: const Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: _responsiveValue(12, 14, 16)),
                    
                    // Features
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (studio['features'] as List<String>).map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _responsiveValue(10, 12, 14),
                            vertical: _responsiveValue(5, 6, 7),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE3F2FD),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: _responsiveValue(12, 13, 14),
                              color: const Color(0xFF0052A2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    // Rating and Actions Row
                    SizedBox(height: _responsiveValue(12, 14, 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: _responsiveValue(18, 20, 22),
                              color: const Color(0xFFFFB800),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: _responsiveValue(14, 15, 16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        
                        // View Details Button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _responsiveValue(16, 18, 20),
                            vertical: _responsiveValue(8, 9, 10),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0052A2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show URL dialog for YouTube
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
}