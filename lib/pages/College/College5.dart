// lib/pages/College/College5.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../Widgets/Footer.dart';

class College5Screen extends StatefulWidget {
  final Map<String, dynamic> college;
  
  const College5Screen({
    super.key,
    required this.college,
  });

  @override
  State<College5Screen> createState() => _College5ScreenState();
}

class _College5ScreenState extends State<College5Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  String _activeTab = "Placement";
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Banner Ads Data
  final List<String> bannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  // Reviews Data
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Student Review',
      'rating': 5,
      'comment': 'Good placement support and faculty guidance.',
    },
  ];

  // Tabs Data
  final List<String> tabs = ["All", "Dept", "Placement", "Academic", "Facilities", "Admission", "About"];

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
    _reviewController.dispose();
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

  // Simple URL launcher function
  void _launchURL(String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would launch: $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMap() {
    _launchURL('https://www.google.com/maps/search/?api=1&query=Arunachala+College+of+Engineering');
  }

  void _callNow() {
    _launchURL('tel:9876543210');
  }

  void _openWhatsApp() {
    _launchURL('https://wa.me/919876543210');
  }

  void _submitReview() {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please give rating and write review'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _reviews.insert(0, {
        'name': 'Anonymous User',
        'rating': _rating,
        'comment': _reviewController.text,
      });
      _rating = 0;
      _reviewController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review submitted successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _renderContent() {
    if (_activeTab != "Placement") {
      return _buildSectionCard(
        title: _activeTab,
        child: Text(
          'Details about $_activeTab will be available here.',
          style: TextStyle(
            fontSize: _isTablet ? 15 : 13,
            color: const Color(0xFF5F6F81),
            height: 1.5,
          ),
        ),
      );
    }

    return _buildSectionCard(
      title: 'Placement',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training & Placement: Shaping Future-Ready Engineers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _isTablet ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0052A2),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Placement Officer Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Officer Image
              Container(
                width: _isTablet ? (_isDesktop ? 120 : 110) : 90,
                height: _isTablet ? (_isDesktop ? 150 : 140) : 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(_isTablet ? 10 : 8),
                ),
                child: Icon(
                  Icons.person,
                  size: _isTablet ? 40 : 30,
                  color: const Color(0xFF666666),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Officer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mr. C.D. Prabakar',
                      style: TextStyle(
                        fontSize: _isTablet ? 17 : 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Training & Placement Officer',
                      style: TextStyle(
                        fontSize: _isTablet ? 14 : 12,
                        color: const Color(0xFF5F6F81),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'The Training & Placement Department prepares students '
                      'for professional success through skill development, '
                      'industry exposure, and placement assistance.',
                      style: TextStyle(
                        fontSize: _isTablet ? 15 : 13,
                        color: const Color(0xFF5F6F81),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'The institution consistently produces industry-ready '
            'graduates with strong technical and professional skills.',
            style: TextStyle(
              fontSize: _isTablet ? 15 : 13,
              color: const Color(0xFF5F6F81),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Responsive variables
  late bool _isTablet;
  late bool _isDesktop;
  late double _horizontalPadding;
  late double _bannerHeight;
  late double _maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    _isTablet = screenWidth >= 768;
    _isDesktop = screenWidth >= 1024;
    
    // Responsive dimensions
    _horizontalPadding = _getHorizontalPadding(context);
    _bannerHeight = _isDesktop ? 220 : (_isTablet ? 300 : 180);
    _maxContentWidth = _isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
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
                borderRadius: _isDesktop
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )
                    : null,
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: _maxContentWidth),
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
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
                          'College Details',
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
                      maxWidth: _maxContentWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== TOP ADS =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _isDesktop ? 8 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: _isDesktop
                                ? BorderRadius.circular(12)
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: _isDesktop
                                ? BorderRadius.circular(12)
                                : BorderRadius.zero,
                            child: SizedBox(
                              height: _bannerHeight,
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

                        // ===== HERO CARD =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            _isDesktop ? 0 : _horizontalPadding,
                            _isTablet ? 20 : 16,
                            _isDesktop ? 0 : _horizontalPadding,
                            0,
                          ),
                          padding: EdgeInsets.all(_isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C73AC),
                            borderRadius: BorderRadius.circular(_isTablet ? 20 : 18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arunachala College of Engineering',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _isDesktop ? 26 : (_isTablet ? 24 : 20),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              Text(
                                'For Women · Autonomous Institution',
                                style: TextStyle(
                                  color: const Color(0xFFDCE8FF),
                                  fontSize: _isTablet ? 14 : 12,
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Info Rows
                              Row(
                                children: [
                                  Icon(
                                    Icons.school,
                                    size: _isTablet ? 18 : 16,
                                    color: const Color(0xFFE8F0FF),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Engineering & Technology Programs',
                                    style: TextStyle(
                                      color: const Color(0xFFE8F0FF),
                                      fontSize: _isTablet ? 14 : 12,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: _isTablet ? 18 : 16,
                                    color: const Color(0xFFE8F0FF),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Nagercoil, Tamil Nadu',
                                    style: TextStyle(
                                      color: const Color(0xFFE8F0FF),
                                      fontSize: _isTablet ? 14 : 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ===== TABS =====
                        Container(
                          height: _isTablet ? 60 : 50,
                          margin: EdgeInsets.only(
                            top: _isTablet ? 12 : 10,
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tabs.length,
                            itemBuilder: (context, index) {
                              final tab = tabs[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activeTab = tab;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _isTablet ? 18 : 16,
                                    vertical: _isTablet ? 10 : 8,
                                  ),
                                  margin: EdgeInsets.only(
                                    left: index == 0 ? _horizontalPadding : 0,
                                    right: index == tabs.length - 1 ? _horizontalPadding : 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _activeTab == tab 
                                      ? const Color(0xFF0B5ED7) 
                                      : const Color(0xFFE8F0FF),
                                    borderRadius: BorderRadius.circular(_isTablet ? 22 : 20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      tab,
                                      style: TextStyle(
                                        fontSize: _isTablet ? 15 : 14,
                                        color: _activeTab == tab ? Colors.white : const Color(0xFF0B5ED7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // ===== TAB CONTENT =====
                        _renderContent(),

                        // ===== MAP BUTTON =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            _isDesktop ? 0 : _horizontalPadding,
                            _isTablet ? 20 : 16,
                            _isDesktop ? 0 : _horizontalPadding,
                            0,
                          ),
                          child: ElevatedButton(
                            onPressed: _openMap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B5ED7),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: _isTablet ? 16 : 14,
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  size: _isTablet ? 20 : 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'View on Map',
                                  style: TextStyle(
                                    fontSize: _isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ===== CALL & WHATSAPP =====
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            _isDesktop ? 0 : _horizontalPadding,
                            _isTablet ? 12 : 10,
                            _isDesktop ? 0 : _horizontalPadding,
                            0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _callNow,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE53E3E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(_isTablet ? 16 : 14),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: _isTablet ? 16 : 14,
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.call,
                                        size: _isTablet ? 20 : 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Call',
                                        style: TextStyle(
                                          fontSize: _isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              SizedBox(width: _isTablet ? 12 : 8),
                              
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _openWhatsApp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(_isTablet ? 16 : 14),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: _isTablet ? 16 : 14,
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.message,
                                        size: _isTablet ? 20 : 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'WhatsApp',
                                        style: TextStyle(
                                          fontSize: _isTablet ? 16 : 14,
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
                          child: Column(
                            children: [
                              // Star Rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _rating = index + 1;
                                      });
                                    },
                                    icon: Icon(
                                      index < _rating ? Icons.star : Icons.star_border,
                                      size: _isTablet ? 32 : 28,
                                      color: const Color(0xFFFFD700),
                                    ),
                                  );
                                }),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Review Input
                              TextField(
                                controller: _reviewController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Write your review...',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF999999),
                                    fontSize: _isTablet ? 16 : 14,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFF),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(_isTablet ? 12 : 10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(_isTablet ? 16 : 12),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Submit Button
                              ElevatedButton(
                                onPressed: _submitReview,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B5ED7),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: _isTablet ? 14 : 12,
                                  ),
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.send,
                                      size: _isTablet ? 20 : 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Submit Review',
                                      style: TextStyle(
                                        fontSize: _isTablet ? 16 : 14,
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
                        _buildSectionCard(
                          title: 'Student Reviews',
                          child: Column(
                            children: _reviews.map((review) {
                              return _buildReviewCard(review);
                            }).toList(),
                          ),
                        ),

                        // ===== YOUTUBE VIDEO - EDGE TO EDGE =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _isTablet ? 40 : 32,
                            bottom: 0,
                          ),
                          width: double.infinity,
                          height: _isDesktop ? 360 : (_isTablet ? 280 : 220),
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
                       // SizedBox(height: _isTablet ? 30 : 20), // Minimal space for footer
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

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        _isDesktop ? 0 : _horizontalPadding,
        _isTablet ? 20 : 16,
        _isDesktop ? 0 : _horizontalPadding,
        0,
      ),
      padding: EdgeInsets.all(_isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_isTablet ? 18 : 16),
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
            title,
            style: TextStyle(
              fontSize: _isTablet ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.all(_isTablet ? 16 : 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(_isTablet ? 14 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['name'],
                style: TextStyle(
                  fontSize: _isTablet ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004780),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating'] ? Icons.star : Icons.star_border,
                    size: _isTablet ? 16 : 14,
                    color: const Color(0xFFFFD700),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: _isTablet ? 15 : 13,
              color: const Color(0xFF5F6F81),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
