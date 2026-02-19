// lib/pages/Extraskills/Extraskills2.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';
import 'Extraskills3.dart';

class Extraskills2Screen extends StatefulWidget {
  final String categoryTitle;
  final int? categoryId;

  const Extraskills2Screen({
    super.key,
    required this.categoryTitle,
    this.categoryId,
  });

  @override
  State<Extraskills2Screen> createState() => _Extraskills2ScreenState();
}

class _Extraskills2ScreenState extends State<Extraskills2Screen> {
  int _currentCarouselIndex = 0;
  int _currentVideoIndex = 0;
  final PageController _pageController = PageController();

  // Loading states
  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;

  // API Data
  List<Map<String, dynamic>> _skillTypes = [];
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];

  // Default banner ads (fallback if API fails)
  final List<String> _defaultBannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  // Fallback icons for when images fail to load
  final Map<String, IconData> _fallbackIcons = {
    "Arts": Icons.palette,
    "Fine Arts": Icons.palette,
    "Classical Dance": Icons.music_note,
    "Western Dance": Icons.music_note,
    "Folk Dance": Icons.music_note,
    "Zumba / Fitness Dance": Icons.fitness_center,
    "Freestyle & Choreography Training": Icons.theater_comedy,
    "Classical Vocal": Icons.mic,
    "Western Vocal": Icons.mic,
    "Devotional / Bhajan Singing": Icons.music_note,
    "Folk Music Singing": Icons.music_note,
    "Voice Culture & Training": Icons.record_voice_over,
    "Basic Drawing & Sketching": Icons.brush,
    "Creative Art & Imagination Drawing": Icons.lightbulb,
    "Thematic & Subject Drawing": Icons.draw,
    "Professional Art Techniques": Icons.palette,
    "Art for School & Hobby": Icons.school,
    "Two Wheeler": Icons.two_wheeler,
    "Four Wheeler": Icons.directions_car,
    "Heavy Vehicle": Icons.local_shipping,
    "Driving Rules": Icons.traffic,
    "Practical Lessons": Icons.directions,
    "Track Running": Icons.directions_run,
    "Marathon Prep": Icons.directions_run,
    "High Jump": Icons.arrow_upward,
    "Long Jump": Icons.arrow_forward,
    "Football": Icons.sports_soccer,
    "Cricket": Icons.sports_cricket,
    "Yoga": Icons.self_improvement,
    "Gym": Icons.fitness_center,
    "Swimming": Icons.pool,
    "Cooking": Icons.restaurant,
    "Sewing": Icons.content_cut,
    "Home Management": Icons.home,
    "Interior Design": Icons.architecture,
    "Music Production": Icons.music_note,
    "Creative Writing": Icons.edit,
    "Photography": Icons.camera_alt,
    "Film Making": Icons.videocam,
  };

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  // Get skill types to display
  List<Map<String, dynamic>> get _displaySkillTypes {
    if (_skillTypes.isNotEmpty) {
      return _skillTypes;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    if (widget.categoryId != null) {
      _loadSkillTypes(widget.categoryId!);
    } else {
      setState(() {
        _isLoading = false;
      });
      _startAutoScroll();
    }
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for extraskillpage2...');

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=extraskillpage2'),
      );

      debugPrint('📡 Ads API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];

          setState(() {
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
              debugPrint('🖼️ Loaded ${_adImages.length} images from API');
            }

            if (apiData['youtube_urls'] != null &&
                apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
              debugPrint('🎥 Loaded ${_youtubeUrls.length} videos from API');
            }
            _isLoadingAds = false;
          });
        }
      } else {
        debugPrint('⚠️ Ads API error: ${response.statusCode}');
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

  Future<void> _loadSkillTypes(int categoryId) async {
    debugPrint('🔄 Loading skill types for category $categoryId...');

    try {
      final response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/extra-skill-types/category/$categoryId'),
      );

      debugPrint('📡 Skill Types API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} skill types');

        setState(() {
          _skillTypes = data.map((item) {
            // Fix image URL if it's a placeholder
            String? imageUrl = item['image'];
            if (imageUrl != null && imageUrl.contains('example.com')) {
              imageUrl = null; // Don't use placeholder images
            }

            return {
              'id': item['id'] ?? 0, // Make sure ID is present
              'name': item['name'] ?? 'Unknown Skill',
              'shortDescription':
                  item['shortDescription'] ?? 'Explore this skill',
              'image': imageUrl,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        debugPrint('⚠️ Skill Types API error: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to load skill types';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading skill types: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    } finally {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients && mounted) {
        int nextPage = _currentCarouselIndex + 1;
        if (nextPage >= bannerAds.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
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

  // Function to generate default skill types if API fails
  List<Map<String, dynamic>> _getDefaultSkillTypes() {
    switch (widget.categoryTitle) {
      case 'Fine Arts':
        return [
          {
            'id': 1,
            'name': 'Arts',
            'shortDescription': 'Explore creative and practical skills',
            'image': null
          },
          {
            'id': 2,
            'name': 'Basic Drawing & Sketching',
            'shortDescription': 'Drawing fundamentals',
            'image': null
          },
          {
            'id': 3,
            'name': 'Creative Art & Imagination Drawing',
            'shortDescription': 'Creative expression',
            'image': null
          },
          {
            'id': 4,
            'name': 'Professional Art Techniques',
            'shortDescription': 'Advanced art skills',
            'image': null
          },
        ];
      case 'Driving Class':
        return [
          {
            'id': 5,
            'name': 'Two Wheeler',
            'shortDescription': 'Bike driving skills',
            'image': null
          },
          {
            'id': 6,
            'name': 'Four Wheeler',
            'shortDescription': 'Car driving training',
            'image': null
          },
          {
            'id': 7,
            'name': 'Driving Rules',
            'shortDescription': 'Traffic rules & safety',
            'image': null
          },
          {
            'id': 8,
            'name': 'Practical Lessons',
            'shortDescription': 'Hands-on driving practice',
            'image': null
          },
        ];
      case 'Athlete':
        return [
          {
            'id': 9,
            'name': 'Track Running',
            'shortDescription': 'Speed and endurance training',
            'image': null
          },
          {
            'id': 10,
            'name': 'Marathon Prep',
            'shortDescription': 'Long-distance running prep',
            'image': null
          },
          {
            'id': 11,
            'name': 'High Jump',
            'shortDescription': 'Jumping techniques',
            'image': null
          },
          {
            'id': 12,
            'name': 'Long Jump',
            'shortDescription': 'Distance jumping skills',
            'image': null
          },
        ];
      case 'Sports & Fitness':
        return [
          {
            'id': 13,
            'name': 'Football',
            'shortDescription': 'Football skills training',
            'image': null
          },
          {
            'id': 14,
            'name': 'Cricket',
            'shortDescription': 'Cricket coaching',
            'image': null
          },
          {
            'id': 15,
            'name': 'Yoga',
            'shortDescription': 'Mind & body wellness',
            'image': null
          },
          {
            'id': 16,
            'name': 'Gym',
            'shortDescription': 'Strength & fitness training',
            'image': null
          },
          {
            'id': 17,
            'name': 'Swimming',
            'shortDescription': 'Swimming techniques',
            'image': null
          },
        ];
      case 'Home Science':
        return [
          {
            'id': 18,
            'name': 'Cooking',
            'shortDescription': 'Cooking fundamentals',
            'image': null
          },
          {
            'id': 19,
            'name': 'Sewing',
            'shortDescription': 'Stitching & tailoring',
            'image': null
          },
          {
            'id': 20,
            'name': 'Home Management',
            'shortDescription': 'Household management',
            'image': null
          },
          {
            'id': 21,
            'name': 'Interior Design',
            'shortDescription': 'Interior design basics',
            'image': null
          },
        ];
      case 'Other Classes':
        return [
          {
            'id': 22,
            'name': 'Music Production',
            'shortDescription': 'Create and mix music',
            'image': null
          },
          {
            'id': 23,
            'name': 'Creative Writing',
            'shortDescription': 'Writing & storytelling',
            'image': null
          },
          {
            'id': 24,
            'name': 'Photography',
            'shortDescription': 'Photography skills',
            'image': null
          },
          {
            'id': 25,
            'name': 'Film Making',
            'shortDescription': 'Film creation basics',
            'image': null
          },
        ];
      default:
        return [
          {
            'id': 26,
            'name': 'Arts',
            'shortDescription': 'Explore creative and practical skills',
            'image': null
          },
          {
            'id': 27,
            'name': 'Music',
            'shortDescription': 'Learn musical instruments and vocals',
            'image': null
          },
          {
            'id': 28,
            'name': 'Dance',
            'shortDescription': 'Various dance forms',
            'image': null
          },
          {
            'id': 29,
            'name': 'Sports',
            'shortDescription': 'Physical activities and games',
            'image': null
          },
        ];
    }
  }

  // Get fallback icon for a skill name
  IconData _getFallbackIcon(String skillName) {
    // Try exact match first
    if (_fallbackIcons.containsKey(skillName)) {
      return _fallbackIcons[skillName]!;
    }

    // Try partial match
    final matchingKey = _fallbackIcons.keys.firstWhere(
      (key) =>
          skillName.toLowerCase().contains(key.toLowerCase()) ||
          key.toLowerCase().contains(skillName.toLowerCase()),
      orElse: () => 'Arts',
    );
    return _fallbackIcons[matchingKey]!;
  }

  // Responsive value function
  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop;
    if (screenWidth >= 768) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    final int numColumns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final double videoHeight = isMobile ? 220 : (isTablet ? 280 : 360);

    final double cardWidth = (screenWidth -
            (horizontalPadding * 2) -
            (_responsiveValue(12, 16, 20) * (numColumns - 1))) /
        numColumns;

    List<Map<String, dynamic>> skillsToDisplay = _displaySkillTypes.isNotEmpty
        ? _displaySkillTypes
        : (!_isLoading && _errorMessage != null ? _getDefaultSkillTypes() : []);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
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
                    height: _responsiveValue(52, 72, 80),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            size: _responsiveValue(24, 26, 28),
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.categoryTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(18, 22, 24),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: _responsiveValue(40, 44, 48)),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: GlassLoader(
                            message: 'Loading skills...',
                          ),
                        )
                      : SingleChildScrollView(
                          child: Center(
                            child: Container(
                              constraints:
                                  BoxConstraints(maxWidth: maxContentWidth),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Banner Carousel
                                  SizedBox(
                                    height: _responsiveValue(200, 280, 300),
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: bannerAds.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentCarouselIndex = index;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: double.infinity,
                                          child: Image.network(
                                            bannerAds[index],
                                            width: double.infinity,
                                            height:
                                                _responsiveValue(200, 280, 300),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: _responsiveValue(
                                                    200, 280, 300),
                                                color: const Color(0xFF0052A2),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.broken_image,
                                                        size: 50,
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Advertisement ${index + 1}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                width: double.infinity,
                                                height: _responsiveValue(
                                                    200, 280, 300),
                                                color: const Color(0xFF0052A2),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Dots Indicator
                                  SizedBox(
                                      height: _responsiveValue(12, 16, 20)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        bannerAds.asMap().entries.map((entry) {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width:
                                            _currentCarouselIndex == entry.key
                                                ? _responsiveValue(20, 22, 24)
                                                : _responsiveValue(8, 9, 10),
                                        height: _responsiveValue(8, 9, 10),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: _responsiveValue(4, 5, 6),
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _currentCarouselIndex == entry.key
                                                  ? const Color(0xFF0B5ED7)
                                                  : const Color(0xFFCCCCCC),
                                          borderRadius: BorderRadius.circular(
                                              _responsiveValue(4, 5, 6)),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  // Fallback banner message
                                  if (_adImages.isEmpty && !_isLoadingAds)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: Colors.orange),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 14,
                                              color: Colors.orange[700],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Using default banners',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // Skill Types Section
                                  if (skillsToDisplay.isNotEmpty)
                                    Column(
                                      children: [
                                        // Section Header
                                        Container(
                                          margin: EdgeInsets.all(
                                              _responsiveValue(16, 20, 24)),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFCFE5FA),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical:
                                                _responsiveValue(16, 18, 20),
                                            horizontal:
                                                _responsiveValue(20, 24, 28),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${widget.categoryTitle} Skills',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(
                                                    18, 20, 22),
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF0B5AA7),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Skill Cards Grid
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: horizontalPadding,
                                            vertical:
                                                _responsiveValue(8, 12, 16),
                                          ),
                                          child: Wrap(
                                            spacing:
                                                _responsiveValue(12, 16, 20),
                                            runSpacing:
                                                _responsiveValue(12, 16, 20),
                                            children:
                                                skillsToDisplay.map((skill) {
                                              final skillName =
                                                  skill['name'] as String;
                                              final skillId = skill['id']
                                                  as int; // Get the actual ID
                                              final imageUrl =
                                                  skill['image'] as String?;
                                              final fallbackIcon =
                                                  _getFallbackIcon(skillName);

                                              return _buildSkillCard(
                                                title: skillName,
                                                description:
                                                    skill['shortDescription'] ??
                                                        'Explore this skill',
                                                imageUrl: imageUrl,
                                                fallbackIcon: fallbackIcon,
                                                skillId: skillId, // Pass the ID
                                                width: cardWidth,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),

                                  // Error message with retry
                                  if (_errorMessage != null &&
                                      skillsToDisplay.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 48,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Error loading skills',
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
                                          if (widget.categoryId != null)
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isLoading = true;
                                                  _errorMessage = null;
                                                });
                                                _loadSkillTypes(
                                                    widget.categoryId!);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF0B5ED7),
                                              ),
                                              child: const Text('Retry'),
                                            ),
                                        ],
                                      ),
                                    ),

                                  // YouTube Video Section
                                  if (_youtubeUrls.isNotEmpty) ...[
                                    if (_youtubeUrls.length > 1)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: horizontalPadding,
                                          vertical:
                                              _responsiveValue(12, 16, 20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Videos',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(
                                                    18, 20, 22),
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: _previousVideo,
                                                  icon: const Icon(
                                                      Icons.chevron_left,
                                                      color: Color(0xFF0B5ED7)),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
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
                                                  constraints:
                                                      const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      width: double.infinity,
                                      height: videoHeight,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            _getVideoThumbnail(_youtubeUrls[
                                                _currentVideoIndex]),
                                          ),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {},
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: GestureDetector(
                                              onTap: () => _showUrlDialog(
                                                  _youtubeUrls[
                                                      _currentVideoIndex]),
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
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
                                          if (_youtubeUrls.length > 1)
                                            Positioned(
                                              bottom: 16,
                                              right: 16,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: _previousVideo,
                                                      icon: const Icon(
                                                          Icons.chevron_left,
                                                          color: Colors.white,
                                                          size: 20),
                                                      constraints:
                                                          const BoxConstraints(),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                    Text(
                                                      '${_currentVideoIndex + 1}/${_youtubeUrls.length}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: _nextVideo,
                                                      icon: const Icon(
                                                          Icons.chevron_right,
                                                          color: Colors.white,
                                                          size: 20),
                                                      constraints:
                                                          const BoxConstraints(),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ] else
                                    // Fallback video
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: _responsiveValue(20, 30, 40),
                                      ),
                                      width: double.infinity,
                                      height: videoHeight,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            'https://img.youtube.com/vi/L2zqTYgcpfg/maxresdefault.jpg',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () => _showUrlDialog(
                                              'https://www.youtube.com/embed/L2zqTYgcpfg'),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
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
                        ),
                ),
              ],
            ),
          ),

          // Full screen loader
          if (_isLoading && widget.categoryId != null)
            const GlassLoader(
              message: 'Loading skills...',
            ),
        ],
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildSkillCard({
    required String title,
    required String description,
    String? imageUrl,
    required IconData fallbackIcon,
    required int skillId, // Add this parameter
    required double width,
  }) {
    return GestureDetector(
      onTap: () {
        debugPrint('👉 Navigating to skill: $title with ID: $skillId');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Extraskills3Screen(
              skillTitle: title,
              skillDescription: description,
              typeId: skillId, // Pass the actual skill ID
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: width,
          padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image/Icon Container
              Container(
                width: _responsiveValue(56, 64, 72),
                height: _responsiveValue(56, 64, 72),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(_responsiveValue(12, 14, 16)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2295D2), Color(0xFF284598)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: imageUrl != null && !imageUrl.contains('example.com')
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(_responsiveValue(12, 14, 16)),
                        child: Image.network(
                          imageUrl,
                          width: _responsiveValue(56, 64, 72),
                          height: _responsiveValue(56, 64, 72),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // If image fails to load, show fallback icon
                            return Center(
                              child: Icon(
                                fallbackIcon,
                                size: _responsiveValue(28, 32, 36),
                                color: Colors.white,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          fallbackIcon,
                          size: _responsiveValue(28, 32, 36),
                          color: Colors.white,
                        ),
                      ),
              ),

              SizedBox(height: _responsiveValue(12, 14, 16)),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: _responsiveValue(16, 17, 18),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004780),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: _responsiveValue(8, 9, 10)),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: _responsiveValue(12, 13, 14),
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
      ),
    );
  }

  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External Link'),
        content: Text('Would you like to open the video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening video: $url')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
