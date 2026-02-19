// lib/pages/Collegecourse/Collegecourse4.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../Widgets/Footer.dart';

class Collegecourse4Screen extends StatefulWidget {
  final String? institute; // Optional institute parameter
  
  const Collegecourse4Screen({
    super.key,
    this.institute,
  });

  @override
  State<Collegecourse4Screen> createState() => _Collegecourse4ScreenState();
}

class _Collegecourse4ScreenState extends State<Collegecourse4Screen> {
  int _footerIndex = 0;
  int _activeBannerIndex = 0;
  int _rating = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  final TextEditingController _reviewController = TextEditingController();

  // Banner Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3',
  ];

  // Skills Data
  final List<String> skills = [
    'Atomic Design',
    'Prototyping',
    'User Research',
    'Auto-layout',
    'Figma Advanced',
    'Design Tokens',
  ];

  // Benefits Data
  final List<String> benefits = [
    'Eligible for Senior UI/UX Designer roles',
    'Avg. 30% salary increase post-certification',
    'Direct access to job placement network',
  ];

  // Reviews Data
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Student',
      'rating': 5,
      'comment': 'Very useful course with practical exposure.',
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
    _reviewController.dispose();
    super.dispose();
  }

  // Add header helper methods like Collegecourse2
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

  // Show URL launch message (temporary function)
  void _showLaunchMessage(String url, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message - $url'),
        duration: const Duration(seconds: 2),
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
        'name': 'Anonymous',
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

  // Star Widget
  Widget _buildStarRating(int rating, int activeStars, double size, Function(int)? onTap) {
    return Row(
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
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints - Updated to match Collegecourse2
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive dimensions using helper methods
    final double horizontalPadding = _getHorizontalPadding(context);
    final double bannerHeight = isDesktop ? 220 : (isTablet ? 300 : 180);
    final double maxContentWidth = isDesktop ? 800 : double.infinity;
    final double videoHeight = isDesktop ? 320 : (isTablet ? 260 : 200);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
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
                          'Course Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Share Button - Keep it but with consistent styling
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share feature coming soon')),
                          );
                        },
                        icon: Icon(
                          Icons.share_outlined,
                          size: 22, // Slightly smaller to fit better
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
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
                                          ],
                                        ),
                                      );
                                    },
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
                                  ? const Color(0xFF2563EB) 
                                  : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // ===== COURSE CARD =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            isTablet ? 24 : 16,
                            horizontalPadding,
                            isTablet ? 24 : 16,
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
                                'DESIGN SKILL',
                                style: TextStyle(
                                  color: const Color(0xFFDCE8FF),
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Advanced UI/UX Design Systems',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? (isDesktop ? 32 : 28) : 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Department of Creative Arts',
                                style: TextStyle(
                                  color: const Color(0xFFDCE8FF),
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== SKILLS SECTION =====
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Skills You Will Gain',
                                style: TextStyle(
                                  fontSize: isTablet ? (isDesktop ? 22 : 20) : 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: skills.map((skill) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 16 : 12,
                                      vertical: isTablet ? 8 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF2FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      skill,
                                      style: TextStyle(
                                        color: const Color(0xFF2563EB),
                                        fontSize: isTablet ? 14 : 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // ===== INFO CARDS =====
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isTablet ? 20 : 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Duration Card
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: EdgeInsets.all(isTablet ? 16 : 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.access_time_outlined,
                                        size: 20,
                                        color: Color(0xFF2563EB),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Duration',
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '12 Weeks',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Self-paced Online',
                                        style: TextStyle(
                                          fontSize: isTablet ? 13 : 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Eligibility Card
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: EdgeInsets.all(isTablet ? 16 : 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.verified_outlined,
                                        size: 20,
                                        color: Color(0xFF2563EB),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Eligibility',
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Intermediate',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Basic Figma knowledge',
                                        style: TextStyle(
                                          fontSize: isTablet ? 13 : 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== VIEW ON MAP BUTTON =====
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: ElevatedButton(
                            onPressed: () => _showLaunchMessage(
                              'https://www.google.com/maps/search/?api=1&query=training+institute',
                              'Open Map',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0052A2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: isTablet ? 15 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_outlined),
                                const SizedBox(width: 8),
                                Text(
                                  'View on Map',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ===== CAREER BENEFITS =====
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isTablet ? 20 : 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Career Benefits',
                                style: TextStyle(
                                  fontSize: isTablet ? (isDesktop ? 22 : 20) : 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Column(
                                children: benefits.map((benefit) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Color(0xFF16A34A),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            benefit,
                                            style: TextStyle(
                                              fontSize: isTablet ? 15 : 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // ===== ACTION BUTTONS =====
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isTablet ? 10 : 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Call Us Button
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ElevatedButton(
                                    onPressed: () => _showLaunchMessage(
                                      'tel:+919999999999',
                                      'Call Us',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFc25c5c),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isTablet ? 15 : 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.call_outlined),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Call Us',
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // WhatsApp Button
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: ElevatedButton(
                                    onPressed: () => _showLaunchMessage(
                                      'https://wa.me/919999999999',
                                      'Open WhatsApp',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isTablet ? 15 : 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Using an icon that looks similar to WhatsApp
                                        const Icon(Icons.chat_outlined),
                                        const SizedBox(width: 6),
                                        Text(
                                          'WhatsApp',
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== RATE & REVIEW SECTION =====
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isTablet ? 20 : 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rate & Review',
                                style: TextStyle(
                                  fontSize: isTablet ? (isDesktop ? 22 : 20) : 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // Star Rating
                              Center(
                                child: _buildStarRating(5, _rating, isTablet ? 32 : 28, (stars) {
                                  setState(() {
                                    _rating = stars;
                                  });
                                }),
                              ),
                              const SizedBox(height: 16),
                              
                              // Review Input
                              TextField(
                                controller: _reviewController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Write your review...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Submit Review Button
                              ElevatedButton(
                                onPressed: _submitReview,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 14 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Submit Review',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== REVIEWS LIST =====
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isTablet ? 10 : 8,
                          ),
                          child: Column(
                            children: _reviews.map((review) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFF3F4F6)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          review['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        _buildStarRating(5, review['rating'] as int, 14, null),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      review['comment'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // ===== VIDEO SECTION HEADER =====
                        Container(
                          margin: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
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

                        // ===== SPACER FOR FOOTER =====
                      //  SizedBox(height: isDesktop ? 30 : (isTablet ? 20 : 16)),
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
}