// lib/pages/Course/Course3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../components/glass_loader.dart';
import '../../api/baseurl.dart';
import '../../Widgets/Footer.dart';
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
  int _activeAdIndex = 0;
  String _selectedMode = "All";
  String _searchQuery = "";
  bool _showFilters = false;
  final PageController _adController = PageController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _adTimer;

  // Loading states
  bool _isLoading = true;
  bool _isAdsLoading = true;
  String? _errorMessage;

  // Course providers from API
  List<Map<String, dynamic>> courseProviders = [];

  // Ads and Videos
  List<String> adImages = [];
  List<String> youtubeUrls = [];

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
    _fetchAdvertisements();

    // Auto scroll ads
    _adTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_adController.hasClients && mounted && adImages.isNotEmpty) {
        int nextPage = _activeAdIndex + 1;
        if (nextPage >= adImages.length) nextPage = 0;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
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

  Future<void> _fetchAdvertisements() async {
    debugPrint('🔄 Loading advertisements for coursepage3...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=coursepage3'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            adImages = List<String>.from(data['data']['images'] ?? []);
            youtubeUrls = List<String>.from(data['data']['youtube_urls'] ?? []);
            _isAdsLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading advertisements: $e');
      setState(() {
        _isAdsLoading = false;
      });
    }
  }

  // Fetch course providers by courseItemId
  Future<void> _fetchCourseProviders() async {
    debugPrint('🔄 Loading course providers...');

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

      debugPrint('📡 Course Providers API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Handle the response structure: { "success": true, "data": [...] }
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          
          debugPrint('📦 Loaded ${data.length} course providers');

          setState(() {
            courseProviders = data.map((item) {
              // Fix image URL if needed
              String? imageUrl = item['image'];
              if (imageUrl != null && imageUrl.isNotEmpty) {
                if (!imageUrl.startsWith('http')) {
                  imageUrl = '${BaseUrl.baseUrl}$imageUrl';
                }
              }

              return {
                'id': item['id'] ?? item['_id'] ?? DateTime.now().millisecondsSinceEpoch,
                'name': item['name'] ?? 'Unknown Provider',
                'description': item['description'] ?? 'No description available',
                'image': imageUrl,
                'area': item['area'] ?? '',
                'district': item['district'] ?? '',
                'state': item['state'] ?? '',
                'rating': item['rating'] ?? 0.0,
                'teachingMode': item['teachingMode'] ?? [],
                'address': item['address'] ?? '',
                'phone': item['phone'] ?? '',
                'email': item['email'] ?? '',
                'website': item['website'] ?? '',
              };
            }).toList();
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
          _errorMessage = 'Failed to load providers. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading course providers: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _isAdsLoading = true;
      _errorMessage = null;
    });
    _fetchCourseProviders();
    _fetchAdvertisements();
  }

  String _getYoutubeThumbnail(String url) {
    try {
      String videoId = '';
      if (url.contains('embed/')) {
        videoId = url.split('embed/').last.split('?').first;
      } else if (url.contains('v=')) {
        videoId = url.split('v=').last.split('&').first;
      } else if (url.contains('youtu.be/')) {
        videoId = url.split('youtu.be/').last.split('?').first;
      } else {
        videoId = url.split('/').last.split('?').first;
      }
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    } catch (e) {
      return '';
    }
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
    return courseProviders.where((provider) {
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
    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isMobile = screenWidth < 768;

    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double adHeight = _responsiveValue(200, 300, 300);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;

    // Calculate header height
    final double headerHeight = _responsiveValue(52, 58, 80);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Stack(
        children: [
          SafeArea(
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
                    height: headerHeight,
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            size: _scale(24),
                            color: Colors.white,
                          ),
                        ),
                        // Title
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title ?? 'Course Providers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(20, 22, 24),
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Spacer for symmetry
                        SizedBox(width: _scale(40)),
                      ],
                    ),
                  ),
                ),

                // ===== MAIN CONTENT =====
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: GlassLoader(
                            message: 'Loading providers...',
                          ),
                        )
                      : _errorMessage != null && courseProviders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading providers',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _retryLoading,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B5ED7),
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: IntrinsicHeight(
                                      child: Center(
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: maxContentWidth),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // ===== ADVERTISEMENT BANNER =====
                                                  if (adImages.isNotEmpty)
                                                    Container(
                                                      width: screenWidth,
                                                      height: adHeight,
                                                      child: PageView.builder(
                                                        controller: _adController,
                                                        itemCount: adImages.length,
                                                        onPageChanged: (index) {
                                                          setState(() {
                                                            _activeAdIndex = index;
                                                          });
                                                        },
                                                        itemBuilder: (context, index) {
                                                          return Image.network(
                                                            adImages[index],
                                                            width: screenWidth,
                                                            height: adHeight,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error, stackTrace) {
                                                              return Container(
                                                                width: screenWidth,
                                                                height: adHeight,
                                                                color: Colors.black12,
                                                                child: const Center(
                                                                  child: Icon(
                                                                      Icons.broken_image,
                                                                      color: Colors.grey),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  else if (_isAdsLoading)
                                                    Container(
                                                      width: screenWidth,
                                                      height: adHeight,
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    )
                                                  else
                                                    const SizedBox.shrink(),

                                                  // ===== PAGINATION DOTS =====
                                                  if (adImages.length > 1)
                                                    Container(
                                                      color: Colors.white,
                                                      padding: const EdgeInsets.symmetric(
                                                          vertical: 8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                        children: List.generate(
                                                            adImages.length, (index) {
                                                          return AnimatedContainer(
                                                            duration:
                                                                const Duration(milliseconds: 300),
                                                            width: _activeAdIndex == index
                                                                ? _scale(20)
                                                                : _scale(8),
                                                            height: _scale(8),
                                                            margin: EdgeInsets.symmetric(
                                                                horizontal: _scale(4)),
                                                            decoration: BoxDecoration(
                                                              color: _activeAdIndex == index
                                                                  ? const Color(0xFF0B5ED7)
                                                                  : const Color(0xFFCCCCCC),
                                                              borderRadius:
                                                                  BorderRadius.circular(_scale(4)),
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    ),

                                                  // ===== SEARCH & FILTER ROW =====
                                                  Container(
                                                    width: screenWidth,
                                                    color: Colors.white,
                                                    padding: EdgeInsets.fromLTRB(
                                                      horizontalPadding,
                                                      _responsiveValue(16, 20, 24),
                                                      horizontalPadding,
                                                      _responsiveValue(8, 10, 12),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Search Container
                                                        Expanded(
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: _responsiveValue(12, 14, 16),
                                                              vertical: _responsiveValue(8, 10, 12),
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFF5F7FA),
                                                              borderRadius:
                                                                  BorderRadius.circular(_scale(12)),
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
                                                        SizedBox(width: _responsiveValue(8, 12, 16)),
                                                        
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _showFilters = !_showFilters;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.all(
                                                                _responsiveValue(10, 12, 14)),
                                                            decoration: BoxDecoration(
                                                              color: _showFilters
                                                                  ? const Color(0xFF0B5ED7)
                                                                  : const Color(0xFFF5F7FA),
                                                              borderRadius:
                                                                  BorderRadius.circular(_scale(12)),
                                                            ),
                                                            child: Icon(
                                                              Icons.filter_alt,
                                                              size: _scale(18),
                                                              color: _showFilters
                                                                  ? Colors.white
                                                                  : const Color(0xFF0B5ED7),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // ===== FILTER OPTIONS =====
                                                  if (_showFilters)
                                                    Container(
                                                      width: screenWidth,
                                                      color: Colors.white,
                                                      padding: EdgeInsets.fromLTRB(
                                                        horizontalPadding,
                                                        _responsiveValue(8, 10, 12),
                                                        horizontalPadding,
                                                        _responsiveValue(16, 20, 24),
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
                                                          SizedBox(height: _scale(16)),
                                                          // Responsive filter options
                                                          Wrap(
                                                            spacing: 8,
                                                            runSpacing: 8,
                                                            children: categories.map((mode) {
                                                              return _buildResponsiveFilterOption(mode, isMobile);
                                                            }).toList(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  // ===== CATEGORIES (Quick Filters) =====
                                                  Container(
                                                    width: screenWidth,
                                                    color: Colors.white,
                                                    padding: EdgeInsets.fromLTRB(
                                                      horizontalPadding,
                                                      _showFilters ? 0 : _responsiveValue(16, 20, 24),
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
                                                          child: _buildResponsiveChoiceChip(
                                                            category: category,
                                                            isSelected: _selectedMode == category,
                                                            isMobile: isMobile,
                                                            onSelected: (selected) {
                                                              setState(() {
                                                                _selectedMode = category;
                                                              });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  // ===== PROVIDERS LIST SECTION =====
                                                  Container(
                                                    width: double.infinity,
                                                    color: Colors.white,
                                                    padding: EdgeInsets.fromLTRB(
                                                      horizontalPadding,
                                                      _responsiveValue(24, 28, 32),
                                                      horizontalPadding,
                                                      _responsiveValue(20, 24, 28),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        // Section Title with count
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Available Providers',
                                                              style: TextStyle(
                                                                fontSize: _responsiveValue(20, 22, 24),
                                                                fontWeight: FontWeight.w700,
                                                                color: const Color(0xFF003366),
                                                              ),
                                                            ),
                                                            if (!_isLoading)
                                                              Container(
                                                                padding: EdgeInsets.symmetric(
                                                                  horizontal: _responsiveValue(10, 12, 14),
                                                                  vertical: _responsiveValue(4, 5, 6),
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xFFE8F0FF),
                                                                  borderRadius: BorderRadius.circular(_scale(20)),
                                                                ),
                                                                child: Text(
                                                                  '${filteredProviders.length} found',
                                                                  style: TextStyle(
                                                                    fontSize: _responsiveValue(12, 13, 14),
                                                                    color: const Color(0xFF0B5ED7),
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        SizedBox(height: _scale(8)),

                                                        // Section Subtitle
                                                        Text(
                                                          'Browse through our trusted course providers',
                                                          style: TextStyle(
                                                            fontSize: _responsiveValue(14, 15, 16),
                                                            color: const Color(0xFF666666),
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: _responsiveValue(20, 24, 28)),

                                                        // Providers List
                                                        if (filteredProviders.isEmpty)
                                                          _buildEmptyState()
                                                        else
                                                          Column(
                                                            children: filteredProviders.map((provider) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                  bottom: _responsiveValue(14, 18, 22),
                                                                ),
                                                                child: _buildProviderCard(
                                                                  provider: provider,
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                  // ===== BANNER SECTION =====
                                                  Container(
                                                    width: screenWidth,
                                                    margin: EdgeInsets.symmetric(
                                                      horizontal: horizontalPadding,
                                                      vertical: _responsiveValue(20, 24, 28),
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        _responsiveValue(20, 24, 28)),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF4C73AC),
                                                      borderRadius:
                                                          BorderRadius.circular(_scale(12)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1),
                                                          blurRadius: _scale(6),
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Expert Course Providers',
                                                          style: TextStyle(
                                                            fontSize: _responsiveValue(18, 20, 22),
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(height: _scale(10)),
                                                        Text(
                                                          'Connect with experienced instructors and training centers',
                                                          style: TextStyle(
                                                            fontSize: _responsiveValue(14, 15, 16),
                                                            color: const Color(0xFFDCE8FF),
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // ===== YOUTUBE VIDEO SECTION =====
                                              if (youtubeUrls.isNotEmpty)
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: horizontalPadding,
                                                        vertical: _responsiveValue(16, 20, 24),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.play_circle_fill,
                                                              color: Colors.red),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            'Provider Videos',
                                                            style: TextStyle(
                                                              fontSize: _responsiveValue(18, 20, 22),
                                                              fontWeight: FontWeight.w700,
                                                              color: const Color(0xFF003366),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ...youtubeUrls
                                                        .map((url) => Container(
                                                              width: screenWidth,
                                                              margin: EdgeInsets.only(),
                                                              child: CommonYoutubePlayer(
                                                                youtubeUrl: url,
                                                                height: isDesktop
                                                                    ? 360
                                                                    : (isTablet ? 320 : 220),
                                                                placeholderThumbnail:
                                                                    _getYoutubeThumbnail(url),
                                                                borderRadius: 0,
                                                              ),
                                                            ))
                                                        .toList(),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

          // Full screen loader for initial loading
          if (_isLoading && courseProviders.isEmpty)
            const GlassLoader(
              message: 'Loading providers...',
            ),
        ],
      ),
    );
  }

  // Responsive filter option for the expanded filter section
  Widget _buildResponsiveFilterOption(String mode, bool isMobile) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: _selectedMode == mode
              ? const Color(0xFF0B5ED7)
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(_scale(8)),
          border: _selectedMode == mode
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w500,
            color: _selectedMode == mode ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  // Responsive choice chip for quick filters
  Widget _buildResponsiveChoiceChip({
    required String category,
    required bool isSelected,
    required bool isMobile,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        category,
        style: TextStyle(
          fontSize: isMobile ? 11 : 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0B5ED7),
      backgroundColor: const Color(0xFFF1F3F6),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF5F6F81),
        fontSize: isMobile ? 11 : 13,
      ),
      onSelected: onSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 8,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_responsiveValue(32, 40, 48)),
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
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    
    final String providerName = provider['name']?.toString() ?? 'Unknown Institute';
    final String imageUrl = provider['image']?.toString() ?? '';
    final String location = _formatLocation(provider);
    final double rating = (provider['rating'] is num) 
        ? (provider['rating'] as num).toDouble() 
        : double.tryParse(provider['rating']?.toString() ?? '0') ?? 0.0;
    final List teachingModes = provider['teachingMode'] as List? ?? [];
    final String modesText = _formatTeachingModes(teachingModes);

    return GestureDetector(
      onTap: () {
        // Navigate to Course4 with selected provider
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Course4Screen(
              provider: provider,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(_responsiveValue(14, 18, 22)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_scale(16)),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Provider Image - Responsive sizing
            Container(
              width: isMobile ? 50 : _scale(70),
              height: isMobile ? 50 : _scale(70),
              decoration: BoxDecoration(
                color: const Color(0xFF0175D3),
                borderRadius: BorderRadius.circular(isMobile ? 8 : _scale(12)),
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
                          fontSize: isMobile ? 18 : _scale(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(width: isMobile ? 10 : _responsiveValue(14, 18, 22)),

            // Provider Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          providerName,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : _scale(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Rating - Responsive
                      if (rating > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : _responsiveValue(8, 10, 12),
                            vertical: isMobile ? 3 : _responsiveValue(4, 5, 6),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(isMobile ? 8 : _scale(12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: isMobile ? 12 : 14,
                                color: const Color(0xFFFFB703),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : _scale(12),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 4 : 6),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: isMobile ? 12 : _scale(14),
                        color: const Color(0xFF5F6F81),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : _scale(12),
                            color: const Color(0xFF5F6F81),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 6 : 8),

                  // Teaching Mode Tag - Responsive
                  if (modesText != 'Mode not specified')
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : _responsiveValue(10, 12, 14),
                        vertical: isMobile ? 4 : _responsiveValue(5, 6, 7),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(isMobile ? 6 : _scale(8)),
                      ),
                      child: Text(
                        modesText,
                        style: TextStyle(
                          fontSize: isMobile ? 10 : _scale(11),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0B5ED7),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(width: isMobile ? 8 : _responsiveValue(12, 16, 20)),

            // Chevron Icon - Responsive
            Icon(
              Icons.chevron_right,
              size: isMobile ? 18 : _scale(24),
              color: const Color(0xFF0B5ED7),
            ),
          ],
        ),
      ),
    );
  }
}