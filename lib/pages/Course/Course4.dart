// lib/pages/Course/Course4.dart
import 'package:flutter/material.dart';
import 'dart:async';

class Course4Screen extends StatefulWidget {
  final Map<String, dynamic>? course; // Optional course parameter
  
  const Course4Screen({
    super.key,
    this.course,
  });

  @override
  State<Course4Screen> createState() => _Course4ScreenState();
}

class _Course4ScreenState extends State<Course4Screen> {
  int _activeBannerIndex = 0;
  int _rating = 0;
  final PageController _bannerController = PageController();
  final TextEditingController _reviewController = TextEditingController();
  Timer? _bannerTimer;

  // Banner Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3',
  ];

  // Reviews Data
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Student Review',
      'rating': 5,
      'comment': 'Good training quality and practical sessions.',
    },
  ];

  // Course Data
  final List<String> coursesOffered = [
    'Web Development',
    'Full Stack Development',
    'Python',
    'Data Science',
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll banners
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
    _reviewController.dispose();
    super.dispose();
  }

  // Show URL dialog (since we removed url_launcher)
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

  // Show phone dialog
  void _showPhoneDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call'),
        content: Text('Would you like to call: $phoneNumber'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling: $phoneNumber')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  // Submit Review
  void _submitReview() {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give rating and write review')),
      );
      return;
    }

    setState(() {
      _reviews.insert(0, {
        'name': 'Anonymous User',
        'rating': _rating,
        'comment': _reviewController.text.trim(),
      });
      _rating = 0;
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully')),
    );
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

  // Star Widget
  Widget _buildStarRating(int rating, int activeStars, double size, Function(int)? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(rating, (index) {
        return GestureDetector(
          onTap: onTap != null ? () => onTap(index + 1) : null,
          child: Icon(
            index < activeStars ? Icons.star : Icons.star_outline,
            size: size,
            color: const Color(0xFFFFD700),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double bannerHeight = _responsiveValue(180, 220, 260);
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
          'Course Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: _scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.15),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                            size: 60,
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

              // ===== HERO CARD =====
              Container(
                margin: EdgeInsets.all(horizontalPadding),
                padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C73AC),
                  borderRadius: BorderRadius.circular(_scale(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo Placeholder
                    Container(
                      width: _responsiveValue(80, 100, 120),
                      height: _responsiveValue(60, 70, 80),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_scale(8)),
                      ),
                      child: const Center(
                        child: Text(
                          'AK',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0175D3),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Course Name
                    Text(
                      widget.course?['name'] ?? 'AK Technologies',
                      style: TextStyle(
                        fontSize: _responsiveValue(18, 22, 26),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Tagline
                    Text(
                      'IT Training & Placement Support',
                      style: TextStyle(
                        fontSize: _responsiveValue(12, 14, 16),
                        color: const Color(0xFFDCE8FF),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFFB703),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.course?['rating']?.toString() ?? '4.5',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFFE8F0FF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.course?['location'] ?? 'Chennai · 1.2 km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE8F0FF),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Website
                    GestureDetector(
                      onTap: () => _showUrlDialog('www.ak.com'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.language_outlined,
                            size: 14,
                            color: Color(0xFFE8F0FF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'www.ak.com',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE8F0FF),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== ABOUT INSTITUTE =====
              _buildSectionCard(
                title: 'About Institute',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Founded in 2015, AK Technologies focuses on IT training and placement support. '
                      'The institute offers technical courses including Python, Machine Learning, and live project training.',
                      style: TextStyle(
                        fontSize: _responsiveValue(13, 14, 15),
                        color: const Color(0xFF5F6F81),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
                horizontalPadding: horizontalPadding,
              ),

              // ===== COURSES OFFERED =====
              _buildSectionCard(
                title: 'Courses Offered',
                content: Wrap(
                  spacing: _responsiveValue(8, 10, 12),
                  runSpacing: _responsiveValue(8, 10, 12),
                  children: coursesOffered.map((course) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _responsiveValue(12, 14, 16),
                        vertical: _responsiveValue(6, 8, 10),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(_scale(10)),
                      ),
                      child: Text(
                        course,
                        style: TextStyle(
                          fontSize: _responsiveValue(12, 13, 14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B5ED7),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                horizontalPadding: horizontalPadding,
              ),

              // ===== MODE =====
              _buildSectionCard(
                title: 'Mode',
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: isMobile 
                        ? MainAxisAlignment.center 
                        : MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildModeCard(
                            icon: Icons.business_outlined,
                            title: 'Offline',
                            subtitle: 'Classroom Training',
                          ),
                        ),
                        SizedBox(width: isMobile ? 12 : 16),
                        Expanded(
                          child: _buildModeCard(
                            icon: Icons.videocam_outlined,
                            title: 'Online',
                            subtitle: 'Live Sessions',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                horizontalPadding: horizontalPadding,
              ),

              // ===== BENEFITS =====
              _buildSectionCard(
                title: 'Benefits',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '• Career growth\n• Industry-ready skills\n• Flexible learning',
                      style: TextStyle(
                        fontSize: _responsiveValue(13, 14, 15),
                        color: const Color(0xFF5F6F81),
                        height: 2.0,
                      ),
                    ),
                  ],
                ),
                horizontalPadding: horizontalPadding,
              ),

              // ===== CALL & WHATSAPP BUTTONS =====
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: _responsiveValue(16, 20, 24),
                ),
                child: Row(
                  children: [
                    // Call Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showPhoneDialog('+91 93841 52923'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFe51515),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: _responsiveValue(14, 16, 18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_scale(14)),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFe51515).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.call),
                            SizedBox(width: _scale(8)),
                            Text(
                              'Call Now',
                              style: TextStyle(
                                fontSize: _responsiveValue(14, 15, 16),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(width: _responsiveValue(12, 16, 20)),
                    
                    // WhatsApp Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showUrlDialog('https://wa.me/919384152923'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: _responsiveValue(14, 16, 18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_scale(14)),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF25D366).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat),
                            SizedBox(width: _scale(8)),
                            Text(
                              'WhatsApp',
                              style: TextStyle(
                                fontSize: _responsiveValue(14, 15, 16),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== RATE & REVIEW =====
              _buildSectionCard(
                title: 'Rate & Review',
                content: Column(
                  children: [
                    // Star Rating
                    _buildStarRating(5, _rating, _responsiveValue(28, 32, 36), (stars) {
                      setState(() {
                        _rating = stars;
                      });
                    }),
                    
                    const SizedBox(height: 12),
                    
                    // Review Input
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        hintStyle: const TextStyle(color: Color(0xFF888888)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_scale(12)),
                          borderSide: const BorderSide(color: Color(0xFFE8F0FF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_scale(12)),
                          borderSide: const BorderSide(color: Color(0xFF0B5ED7)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFF),
                        contentPadding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Submit Review Button
                    ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B5ED7),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: _responsiveValue(12, 14, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_scale(30)),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF0B5ED7).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send),
                          SizedBox(width: _scale(8)),
                          Text(
                            'Submit Review',
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                horizontalPadding: horizontalPadding,
              ),

              // ===== STUDENT REVIEWS =====
              _buildSectionCard(
                title: 'Student Reviews',
                content: Column(
                  children: _reviews.map((review) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(_scale(12)),
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFF0B5ED7),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review['name'] as String,
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF004780),
                                ),
                              ),
                              _buildStarRating(5, review['rating'] as int, _scale(14), null),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review['comment'] as String,
                            style: TextStyle(
                              fontSize: _responsiveValue(13, 14, 15),
                              color: const Color(0xFF5F6F81),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                horizontalPadding: horizontalPadding,
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
                        fontSize: _responsiveValue(18, 20, 22),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // ===== YOUTUBE VIDEO - LIKE COURSE3 =====
              Container(
                margin: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 0,
                  bottom: 0, // Reduced bottom margin
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
                  child: GestureDetector(
                    onTap: () => _showUrlDialog('https://www.youtube.com/embed/NONufn3jgXI'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    required double horizontalPadding,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: _responsiveValue(12, 16, 20),
      ),
      padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_scale(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: _responsiveValue(16, 18, 20),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF004780),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(_responsiveValue(12, 16, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(_scale(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _scale(20),
            color: const Color(0xFF0B5ED7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: _responsiveValue(14, 16, 18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B5ED7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: _responsiveValue(11, 12, 13),
              color: const Color(0xFF5F6F81),
            ),
          ),
        ],
      ),
    );
  }
}