// lib/pages/Course/Course3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../components/glass_loader.dart';
import '../../api/baseurl.dart';
import 'Course4.dart';

class Course3Screen extends StatefulWidget {
  final String? title; // Course title from Course2
  final Map<String, dynamic>? courseData; // Full course data from Course2

  const Course3Screen({
    super.key,
    this.title,
    this.courseData,
  });

  @override
  State<Course3Screen> createState() => _Course3ScreenState();
}

class _Course3ScreenState extends State<Course3Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  String _selectedMode = "All";
  String _searchQuery = "";
  bool _showFilters = false;
  final PageController _adController = PageController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _adTimer;

  // Loading states
  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;

  // Course providers from API
  List<Map<String, dynamic>> _courseProviders = [];

  // Ads and Videos
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;

  // Default Banner Ads (fallback)
  final List<String> _defaultBannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  // Categories for filter
  final List<String> categories = [
    "All",
    "Online",
    "Offline",
    "Online & Offline"
  ];

  @override
  void initState() {
    super.initState();
    _fetchCourseProviders();
    _loadAdvertisements();
    _startAdTimer();

    // Listen to search controller changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  // Fetch course providers by courseItemId
  Future<void> _fetchCourseProviders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get courseItemId from courseData
    final courseItemId = widget.courseData?['id'] ?? 
                        widget.courseData?['_id'] ?? 
                        1; // Default to 1 if not available

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/course-providers?courseItemId=$courseItemId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // Handle the response structure: { "success": true, "data": [...] }
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          
          setState(() {
            _courseProviders = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid response format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load providers: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Load advertisements for coursepage3
  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for coursepage3...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=coursepage3'),
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

  // Video navigation methods
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

  void _startAdTimer() {
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
    _searchController.dispose();
    super.dispose();
  }

  // Filter providers based on search and mode
  List<Map<String, dynamic>> get filteredProviders {
    return _courseProviders.where((provider) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (provider['name']?.toString() ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (provider['area']?.toString() ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (provider['district']?.toString() ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (provider['state']?.toString() ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Mode filter
      final teachingModes = provider['teachingMode'] as List? ?? [];
      final matchesMode = _selectedMode == "All" ||
          teachingModes.contains(_selectedMode) ||
          (_selectedMode == "Online & Offline" && 
           teachingModes.contains("Online") && 
           teachingModes.contains("Offline"));

      return matchesSearch && matchesMode;
    }).toList();
  }

  // Helper method to format location
  String _formatLocation(Map<String, dynamic> provider) {
    final parts = <String>[];
    
    final area = provider['area']?.toString();
    if (area != null && area.isNotEmpty) {
      parts.add(area);
    }
    
    final district = provider['district']?.toString();
    if (district != null && district.isNotEmpty) {
      parts.add(district);
    }
    
    final state = provider['state']?.toString();
    if (state != null && state.isNotEmpty) {
      parts.add(state);
    }
    
    return parts.isNotEmpty ? parts.join(' · ') : 'Location not specified';
  }

  // Helper method to format teaching modes
  String _formatTeachingModes(List? modes) {
    if (modes == null || modes.isEmpty) return 'Mode not specified';
    return modes.join(' & ');
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

    // Responsive breakpoints
    final bool isTablet = screenWidth >= 768;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double bannerHeight = _responsiveValue(200, 300, 300);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;
    final double videoHeight = _responsiveValue(250, 320, 400);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // App Bar
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
                    height: _responsiveValue(52, 58, 64),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title ?? 'Course Providers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(17, 18, 19),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

                // MAIN CONTENT
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
                            // TOP AUTO SCROLL AD BANNER
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

                            // ===== PAGINATION DOTS =====
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
                                padding:
                                    EdgeInsets.all(_responsiveValue(16, 20, 24)),
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
                                      'Teaching Mode',
                                      style: TextStyle(
                                        fontSize: _scale(16),
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: categories.map((mode) {
                                        return _buildFilterOption(mode);
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                            // ===== CATEGORIES (Quick Filters) =====
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
                                    'Available Providers',
                                    style: TextStyle(
                                      fontSize: _scale(18),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (!_isLoading)
                                    Text(
                                      '${filteredProviders.length} providers found',
                                      style: TextStyle(
                                        fontSize: _scale(13),
                                        color: const Color(0xFF666666),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // ===== COURSE PROVIDERS LIST =====
                            if (_isLoading)
                              Container(
                                height: 300,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0052A2),
                                  ),
                                ),
                              )
                            else if (_errorMessage != null)
                              _buildErrorWidget(isDesktop, isTablet, horizontalPadding)
                            else if (filteredProviders.isEmpty)
                              _buildEmptyWidget(isDesktop, isTablet, horizontalPadding)
                            else
                              Column(
                                children: filteredProviders.map((provider) {
                                  return _buildProviderCard(
                                    provider: provider,
                                    horizontalPadding: horizontalPadding,
                                    isTablet: isTablet,
                                  );
                                }).toList(),
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
                                        'Course Videos',
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
                                  bottom: _responsiveValue(30, 40, 50),
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
                              // Default VIDEO - EDGE TO EDGE
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isTablet ? 40 : 30,
                                  bottom: _responsiveValue(30, 40, 50),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const GlassLoader(message: 'Loading providers...'),
        ],
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

  // Error widget
  Widget _buildErrorWidget(bool isDesktop, bool isTablet, double horizontalPadding) {
    return Container(
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
            Icons.error_outline,
            size: _scale(48),
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load providers',
            style: TextStyle(
              fontSize: _scale(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _scale(12),
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchCourseProviders,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052A2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Empty widget
  Widget _buildEmptyWidget(bool isDesktop, bool isTablet, double horizontalPadding) {
    return Container(
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
            Icons.business_center_outlined,
            size: _scale(48),
            color: const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            'No providers found',
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
    );
  }

  Widget _buildProviderCard({
    required Map<String, dynamic> provider,
    required double horizontalPadding,
    required bool isTablet,
  }) {
    final String providerName = provider['name']?.toString() ?? 'Unknown Institute';
    final String imageUrl = provider['image']?.toString() ?? '';
    final String location = _formatLocation(provider);
    final double rating = double.tryParse(provider['rating']?.toString() ?? '0') ?? 0.0;
    final List teachingModes = provider['teachingMode'] as List? ?? [];
    final String modesText = _formatTeachingModes(teachingModes);

    return GestureDetector(
      onTap: () {
        // Navigate to Course4 with selected provider
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Course4Screen(
              provider: provider, // Pass the full provider data
            ),
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
            // Provider Image
            Container(
              width: _scale(80),
              height: _scale(80),
              decoration: BoxDecoration(
                color: const Color(0xFF0175D3),
                borderRadius: BorderRadius.circular(_scale(12)),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl.isEmpty
                  ? Center(
                      child: Text(
                        providerName.isNotEmpty ? providerName[0] : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _scale(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(width: _responsiveValue(14, 18, 22)),

            // Provider Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          providerName,
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
                      if (rating > 0)
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
                                rating.toStringAsFixed(1),
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
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: _scale(12),
                            color: const Color(0xFF5F6F81),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Teaching Mode Tag
                  if (modesText != 'Mode not specified')
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
                        modesText,
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

            // Chevron Icon
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