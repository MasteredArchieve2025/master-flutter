// lib/pages/College/College3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../Widgets/Footer.dart';
import 'College4.dart';
import '../Course/Course1.dart';

class College3Screen extends StatefulWidget {
  final String? degree;
  final int? categoryId;
  final int? degreeId;

  const College3Screen({
    super.key,
    this.degree,
    this.categoryId,
    this.degreeId,
  });

  @override
  State<College3Screen> createState() => _College3ScreenState();
}

class _College3ScreenState extends State<College3Screen> {
  int _footerIndex = 0;
  int _activeIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // Banner Ads Data
  final List<String> _defaultBannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;
  bool _isLoadingAds = true;

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    // Auto scroll banners
    _bannerTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _activeIndex + 1;
        if (nextPage >= bannerAds.length) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for collegepage3...');
    try {
      final response = await http.get(
        Uri.parse(
            'https://master-backend-18ik.onrender.com/api/advertisements?page=collegepage3'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          setState(() {
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
            }
            if (apiData['youtube_urls'] != null &&
                apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }
            _isLoadingAds = false;
          });
        } else {
          setState(() {
            _isLoadingAds = false;
          });
        }
      } else {
        setState(() {
          _isLoadingAds = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading advertisements: $e');
      setState(() {
        _isLoadingAds = false;
      });
    }
  }

  void _nextVideo() {
    if (_youtubeUrls.isEmpty) return;
    setState(() {
      _currentVideoIndex = (_currentVideoIndex + 1) % _youtubeUrls.length;
    });
  }

  void _previousVideo() {
    if (_youtubeUrls.isEmpty) return;
    setState(() {
      _currentVideoIndex =
          (_currentVideoIndex - 1 + _youtubeUrls.length) % _youtubeUrls.length;
    });
  }

  String _getVideoThumbnail(String url) {
    if (url.contains('youtube.com/embed/')) {
      final videoId = url.split('/').last;
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return url;
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
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
    final double bannerHeight = isDesktop ? 300 : (isTablet ? 300 : 200);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
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
                        // ===== BANNER SLIDER =====
                        Container(
                          margin: EdgeInsets.only(
                            top: isDesktop ? 0 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                isDesktop ? BorderRadius.circular(12) : null,
                          ),
                          child: ClipRRect(
                            borderRadius: isDesktop
                                ? BorderRadius.circular(12)
                                : BorderRadius.zero,
                            child: SizedBox(
                              height: bannerHeight,
                              child: PageView.builder(
                                controller: _bannerController,
                                itemCount: bannerAds.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _activeIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: screenWidth,
                                    color: const Color(0xFFF0F0F0),
                                    child: Image.network(
                                      bannerAds[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                              color: Color(0xFF0B5ED7)),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                        );
                                      },
                                    ),
                                  );
                                },
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
                              width: _activeIndex == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _activeIndex == index
                                    ? const Color(0xFF0B5ED7)
                                    : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // ===== 2 COLUMN GRID =====
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop
                                ? horizontalPadding
                                : horizontalPadding,
                            vertical: isTablet ? 24 : 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // View Colleges Card
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: isTablet ? 12 : 8,
                                    top: isTablet ? 20 : 15,
                                  ),
                                  child: _buildGridCard(
                                    icon: Icons.business,
                                    title: 'View Colleges',
                                    subtitle: 'Explore Colleges for you',
                                    isTablet: isTablet,
                                    isDesktop: isDesktop,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => College4Screen(
                                            degree:
                                                widget.degree ?? 'All Colleges',
                                            categoryId: widget.categoryId,
                                            degreeId: widget.degreeId,
                                          ),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Navigate to College4 - ${widget.degree ?? 'All Colleges'}'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // View Courses Card
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: isTablet ? 12 : 8,
                                    top: isTablet ? 20 : 15,
                                  ),
                                  child: _buildGridCard(
                                    icon: Icons.book,
                                    title: 'View Courses',
                                    subtitle:
                                        'Explore Colleges for all Degrees',
                                    isTablet: isTablet,
                                    isDesktop: isDesktop,
                                    onTap: () {
                                      // Navigate to Collegecourse1
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Course1Screen(),
                                        ),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Navigate to Collegecourse1'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== YOUTUBE VIDEO SECTION =====
                        if (_youtubeUrls.isNotEmpty) ...[
                          if (_youtubeUrls.length > 1)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: isTablet ? 16 : 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Videos',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 22 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _previousVideo,
                                        icon: const Icon(Icons.chevron_left,
                                            color: Color(0xFF0B5ED7)),
                                      ),
                                      Text(
                                        '${_currentVideoIndex + 1}/${_youtubeUrls.length}',
                                        style: const TextStyle(
                                          color: Color(0xFF0B5ED7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _nextVideo,
                                        icon: const Icon(Icons.chevron_right,
                                            color: Color(0xFF0B5ED7)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          // Add gap before video
                          SizedBox(height: isTablet ? 40 : 30),
                          // Video with no bottom padding
                          Container(
                            width: double.infinity,
                            height: isDesktop ? 400 : (isTablet ? 320 : 250),
                            child: CommonYoutubePlayer(
                              youtubeUrl: _youtubeUrls[_currentVideoIndex],
                              height: isDesktop ? 400 : (isTablet ? 320 : 250),
                              placeholderThumbnail: _getVideoThumbnail(
                                  _youtubeUrls[_currentVideoIndex]),
                              borderRadius: 0,
                            ),
                          ),
                        ] else
                          // VIDEO AD - EDGE TO EDGE without any padding
                          Column(
                            children: [
                              // Add gap before video
                              SizedBox(height: isTablet ? 40 : 30),
                              Container(
                                width: double.infinity,
                                height: isDesktop ? 400 : (isTablet ? 320 : 250),
                                child: CommonYoutubePlayer(
                                  youtubeUrl:
                                      'https://www.youtube.com/embed/qYapc_bkfxw',
                                  height: isDesktop ? 400 : (isTablet ? 320 : 250),
                                  placeholderThumbnail:
                                      'https://img.youtube.com/vi/qYapc_bkfxw/maxresdefault.jpg',
                                  borderRadius: 0,
                                ),
                              ),
                            ],
                          ),

                        // No spacer - removed completely
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

  Widget _buildGridCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isTablet,
    required bool isDesktop,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 32 : 27)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              size: isDesktop ? 48 : (isTablet ? 48 : 40),
              color: const Color(0xFF0B5ED7),
            ),

            SizedBox(height: isDesktop ? 12 : (isTablet ? 12 : 10)),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 22 : (isTablet ? 20 : 16),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            SizedBox(height: isDesktop ? 6 : (isTablet ? 6 : 4)),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 15 : (isTablet ? 14 : 12),
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}