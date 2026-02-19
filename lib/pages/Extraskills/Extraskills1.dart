// lib/pages/Extraskills/Extraskills1.dart
import 'package:flutter/material.dart';
import '../../widgets/footer.dart';
import 'Extraskills2.dart';

class Extraskills1Screen extends StatefulWidget {
  const Extraskills1Screen({super.key});

  @override
  State<Extraskills1Screen> createState() => _Extraskills1ScreenState();
}

class _Extraskills1ScreenState extends State<Extraskills1Screen> {
  int _currentCarouselIndex = 0;
  final PageController _pageController = PageController();

  // Banner Ads
  final List<String> _bannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  // Activities Data
  final List<Map<String, dynamic>> _activities = [
    {
      'id': 1,
      'title': 'Fine Arts',
      'icon': Icons.palette,
      'description': 'Drawing, Painting, Sculpture',
    },
    {
      'id': 2,
      'title': 'Driving Class',
      'icon': Icons.directions_car,
      'description': 'Learn driving skills',
    },
    {
      'id': 3,
      'title': 'Athlete',
      'icon': Icons.directions_run,
      'description': 'Sports and athletics',
    },
    {
      'id': 4,
      'title': 'Sports & Fitness',
      'icon': Icons.sports_soccer,
      'description': 'Football, Cricket, Yoga',
    },
    {
      'id': 5,
      'title': 'Home Science',
      'icon': Icons.local_laundry_service,
      'description': 'Cooking, Sewing, Home Management',
    },
    {
      'id': 6,
      'title': 'Other Classes',
      'icon': Icons.library_music,
      'description': 'Music, Photography, Writing',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll banner
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
    final int numColumns = isDesktop ? 4 : (isTablet ? 3 : 2);
    
    // Card dimensions
    final double cardWidth = (screenWidth - (horizontalPadding * 2) - 
                            (_responsiveValue(12, 16, 20) * (numColumns - 1))) / numColumns;

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
                        size: _responsiveValue(18, 26, 28),
                        color: Colors.white,
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          'Extra Skills',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(20, 22, 24),
                            fontWeight: FontWeight.w700,
                          ),
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
                                height: _responsiveValue(160, 240, 280),
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

                        // ===== ACTIVITIES GRID =====
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            _responsiveValue(24, 28, 32),
                            horizontalPadding,
                            _responsiveValue(24, 28, 32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Text(
                                'Skill Categories',
                                style: TextStyle(
                                  fontSize: _responsiveValue(20, 22, 24),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF003366),
                                ),
                              ),
                              SizedBox(height: _responsiveValue(8, 10, 12)),
                              
                              // Section Subtitle
                              Text(
                                'Explore different skill categories to enhance your abilities',
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
                                children: _activities.map((activity) {
                                  return _buildActivityCard(
                                    activity: activity,
                                    width: cardWidth,
                                  );
                                }).toList(),
                              ),
                            ],
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
                      //  SizedBox(height: _responsiveValue(80, 100, 120)),
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

  Widget _buildActivityCard({
    required Map<String, dynamic> activity,
    required double width,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Extraskills2Screen(
              categoryTitle: activity['title'] as String,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: width,
          padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
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
              color: const Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: _responsiveValue(56, 64, 72),
                height: _responsiveValue(56, 64, 72),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2295D2), Color(0xFF284598)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_responsiveValue(12, 14, 16)),
                ),
                child: Center(
                  child: Icon(
                    activity['icon'] as IconData,
                    size: _responsiveValue(28, 32, 36),
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: _responsiveValue(12, 14, 16)),

              // Title
              Text(
                activity['title'] as String,
                style: TextStyle(
                  fontSize: _responsiveValue(16, 17, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004780),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: _responsiveValue(8, 9, 10)),

              // Description
              Text(
                activity['description'] as String,
                style: TextStyle(
                  fontSize: _responsiveValue(12, 13, 14),
                  color: const Color(0xFF555555),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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