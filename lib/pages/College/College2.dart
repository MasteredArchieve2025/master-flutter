// lib/pages/College/College2.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../Widgets/Footer.dart';
import '../../components/glass_loader.dart';
import 'College3.dart';
import '../../Api/School/Colleges/College_service.dart';
import '../../Api/baseurl.dart';

class College2Screen extends StatefulWidget {
  final Map<String, dynamic> category;

  const College2Screen({
    super.key,
    required this.category,
  });

  @override
  State<College2Screen> createState() => _College2ScreenState();
}

class _College2ScreenState extends State<College2Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Banner Ads Data
  final List<String> _defaultBannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  // Degrees Data from API
  List<Map<String, dynamic>> _degrees = [];
  bool _isLoadingDegrees = true;
  bool _isLoadingAds = true;
  String? _errorMessage;
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDegrees();
    _loadAdvertisements();
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

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for collegepage2...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=collegepage2'),
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

  Future<void> _fetchDegrees() async {
    setState(() {
      _isLoadingDegrees = true;
      _errorMessage = null;
    });

    try {
      final allDegrees = await CollegeService.getCollegeDegrees();
      // Filter by category if we have the current category ID, otherwise show all
      final filteredDegrees = widget.category['id'] != null
          ? allDegrees
              .where((d) => d.categoryId == widget.category['id'])
              .toList()
          : allDegrees;

      setState(() {
        _degrees = filteredDegrees.map((d) => d.toDegreeMap()).toList();
        _isLoadingDegrees = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingDegrees = false;
      });
    }
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
    final double bannerHeight = isDesktop ? 300 : (isTablet ? 300 : 200);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Stack(
        children: [
          SafeArea(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                              'Departments',
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
                            // ===== BANNER ADS =====
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
                                        child: Image.network(
                                          bannerAds[index],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
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
                                                    color:
                                                        const Color(0xFF0B5ED7),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Advertisement ${index + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Color(0xFF0B5ED7),
                                                      fontWeight:
                                                          FontWeight.bold,
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

                            // Dots Indicator
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate(bannerAds.length, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: _activeAd == index ? 24 : 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: _activeAd == index
                                        ? const Color(0xFF0B5ED7)
                                        : const Color(0xFFCCCCCC),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),

                            // ===== CATEGORY INFO =====
                            Container(
                              margin: EdgeInsets.symmetric(
                                vertical: isTablet ? (isDesktop ? 35 : 30) : 20,
                              ),
                              child: Column(
                                children: [
                                  // Icon Container
                                  Container(
                                    width:
                                        isDesktop ? 90 : (isTablet ? 80 : 70),
                                    height:
                                        isDesktop ? 90 : (isTablet ? 80 : 70),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F2FF),
                                      borderRadius: BorderRadius.circular(
                                        isDesktop ? 70 : (isTablet ? 60 : 50),
                                      ),
                                    ),
                                    child: Icon(
                                      widget.category['icon'] as IconData? ??
                                          Icons.school,
                                      size:
                                          isDesktop ? 50 : (isTablet ? 40 : 35),
                                      color: const Color(0xFF0C2F63),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Category Title
                                  Text(
                                    widget.category['name'] as String? ??
                                        'Unknown',
                                    style: TextStyle(
                                      fontSize:
                                          isDesktop ? 26 : (isTablet ? 24 : 20),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0C2F63),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ===== DEGREE CARDS =====
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 0 : horizontalPadding,
                              ),
                              child: _isLoadingDegrees
                                  ? const SizedBox(
                                      height: 200) // Placeholder while loading
                                  : _errorMessage != null
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error_outline,
                                                  size: 50,
                                                  color: Colors.red[300]),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Failed to load degrees',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[800]),
                                              ),
                                              ElevatedButton(
                                                onPressed: _fetchDegrees,
                                                child: const Text('Retry'),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _degrees.isEmpty
                                          ? Center(
                                              child: Text(
                                                'No degrees available for this category',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600]),
                                              ),
                                            )
                                          : LayoutBuilder(
                                              builder: (context, constraints) {
                                                final double availableWidth =
                                                    constraints.maxWidth;
                                                final int crossAxisCount =
                                                    isDesktop
                                                        ? 2
                                                        : 2; // Always 2 columns
                                                final double spacing =
                                                    isTablet ? 16 : 12;
                                                final double runSpacing =
                                                    isTablet ? 20 : 14;
                                                final double totalSpacing =
                                                    spacing *
                                                        (crossAxisCount - 1);
                                                final double itemWidth =
                                                    (availableWidth -
                                                            totalSpacing) /
                                                        crossAxisCount;
                                                final double
                                                    itemWidthPercentage =
                                                    itemWidth /
                                                        availableWidth *
                                                        100;

                                                return Wrap(
                                                  spacing: spacing,
                                                  runSpacing: runSpacing,
                                                  alignment: WrapAlignment
                                                      .spaceBetween,
                                                  children: List.generate(
                                                      _degrees.length, (index) {
                                                    final degree =
                                                        _degrees[index];

                                                    // Check if this is a single item in the last row
                                                    final bool
                                                        isSingleLastItem =
                                                        _isSingleLastItem(index,
                                                            _degrees.length);

                                                    return Container(
                                                      width: isSingleLastItem &&
                                                              itemWidthPercentage <
                                                                  47
                                                          ? itemWidth
                                                          : // If it's wide enough, use normal width
                                                          itemWidth, // Otherwise use normal width
                                                      child: _buildDegreeCard(
                                                        degree: degree,
                                                        isTablet: isTablet,
                                                        isDesktop: isDesktop,
                                                      ),
                                                    );
                                                  }),
                                                );
                                              },
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
                                            icon: const Icon(
                                                Icons.chevron_right,
                                                color: Color(0xFF0B5ED7)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: _youtubeUrls.length > 1
                                      ? 0
                                      : (isTablet ? 40 : 30),
                                ),
                                child: CommonYoutubePlayer(
                                  youtubeUrl: _youtubeUrls[_currentVideoIndex],
                                  height:
                                      isDesktop ? 400 : (isTablet ? 320 : 250),
                                  placeholderThumbnail: _getVideoThumbnail(
                                      _youtubeUrls[_currentVideoIndex]),
                                  borderRadius: 0,
                                ),
                              ),
                            ] else
                              // VIDEO AD - EDGE TO EDGE (keep as is)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isTablet ? 40 : 30,
                                ),
                                child: CommonYoutubePlayer(
                                  youtubeUrl:
                                      'https://www.youtube.com/embed/NONufn3jgXI',
                                  height:
                                      isDesktop ? 400 : (isTablet ? 320 : 250),
                                  placeholderThumbnail:
                                      'https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg',
                                  borderRadius: 0,
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
          if (_isLoadingDegrees)
            const GlassLoader(message: 'Loading degrees...'),
        ],
      ),
    );
  }

  bool _isSingleLastItem(int index, int totalItems) {
    const itemsPerRow = 2;
    final lastRowStartIndex = ((totalItems - 1) ~/ itemsPerRow) * itemsPerRow;
    final isInLastRow = index >= lastRowStartIndex;
    final isOddItemInLastRow = isInLastRow &&
        (index % itemsPerRow == 0) &&
        (totalItems % itemsPerRow == 1);

    return isOddItemInLastRow;
  }

  Widget _buildDegreeCard({
    required Map<String, dynamic> degree,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => College3Screen(
              degree: degree['title'] as String,
              categoryId: degree['categoryId'] as int?,
              degreeId: degree['id'] as int?,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${degree['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
        margin: EdgeInsets.only(bottom: isDesktop ? 24 : (isTablet ? 20 : 14)),
        decoration: BoxDecoration(
          color: const Color(0xFFDBD9D9),
          borderRadius:
              BorderRadius.circular(isDesktop ? 16 : (isTablet ? 16 : 14)),
          border: Border.all(
            color: const Color(0xFFD0E0FF),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              degree['icon'] as IconData,
              size: isDesktop ? 34 : (isTablet ? 34 : 28),
              color: const Color(0xFF0052A2),
            ),

            SizedBox(height: isDesktop ? 12 : (isTablet ? 12 : 10)),

            // Title
            Text(
              degree['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF003366),
              ),
            ),

            SizedBox(height: isDesktop ? 8 : (isTablet ? 8 : 6)),

            // Description
            Text(
              degree['desc'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 15 : (isTablet ? 14 : 12),
                color: const Color(0xFF555555),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
