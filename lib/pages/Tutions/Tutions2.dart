import 'package:flutter/material.dart';
import 'package:master/components/glass_loader.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/Footer.dart';
import 'Tutions3.dart';
import '../../Api/School/tution_service.dart';
import '../../Api/baseurl.dart';

// ==================== TUITION INSTITUTES SCREEN ====================
class Tution2Screen extends StatefulWidget {
  final String selectedClass;

  const Tution2Screen({super.key,
    required this.selectedClass,
  });

  @override
  State<Tution2Screen> createState() => _Tution2ScreenState();
}

class _Tution2ScreenState extends State<Tution2Screen> {
  int _footerIndex = 0;
  int _adIndex = 0;
  int _currentVideoIndex = 0;
  bool _showAll = false;
  final PageController _adController = PageController();
  Timer? _timer;
  
  bool _isLoading = true;
  String? _errorMessage;
  List<Tution> _tuitions = [];
  List<Tution> _filteredTuitions = [];

  // Advertisement Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  
  // Default ads (fallback if API fails)
  final List<String> defaultAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200',
  ];

  List<String> get ads => _adImages.isNotEmpty ? _adImages : defaultAds;

  List<Tution> get visibleInstitutes {
    return _showAll ? _filteredTuitions : _filteredTuitions.take(3).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    _loadTuitions();
    // Auto scroll ads
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adController.hasClients && mounted) {
        int nextPage = _adIndex + 1;
        if (nextPage >= ads.length) nextPage = 0;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=tuitionspage2'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          
          setState(() {
            // Parse images
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
            }
            
            // Parse youtube URLs
            if (apiData['youtube_urls'] != null && apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading advertisements: $e');
      // Continue with default ads
    }
  }

  Future<void> _loadTuitions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await TutionService().fetchTuitions();
      final tuitions = data.map((json) => Tution.fromJson(json)).toList();
      
      // Add small delay to ensure loader is visible
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _tuitions = tuitions;
          _filterTuitions();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterTuitions() {
    final query = widget.selectedClass.toUpperCase();
    _filteredTuitions = _tuitions.where((t) {
      return t.category.contains(query);
    }).toList();
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
      _currentVideoIndex = (_currentVideoIndex - 1 + _youtubeUrls.length) % _youtubeUrls.length;
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
    _timer?.cancel();
    _adController.dispose();
    super.dispose();
  }

  // Responsive header height like IQ1
  double _getHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 64;
    if (screenWidth >= 768) return 58;
    return 52;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    final double horizontalPadding = _getHorizontalPadding(context);
    final double adHeight = isTablet ? 220 : 180;
    final double bannerPadding = isTablet ? 24 : 16;
    final double cardPadding = isTablet ? 20 : 14;
    final double cardMargin = isTablet ? 20 : 14;
    final double videoHeight = isTablet ? 280 : 220;
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // Header
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
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    height: _getHeaderHeight(context),
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tuition Institutes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _getTitleFontSize(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Ads from API
                        SizedBox(
                          height: adHeight,
                          child: PageView.builder(
                            controller: _adController,
                            itemCount: ads.length,
                            onPageChanged: (index) {
                              setState(() {
                                _adIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                width: screenWidth,
                                color: const Color(0xFFF0F0F0),
                                child: Image.network(
                                  ads[index],
                                  width: screenWidth,
                                  height: adHeight,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: screenWidth,
                                      height: adHeight,
                                      color: const Color(0xFF0052A2),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.white.withOpacity(0.5),
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
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: screenWidth,
                                      height: adHeight,
                                      color: const Color(0xFF0052A2),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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

                        // Dots
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(ads.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _adIndex == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: _adIndex == index 
                                  ? const Color(0xFF0B5ED7) 
                                  : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // Banner
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isTablet ? 24 : 16,
                          ),
                          padding: EdgeInsets.all(bannerPadding),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B5ED7),
                            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0B5ED7).withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Tuition Centers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 24 : 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find the best educators near you for Grade 10 ${widget.selectedClass}',
                                style: TextStyle(
                                  color: const Color(0xFFDCE8FF),
                                  fontSize: isTablet ? 16 : 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Error Message
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                _errorMessage!, 
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          )

                        // Empty State
                        else if (!_isLoading && _filteredTuitions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Text('No tuition centers found for this class.'),
                            ),
                          )

                        // Institute List
                        else if (!_isLoading && _filteredTuitions.isNotEmpty) ...[
                          // Section Header
                          Container(
                            margin: EdgeInsets.only(
                              left: horizontalPadding,
                              right: horizontalPadding,
                              top: isTablet ? 8 : 4,
                              bottom: isTablet ? 16 : 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nearby Institutes',
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Institute Cards
                          ...visibleInstitutes.map((item) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Tution3Screen(
                                        instituteName: item.tuitionName,
                                        instituteData: item.toJson(),
                                      ),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(
                                    left: horizontalPadding,
                                    right: horizontalPadding,
                                    bottom: cardMargin,
                                  ),
                                  padding: EdgeInsets.all(cardPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: isTablet ? 120 : 90,
                                        height: isTablet ? 120 : 90,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                                          child: item.tuitionImage != null
                                              ? Image.network(
                                                  item.tuitionImage!,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Container(
                                                      color: Colors.grey[100],
                                                      child: const Center(
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B5ED7)),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) => 
                                                      const Icon(Icons.school, size: 40, color: Colors.grey),
                                                )
                                              : const Icon(Icons.school, size: 40, color: Colors.grey),
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.tuitionName,
                                                    style: TextStyle(
                                                      fontSize: isTablet ? 20 : 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFF9E6),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: Color(0xFFFFB703),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        item.rating.toString(),
                                                        style: TextStyle(
                                                          fontSize: isTablet ? 16 : 12,
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

                                            Text(
                                              item.subjectsOffered.join(', '),
                                              style: TextStyle(
                                                fontSize: isTablet ? 15 : 12,
                                                color: Colors.black,
                                                height: 1.5,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            const SizedBox(height: 12),

                                            Row(
                                              children: [
                                                if (item.teachingMode.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFE8F1FF),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      item.teachingMode.first,
                                                      style: TextStyle(
                                                        fontSize: isTablet ? 14 : 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF0B5ED7),
                                                      ),
                                                    ),
                                                  ),

                                                const SizedBox(width: 8),

                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF1F3F6),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      item.location,
                                                      style: TextStyle(
                                                        fontSize: isTablet ? 14 : 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF5F6F81),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.chevron_right,
                                        size: isTablet ? 28 : 20,
                                        color: const Color(0xFF0B5ED7),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          // See All / See Less
                          if (_filteredTuitions.length > 3)
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAll = !_showAll;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                    vertical: isTablet ? 24 : 16,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 12 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F1FF),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _showAll ? "See less" : "See all institutes",
                                        style: TextStyle(
                                          color: const Color(0xFF0B5ED7),
                                          fontSize: isTablet ? 18 : 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _showAll ? Icons.expand_less : Icons.expand_more,
                                        size: isTablet ? 22 : 16,
                                        color: const Color(0xFF0B5ED7),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],

                        // Video Section with API videos
                        if (_youtubeUrls.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(
                              left: horizontalPadding,
                              right: horizontalPadding,
                              top: isTablet ? 40 : 32,
                              bottom: isTablet ? 16 : 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _youtubeUrls.length > 1 ? 'Videos' : 'Video',
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                if (_youtubeUrls.length > 1)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _previousVideo,
                                        icon: const Icon(Icons.chevron_left, color: Color(0xFF0B5ED7)),
                                        constraints: const BoxConstraints(),
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
                                        icon: const Icon(Icons.chevron_right, color: Color(0xFF0B5ED7)),
                                        constraints: const BoxConstraints(),
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
                                _youtubeUrls.isNotEmpty
                                    ? _getVideoThumbnail(_youtubeUrls[_currentVideoIndex])
                                    : 'https://img.youtube.com/vi/PHJVAQ6kFHM/maxresdefault.jpg',
                              ),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
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
                              if (_youtubeUrls.length > 1)
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: _previousVideo,
                                          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        Text(
                                          '${_currentVideoIndex + 1}/${_youtubeUrls.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: _nextVideo,
                                          icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
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

            // Glass Loader
            if (_isLoading)
              const GlassLoader(
                message: 'Loading tuition centers...',
              ),
          ],
        ),
      ),
    );
  }
}