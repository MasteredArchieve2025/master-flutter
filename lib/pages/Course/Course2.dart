// lib/pages/Course/Course2.dart
import 'package:flutter/material.dart';
import 'dart:async';
 import 'Course3.dart';


class Course2Screen extends StatefulWidget {
  final List<dynamic> sections;
  
  const Course2Screen({
    super.key,
    required this.sections,
  });

  @override
  State<Course2Screen> createState() => _Course2ScreenState();
}

class _Course2ScreenState extends State<Course2Screen> {
  int _activeBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // Banner Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3',
  ];

  // Course Meta Data
  final Map<String, Map<String, String>> courseMeta = {
    "Web Development": {
      "icon": "web",
      "desc": "Build modern websites and web apps",
    },
    "Python Programming": {
      "icon": "code",
      "desc": "Learn Python for real-world applications",
    },
    "Data Science": {
      "icon": "show_chart",
      "desc": "Analyze data and build insights",
    },
    "Cybersecurity": {
      "icon": "security",
      "desc": "Protect systems from digital threats",
    },
    "Cloud Computing": {
      "icon": "cloud",
      "desc": "Master cloud services and deployment",
    },
    "Nursing Fundamentals": {
      "icon": "medical_services",
      "desc": "Essential skills for nursing professionals",
    },
    "Public Health": {
      "icon": "local_hospital",
      "desc": "Community health and disease prevention",
    },
    "Nutrition & Dietetics": {
      "icon": "restaurant",
      "desc": "Science of nutrition and healthy eating",
    },
    "Medical Terminology": {
      "icon": "medical_information",
      "desc": "Learn medical language and terms",
    },
    "First Aid & CPR": {
      "icon": "favorite",
      "desc": "Emergency response and life-saving techniques",
    },
    "Digital Marketing": {
      "icon": "campaign",
      "desc": "Online marketing strategies and tools",
    },
    "Business Analytics": {
      "icon": "bar_chart",
      "desc": "Data-driven business decision making",
    },
    "Project Management": {
      "icon": "checklist",
      "desc": "Plan and execute projects successfully",
    },
    "Finance Fundamentals": {
      "icon": "attach_money",
      "desc": "Understand finance & accounting basics",
    },
    "Entrepreneurship": {
      "icon": "lightbulb",
      "desc": "Start and grow your own business",
    },
    "English Grammar & Writing": {
      "icon": "edit",
      "desc": "Master English language skills",
    },
    "Public Speaking": {
      "icon": "mic",
      "desc": "Confident communication and presentation",
    },
    "Business Communication": {
      "icon": "email",
      "desc": "Professional communication in business",
    },
    "French for Beginners": {
      "icon": "translate",
      "desc": "Start learning French language basics",
    },
    "Creative Writing": {
      "icon": "menu_book",
      "desc": "Develop storytelling and writing skills",
    },
    "Mechanical Engineering Basics": {
      "icon": "settings",
      "desc": "Fundamentals of mechanical systems",
    },
    "Electrical Systems": {
      "icon": "bolt",
      "desc": "Understanding electrical circuits",
    },
    "Civil Engineering": {
      "icon": "architecture",
      "desc": "Infrastructure and construction principles",
    },
    "Robotics": {
      "icon": "smart_toy",
      "desc": "Design and program robots",
    },
    "3D Printing & CAD Design": {
      "icon": "precision_manufacturing",
      "desc": "Create 3D models and prototypes",
    },
    "UI/UX Design": {
      "icon": "palette",
      "desc": "Design user-friendly digital interfaces",
    },
    "Graphic Design": {
      "icon": "brush",
      "desc": "Visual communication and design",
    },
    "Animation": {
      "icon": "movie",
      "desc": "Bring characters and stories to life",
    },
    "Photography": {
      "icon": "camera_alt",
      "desc": "Master the art of photography",
    },
    "Interior Design": {
      "icon": "chair",
      "desc": "Create beautiful living spaces",
    },
    "Time Management": {
      "icon": "schedule",
      "desc": "Maximize productivity and efficiency",
    },
    "Mindfulness & Meditation": {
      "icon": "self_improvement",
      "desc": "Stress reduction and mental wellness",
    },
    "Fitness & Wellness": {
      "icon": "fitness_center",
      "desc": "Physical health and exercise routines",
    },
    "Personal Finance": {
      "icon": "account_balance_wallet",
      "desc": "Money management and financial planning",
    },
    "Goal Setting": {
      "icon": "target",
      "desc": "Achieve your personal and professional goals",
    },
  };

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
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double bannerHeight = _responsiveValue(190, 300, 260);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    final double videoHeight = _responsiveValue(200, 280, 300);
    
    // Calculate columns based on screen size
    final int columns = isDesktop ? 3 : (isTablet ? 2 : 2);
    final double gap = _responsiveValue(12, 16, 20);
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
          'Course Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: _scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
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

                        // ===== SECTIONS =====
                        for (int idx = 0; idx < widget.sections.length; idx++)
                          _buildSection(
                            section: widget.sections[idx],
                            index: idx,
                            horizontalPadding: horizontalPadding,
                            cardWidth: cardWidth,
                            gap: gap,
                            columns: columns,
                          ),

                        // ===== VIDEO SECTION HEADER =====
                        Container(
                          margin: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: _responsiveValue(20, 24, 30),
                            bottom: _responsiveValue(12, 16, 20),
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

                        // ===== MINIMAL SPACER =====
                      //  SizedBox(height: _responsiveValue(20, 30, 40)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required Map<String, dynamic> section,
    required int index,
    required double horizontalPadding,
    required double cardWidth,
    required double gap,
    required int columns,
  }) {
    final List<String> items = (section['items'] as List<dynamic>?)?.cast<String>() ?? [];

    return Column(
      children: [
        // Section Header
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: index == 0 
              ? _responsiveValue(16, 20, 24)
              : _responsiveValue(24, 28, 32),
          ),
          padding: EdgeInsets.symmetric(
            vertical: _responsiveValue(14, 16, 18),
            horizontal: _responsiveValue(16, 20, 24),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFCFE5FA),
            borderRadius: BorderRadius.circular(_scale(14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              section['title'] as String? ?? 'Course Section',
              style: TextStyle(
                fontSize: _responsiveValue(18, 22, 26),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B5AA7),
              ),
            ),
          ),
        ),

        // Cards Grid
        Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Wrap(
            spacing: gap,
            runSpacing: _responsiveValue(12, 16, 20),
            alignment: WrapAlignment.start,
            children: items.map((item) {
              final meta = courseMeta[item] ?? {
                "icon": "menu_book",
                "desc": "Explore this professional course",
              };

              return SizedBox(
                width: cardWidth,
                child: _buildCourseCard(
                  title: item,
                  meta: meta,
                ),
              );
            }).toList(),
          ),
        ),

        // Spacing after each section
        SizedBox(height: _responsiveValue(16, 20, 24)),
      ],
    );
  }

  Widget _buildCourseCard({
    required String title,
    required Map<String, String> meta,
  }) {
    // Get appropriate icon
    IconData getIcon(String iconName) {
      switch (iconName) {
        case "web": return Icons.web;
        case "code": return Icons.code;
        case "show_chart": return Icons.show_chart;
        case "security": return Icons.security;
        case "cloud": return Icons.cloud;
        case "medical_services": return Icons.medical_services;
        case "local_hospital": return Icons.local_hospital;
        case "restaurant": return Icons.restaurant;
        case "medical_information": return Icons.medical_information;
        case "favorite": return Icons.favorite;
        case "campaign": return Icons.campaign;
        case "bar_chart": return Icons.bar_chart;
        case "checklist": return Icons.checklist;
        case "attach_money": return Icons.attach_money;
        case "lightbulb": return Icons.lightbulb;
        case "edit": return Icons.edit;
        case "mic": return Icons.mic;
        case "email": return Icons.email;
        case "translate": return Icons.translate;
        case "menu_book": return Icons.menu_book;
        case "settings": return Icons.settings;
        case "bolt": return Icons.bolt;
        case "architecture": return Icons.architecture;
        case "smart_toy": return Icons.smart_toy;
        case "precision_manufacturing": return Icons.precision_manufacturing;
        case "palette": return Icons.palette;
        case "brush": return Icons.brush;
        case "movie": return Icons.movie;
        case "camera_alt": return Icons.camera_alt;
        case "chair": return Icons.chair;
        case "schedule": return Icons.schedule;
        case "self_improvement": return Icons.self_improvement;
        case "fitness_center": return Icons.fitness_center;
        case "account_balance_wallet": return Icons.account_balance_wallet;
        case "target": return Icons.flag;
        default: return Icons.menu_book;
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate to Course3 with selected course
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Course3Screen(
              title: title,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to $title'),
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
            // Gradient Icon Container
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
                getIcon(meta["icon"] ?? "menu_book"),
                size: _scale(26),
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: _scale(10)),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: _scale(15),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004780),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: _scale(4)),
            
            // Description
            Text(
              meta["desc"] ?? "Explore this professional course",
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