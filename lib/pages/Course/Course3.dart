// lib/pages/Course/Course3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'Course4.dart';

class Course3Screen extends StatefulWidget {
  final String? title; // Optional course title parameter

  const Course3Screen({
    super.key,
    this.title,
  });

  @override
  State<Course3Screen> createState() => _Course3ScreenState();
}

class _Course3ScreenState extends State<Course3Screen> {
  int _footerIndex = 0;
  int _activeBannerIndex = 0;
  String _selectedMode = "All";
  String _searchQuery = "";
  bool _showFilters = false;
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _bannerTimer;

  // Banner Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  // Course Data
  final List<Map<String, dynamic>> coursesData = [
    {
      'id': '1',
      'name': 'AK Technologies',
      'location': 'Chennai · 1.2 km',
      'rating': 4.5,
    },
    {
      'id': '2',
      'name': 'AK Technologies',
      'location': 'Bangalore · 2.5 km',
      'rating': 4.8,
    },
    {
      'id': '3',
      'name': 'AK Technologies',
      'location': 'Hyderabad · 4.0 km',
      'rating': 4.3,
    },
    {
      'id': '4',
      'name': 'AK Technologies',
      'location': 'Mumbai · 3.2 km',
      'rating': 4.6,
    },
    {
      'id': '5',
      'name': 'AK Technologies',
      'location': 'Delhi · 5.0 km',
      'rating': 4.2,
    },
    {
      'id': '6',
      'name': 'AK Technologies',
      'location': 'Pune · 2.8 km',
      'rating': 4.7,
    },
  ];

  // Categories
  final List<String> categories = [
    "All",
    "Online",
    "Offline",
    "Online & Offline"
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

    // Listen to search controller changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter courses based on search and mode
  List<Map<String, dynamic>> get filteredCourses {
    return coursesData.where((course) {
      final matchesSearch = _searchQuery.isEmpty ||
          course['name']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          course['location']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
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
    final bool isTablet = screenWidth >= 768;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double bannerHeight = _responsiveValue(180, 200, 220);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;
    final double videoHeight = _responsiveValue(200, 280, 320);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
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
          'Course Providers',
          style: TextStyle(
            color: Colors.white,
            fontSize: _scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.15),
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
                        SizedBox(
                          height: bannerHeight,
                          child: PageView.builder(
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
                        ),

                        // ===== PAGINATION DOTS =====
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(bannerAds.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _activeBannerIndex == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: _activeBannerIndex == index
                                    ? const Color(0xFF0B5ED7)
                                    : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // ===== SEARCH & FILTER ROW =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            _responsiveValue(16, 20, 24),
                            horizontalPadding,
                            _responsiveValue(16, 20, 24),
                          ),
                          child: Row(
                            children: [
                              // Search Container
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: _responsiveValue(8, 12, 16)),
                                  padding: EdgeInsets.all(
                                      _responsiveValue(10, 14, 16)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(_scale(12)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: _scale(16),
                                        color: const Color(0xFF666666),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Search by name or location...',
                                            hintStyle: TextStyle(
                                                color: Color(0xFF666666)),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: TextStyle(
                                            fontSize: _scale(14),
                                            color: const Color(0xFF333333),
                                          ),
                                        ),
                                      ),
                                      if (_searchQuery.isNotEmpty)
                                        IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: _scale(16),
                                            color: const Color(0xFF999999),
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Filter Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showFilters = !_showFilters;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(
                                      _responsiveValue(10, 14, 16)),
                                  decoration: BoxDecoration(
                                    color: _showFilters
                                        ? const Color(0xFF0B5ED7)
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(_scale(12)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.filter_alt,
                                        size: _scale(18),
                                        color: _showFilters
                                            ? Colors.white
                                            : const Color(0xFF0B5ED7),
                                      ),
                                      if (_showFilters) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          'Filters',
                                          style: TextStyle(
                                            fontSize: _scale(13),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== FILTER OPTIONS =====
                        if (_showFilters)
                          Container(
                            margin: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              _responsiveValue(16, 20, 24),
                            ),
                            padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_scale(14)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Filter Options',
                                  style: TextStyle(
                                    fontSize: _scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildFilterOption("All"),
                                    const SizedBox(width: 12),
                                    _buildFilterOption("Online"),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // ===== CATEGORIES =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            _responsiveValue(16, 20, 24),
                          ),
                          height: _scale(50),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return Container(
                                margin: EdgeInsets.only(
                                  right: index < categories.length - 1
                                      ? _responsiveValue(8, 12, 16)
                                      : 0,
                                ),
                                child: ChoiceChip(
                                  label: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: _scale(13),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  selected: _selectedMode == category,
                                  selectedColor: const Color(0xFF0B5ED7),
                                  backgroundColor: const Color(0xFFF1F3F6),
                                  labelStyle: TextStyle(
                                    color: _selectedMode == category
                                        ? Colors.white
                                        : const Color(0xFF5F6F81),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedMode = category;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(_scale(18)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // ===== COURSE LIST HEADER =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            _responsiveValue(12, 16, 20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Courses',
                                style: TextStyle(
                                  fontSize: _scale(18),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${filteredCourses.length} providers found',
                                style: TextStyle(
                                  fontSize: _scale(13),
                                  color: const Color(0xFF666666),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== COURSE LIST =====
                        if (filteredCourses.isEmpty)
                          // Empty State
                          Container(
                            margin: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              _responsiveValue(20, 30, 40),
                              horizontalPadding,
                              _responsiveValue(20, 30, 40),
                            ),
                            padding: EdgeInsets.all(_responsiveValue(32, 40, 48)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_scale(16)),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: _scale(48),
                                  color: const Color(0xFFCCCCCC),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses found',
                                  style: TextStyle(
                                    fontSize: _scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try changing your search or filter criteria',
                                  style: TextStyle(
                                    fontSize: _scale(12),
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // Course Cards
                          Column(
                            children: filteredCourses.map((course) {
                              return _buildCourseCard(
                                course: course,
                                horizontalPadding: horizontalPadding,
                                isTablet: isTablet,
                              );
                            }).toList(),
                          ),

                        // ===== VIDEO SECTION HEADER =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            _responsiveValue(20, 24, 28),
                            horizontalPadding,
                            _responsiveValue(12, 16, 20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Video',
                                style: TextStyle(
                                  fontSize: _scale(18),
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
                       // SizedBox(height: _responsiveValue(20, 30, 40)),
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

  Widget _buildFilterOption(String mode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _responsiveValue(16, 20, 24),
          vertical: _responsiveValue(10, 12, 14),
        ),
        decoration: BoxDecoration(
          color: _selectedMode == mode
              ? const Color(0xFF0B5ED7)
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(_scale(10)),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: _scale(12),
            fontWeight: FontWeight.w500,
            color:
                _selectedMode == mode ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required Map<String, dynamic> course,
    required double horizontalPadding,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Course4 with selected course
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Course4Screen(
              course: course,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to ${course['name']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          _responsiveValue(14, 18, 22),
        ),
        padding: EdgeInsets.all(_responsiveValue(14, 18, 22)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_scale(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Course Image
            Container(
              width: _scale(80),
              height: _scale(80),
              decoration: BoxDecoration(
                color: const Color(0xFF0175D3),
                borderRadius: BorderRadius.circular(_scale(12)),
              ),
              child: const Center(
                child: Text(
                  'AK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: _responsiveValue(14, 18, 22)),
            
            // Course Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course['name'] as String,
                          style: TextStyle(
                            fontSize: _scale(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Rating
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _responsiveValue(8, 10, 12),
                          vertical: _responsiveValue(4, 5, 6),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(_scale(12)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFFFFB703),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course['rating'].toString(),
                              style: TextStyle(
                                fontSize: _scale(12),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF5F6F81),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course['location'] as String,
                        style: TextStyle(
                          fontSize: _scale(12),
                          color: const Color(0xFF5F6F81),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tags
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _responsiveValue(10, 12, 14),
                      vertical: _responsiveValue(5, 6, 7),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(_scale(8)),
                    ),
                    child: Text(
                      'Online & Offline',
                      style: TextStyle(
                        fontSize: _scale(11),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0B5ED7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: _responsiveValue(12, 16, 20)),
            
            // Chevron Icon - FIXED: Removed duplicate 'const' keyword
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: Color(0xFF0B5ED7),
            ),
          ],
        ),
      ),
    );
  }
}