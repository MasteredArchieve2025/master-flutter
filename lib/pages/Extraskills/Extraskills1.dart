// lib/pages/Extraskills/Extraskills1.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/CommonYoutubePlayer.dart';

import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';
import 'Extraskills2.dart';

class Extraskills1Screen extends StatefulWidget {
  const Extraskills1Screen({super.key});

  @override
  State<Extraskills1Screen> createState() => _Extraskills1ScreenState();
}

class _Extraskills1ScreenState extends State<Extraskills1Screen> {
  int _activeAdIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Loading states
  bool _isLoading = true;
  bool _isAdsLoading = true;
  String? _errorMessage;

  // API Data
  List<Map<String, dynamic>> skillCategories = [];
  List<String> adImages = [];
  List<String> youtubeUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchSkillCategories();
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
  }

  Future<void> _fetchAdvertisements() async {
    debugPrint('🔄 Loading advertisements for extraskillpage1...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=extraskillpage1'),
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

  Future<void> _fetchSkillCategories() async {
    debugPrint('🔄 Loading skill categories...');

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/extra-skill-categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Skill Categories API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} skill categories');

        setState(() {
          skillCategories = data.map((item) {
            // Fix image URL if needed
            String? imageUrl = item['image'];
            if (imageUrl != null && imageUrl.isNotEmpty) {
              // Check if URL is valid
              if (!imageUrl.startsWith('http')) {
                imageUrl = '${BaseUrl.baseUrl}$imageUrl';
              }
            }

            return {
              'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
              'title': item['name'] ?? 'Unknown Skill',
              'description':
                  item['shortDescription'] ?? 'No description available',
              'image': imageUrl,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load skill categories. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading skill categories: $e');
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
    _fetchSkillCategories();
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

  // Calculate grid columns
  int _getGridColumns() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 4; // Desktop
    if (screenWidth >= 768) return 3; // Tablet
    return 2; // Mobile
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
    final double adHeight = _responsiveValue(200, 300, 300);
    final int gridColumns = _getGridColumns();
    final double cardWidth = (screenWidth -
            (horizontalPadding * 2) -
            (_responsiveValue(12, 16, 20) * (gridColumns - 1))) /
        gridColumns;
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
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                              'Extra Skills',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(20, 22, 24),
                                fontWeight: FontWeight.w700,
                              ),
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
                            message: 'Loading skills...',
                          ),
                        )
                      : _errorMessage != null && skillCategories.isEmpty
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
                                    'Error loading skill categories',
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
                                                        controller:
                                                            _adController,
                                                        itemCount:
                                                            adImages.length,
                                                        onPageChanged: (index) {
                                                          setState(() {
                                                            _activeAdIndex =
                                                                index;
                                                          });
                                                        },
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Image.network(
                                                            adImages[index],
                                                            width: screenWidth,
                                                            height: adHeight,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                width:
                                                                    screenWidth,
                                                                height:
                                                                    adHeight,
                                                                color: Colors
                                                                    .black12,
                                                                child:
                                                                    const Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .broken_image,
                                                                      color: Colors
                                                                          .grey),
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
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    )
                                                  else
                                                    const SizedBox.shrink(),

                                                  // ===== PAGINATION DOTS =====
                                                  if (adImages.length > 1)
                                                    Container(
                                                      color: Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: List.generate(
                                                            adImages.length,
                                                            (index) {
                                                          return AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            width:
                                                                _activeAdIndex ==
                                                                        index
                                                                    ? _scale(20)
                                                                    : _scale(8),
                                                            height: _scale(8),
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        _scale(
                                                                            4)),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: _activeAdIndex ==
                                                                      index
                                                                  ? const Color(
                                                                      0xFF0B5ED7)
                                                                  : const Color(
                                                                      0xFFCCCCCC),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          _scale(
                                                                              4)),
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    ),

                                                  // ===== SKILL CATEGORIES SECTION =====
                                                  Container(
                                                    width: double.infinity,
                                                    color: Colors.white,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      horizontalPadding,
                                                      _responsiveValue(
                                                          24, 28, 32),
                                                      horizontalPadding,
                                                      _responsiveValue(
                                                          20, 24, 28),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Section Title
                                                        Text(
                                                          'Skill Categories',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    20, 22, 24),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: const Color(
                                                                0xFF003366),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: _scale(8)),

                                                        // Section Subtitle with count
                                                        Text(
                                                          skillCategories
                                                                  .isNotEmpty
                                                              ? '${skillCategories.length} skill ${skillCategories.length == 1 ? 'category' : 'categories'} available'
                                                              : 'Browse skills by category and find the right learning resources',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    14, 15, 16),
                                                            color: const Color(
                                                                0xFF666666),
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                _responsiveValue(
                                                                    20,
                                                                    24,
                                                                    28)),

                                                        // Grid View
                                                        if (skillCategories
                                                            .isEmpty)
                                                          const Center(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(20),
                                                              child: Text(
                                                                  'No skill categories available'),
                                                            ),
                                                          )
                                                        else
                                                          Wrap(
                                                            spacing:
                                                                _responsiveValue(
                                                                    12, 16, 20),
                                                            runSpacing:
                                                                _responsiveValue(
                                                                    12, 16, 20),
                                                            children:
                                                                skillCategories
                                                                    .map(
                                                                        (skill) {
                                                              return _buildSkillCard(
                                                                skill: skill,
                                                                width:
                                                                    cardWidth,
                                                              );
                                                            }).toList(),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                  // ===== BANNER SECTION =====
                                                  Container(
                                                    width: screenWidth,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          horizontalPadding,
                                                      vertical:
                                                          _responsiveValue(
                                                              20, 24, 28),
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        _responsiveValue(
                                                            20, 24, 28)),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF4C73AC),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              _scale(12)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: _scale(6),
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Comprehensive Skill Development',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    18, 20, 22),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: _scale(10)),
                                                        Text(
                                                          'Get tutorials, practice materials, and expert guidance',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    14, 15, 16),
                                                            color: const Color(
                                                                0xFFDCE8FF),
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            horizontalPadding,
                                                        vertical:
                                                            _responsiveValue(
                                                                16, 20, 24),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .play_circle_fill,
                                                              color:
                                                                  Colors.red),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            'Video Tutorials',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  _responsiveValue(
                                                                      18,
                                                                      20,
                                                                      22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: const Color(
                                                                  0xFF003366),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ...youtubeUrls
                                                        .map((url) => Container(
                                                              width:
                                                                  screenWidth,
                                                              margin:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child:
                                                                  CommonYoutubePlayer(
                                                                youtubeUrl: url,
                                                                height: isDesktop
                                                                    ? 360
                                                                    : (isTablet
                                                                        ? 320
                                                                        : 220),
                                                                placeholderThumbnail:
                                                                    _getYoutubeThumbnail(
                                                                        url),
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
              ],
            ),
          ),

          // Full screen loader for initial loading
          if (_isLoading && skillCategories.isEmpty)
            const GlassLoader(
              message: 'Loading skill categories...',
            ),
        ],
      ),
    );
  }

  Widget _buildSkillCard({
    required Map<String, dynamic> skill,
    required double width,
  }) {
    // Check if we have an image from API and it's valid
    bool hasValidImage =
        skill['image'] != null && skill['image'].toString().isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Navigate to Extraskills2 screen when card is tapped with the skill data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Extraskills2Screen(
              categoryTitle: skill['title'] as String,
              categoryId: skill['id'] as int?,
            ),
          ),
        );
      },
      child: Container(
        width: width * 0.9,
        margin: EdgeInsets.symmetric(
            horizontal: width * 0.05), // Center the smaller card
        padding:
            EdgeInsets.all(_responsiveValue(14, 18, 22)), // Increased padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container - Bigger size
            Container(
              width: _responsiveValue(
                  70, 80, 90), // Increased size for better visibility
              height: _responsiveValue(
                  70, 80, 90), // Increased size for better visibility
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    _scale(16)), // Slightly larger border radius
                image: hasValidImage
                    ? DecorationImage(
                        image: NetworkImage(skill['image']),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      )
                    : null,
                color: hasValidImage ? null : const Color(0xFFE6F0FF),
              ),
              child: !hasValidImage
                  ? Center(
                      child: Icon(
                        Icons.star,
                        size: _responsiveValue(
                            25, 30, 35), // Icon size for fallback
                        color: const Color(0xFF0052A2).withOpacity(0.5),
                      ),
                    )
                  : null,
            ),
            SizedBox(height: _scale(14)), // Slightly increased spacing

            // Title - Centered
            Text(
              skill['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _responsiveValue(14, 16, 18),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: _scale(4)),

            // Description - Centered
            Text(
              skill['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _responsiveValue(11, 12, 13),
                color: const Color(0xFF666666),
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}