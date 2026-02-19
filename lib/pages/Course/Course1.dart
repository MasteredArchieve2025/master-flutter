// lib/pages/Course/Course1.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../Widgets/Footer.dart';
// Temporarily comment out Course2 import since it might not exist
import 'Course2.dart';

class Course1Screen extends StatefulWidget {
  const Course1Screen({super.key});

  @override
  State<Course1Screen> createState() => _Course1ScreenState();
}

class _Course1ScreenState extends State<Course1Screen> {
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

  // Activities Data
  final List<Map<String, dynamic>> activities = [
    {
      'id': 1,
      'title': 'Computer & IT',
      'icon': Icons.laptop,
      'sections': [
        {
          'title': 'Computer & IT',
          'items': [
            'Web Development',
            'Python Programming',
            'Data Science',
            'Cybersecurity',
            'Cloud Computing',
          ],
        },
      ],
    },
    {
      'id': 2,
      'title': 'Health Science',
      'icon': Icons.favorite_border,
      'sections': [
        {
          'title': 'Health Science',
          'items': [
            'Nursing Fundamentals',
            'Public Health',
            'Nutrition & Dietetics',
            'Medical Terminology',
            'First Aid & CPR',
          ],
        },
      ],
    },
    {
      'id': 3,
      'title': 'Business & Management',
      'icon': Icons.business_center,
      'sections': [
        {
          'title': 'Business & Management',
          'items': [
            'Digital Marketing',
            'Business Analytics',
            'Project Management',
            'Finance Fundamentals',
            'Entrepreneurship',
          ],
        },
      ],
    },
    {
      'id': 4,
      'title': 'Language & Communication',
      'icon': Icons.language,
      'sections': [
        {
          'title': 'Language & Communication',
          'items': [
            'English Grammar & Writing',
            'Public Speaking',
            'Business Communication',
            'French for Beginners',
            'Creative Writing',
          ],
        },
      ],
    },
    {
      'id': 5,
      'title': 'Engineering & Technical',
      'icon': Icons.settings,
      'sections': [
        {
          'title': 'Engineering & Technical',
          'items': [
            'Mechanical Engineering Basics',
            'Electrical Systems',
            'Civil Engineering',
            'Robotics',
            '3D Printing & CAD Design',
          ],
        },
      ],
    },
    {
      'id': 6,
      'title': 'Arts & Design',
      'icon': Icons.brush,
      'sections': [
        {
          'title': 'Arts & Design',
          'items': [
            'UI/UX Design',
            'Graphic Design',
            'Animation',
            'Photography',
            'Interior Design',
          ],
        },
      ],
    },
    {
      'id': 7,
      'title': 'Lifestyle & Personal Development',
      'icon': Icons.person,
      'sections': [
        {
          'title': 'Lifestyle & Personal Development',
          'items': [
            'Time Management',
            'Mindfulness & Meditation',
            'Fitness & Wellness',
            'Personal Finance',
            'Goal Setting',
          ],
        },
      ],
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

  // Add this method to handle footer navigation
  void _handleFooterNavigation(int index, BuildContext context) {
    // Handle navigation based on footer index
    switch (index) {
      case 0: // Home
        Navigator.pushNamed(context, '/');
        break;
      case 1: // Dashboard
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 2: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
      case 3: // Settings
        Navigator.pushNamed(context, '/settings');
        break;
      // Add more cases as needed based on your Footer widget implementation
    }
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(12, 16, 24);
    final double bannerHeight = _responsiveValue(190, 300, 260);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    final double videoHeight = _responsiveValue(200, 280, 300);
    
    // Calculate columns based on screen size
    final int columns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final double gap = _responsiveValue(8, 12, 16);
    final double cardWidth = (screenWidth - (horizontalPadding * 2) - (gap * (columns - 1))) / columns;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0052A2),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: _scale(24),
          ),
        ),
        title: Text(
          'Courses',
          style: TextStyle(
            color: Colors.white,
            fontSize: _scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          SizedBox(width: _scale(40)), // Spacer for alignment
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
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
                              width: _activeBannerIndex == index ? 16 : 8,
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

                        // ===== COURSE GRID =====
                        Container(
                          padding: EdgeInsets.all(horizontalPadding),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Wrap(
                                spacing: gap,
                                runSpacing: _responsiveValue(14, 16, 20),
                                alignment: WrapAlignment.spaceBetween,
                                children: activities.map((activity) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: _buildCourseCard(
                                      activity: activity,
                                      cardWidth: cardWidth,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        // ===== VIDEO SECTION HEADER =====
                        Container(
                          margin: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: _responsiveValue(30, 40, 50),
                            bottom: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Video',
                                style: TextStyle(
                                  fontSize: _responsiveValue(18, 20, 22),
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
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: 0,
                            bottom: _responsiveValue(40, 50, 60),
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

                        // ===== BOTTOM PADDING FOR FOOTER =====
                      //  SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // ===== FOOTER (FIXED AT BOTTOM) =====
            Footer(
              currentIndex: _footerIndex,
              onItemTapped: (index) {
                if (mounted) {
                  setState(() {
                    _footerIndex = index;
                  });
                  _handleFooterNavigation(index, context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required Map<String, dynamic> activity,
    required double cardWidth,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Course2Screen(
              sections: activity['sections'],
            ),
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to ${activity['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(_scale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_scale(14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: _scale(4),
              offset: Offset(0, _scale(2)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with Gradient
            Container(
              width: _scale(56),
              height: _scale(56),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2295D2), Color(0xFF284598)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(_scale(28)),
              ),
              child: Icon(
                activity['icon'] as IconData,
                size: _scale(26),
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: _scale(10)),
            
            // Title - Fixed textAlign issue
            Text(
              activity['title'] as String,
              style: TextStyle(
                fontSize: _scale(15),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004780),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: _scale(6)),
            
            // Description - Fixed textAlign issue
            Text(
              'Explore courses and skill development programs',
              style: TextStyle(
                fontSize: _scale(11),
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
    );
  }
}