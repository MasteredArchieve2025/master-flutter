// lib/pages/Extraskills/Extraskills3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';
import 'Extraskills4.dart';

class Extraskills3Screen extends StatefulWidget {
  final String skillTitle;
  final String skillDescription;
  final int? typeId;

  const Extraskills3Screen({
    super.key,
    required this.skillTitle,
    required this.skillDescription,
    this.typeId,
  });

  @override
  State<Extraskills3Screen> createState() => _Extraskills3ScreenState();
}

class _Extraskills3ScreenState extends State<Extraskills3Screen> {
  int _currentCarouselIndex = 0;
  int _currentVideoIndex = 0;
  final PageController _pageController = PageController();

  // Loading states
  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;

  // API Data
  List<Map<String, dynamic>> _institutions = [];
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];

  // Default banner ads (fallback if API fails)
  final List<String> _defaultBannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  // Default studios data (fallback if API fails)
  final List<Map<String, dynamic>> _defaultStudios = [
    {
      'id': 1,
      'name': 'eMotion Dance Studio',
      'area': 'Nagercoil',
      'district': 'Kanyakumari',
      'state': 'Tamil Nadu',
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=400&fit=crop',
      'rating': 4.8,
      'shortDescription': ['Certified Trainers', 'Practical Sessions', '5.0 Rating'],
    },
    {
      'id': 2,
      'name': 'StepUp Dance Academy',
      'area': 'Marthandam',
      'district': 'Kanyakumari',
      'state': 'Tamil Nadu',
      'image': 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=400&h=400&fit=crop',
      'rating': 4.7,
      'shortDescription': ['Expert Trainers', 'Modern Facilities', 'Flexible Timing'],
    },
    {
      'id': 3,
      'name': 'Rhythm & Beats Studio',
      'area': 'Kanyakumari',
      'district': 'Kanyakumari',
      'state': 'Tamil Nadu',
      'image': 'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400&h=400&fit=crop',
      'rating': 4.9,
      'shortDescription': ['Professional Setup', 'Group Classes', 'Performance Opportunities'],
    },
  ];

  List<String> get bannerAds => _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    if (widget.typeId != null) {
      _loadInstitutions(widget.typeId!);
    } else {
      setState(() {
        _isLoading = false;
      });
      _startAutoScroll();
    }
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for extraskillpage3...');
    
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=extraskillpage3'),
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

  Future<void> _loadInstitutions(int typeId) async {
    debugPrint('🔄 Loading institutions for type $typeId...');
    
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/extra-skill-institutions/type/$typeId'),
      );

      debugPrint('📡 Institutions API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} institutions');

        setState(() {
          _institutions = data.map((item) {
            // Calculate a rating (you can replace this logic)
            double rating = 4.5 + (item['id'] % 5) * 0.1;
            
            // Create a clean copy of the full data
            Map<String, dynamic> fullData = Map<String, dynamic>.from(item);
            
            return {
              'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
              'name': item['name'] ?? 'Unknown Institution',
              'image': item['image'],
              'shortDescription': item['shortDescription'] ?? ['Dance', 'Zumba', 'Fitness'],
              'area': item['area'] ?? '',
              'district': item['district'] ?? '',
              'state': item['state'] ?? '',
              'rating': rating,
              'fullData': fullData, // Store the full data separately
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        debugPrint('⚠️ Institutions API error: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to load institutions';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading institutions: $e');
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
    final double videoHeight = isMobile ? 220 : (isTablet ? 280 : 360);

    // Determine which institutions to display
    List<Map<String, dynamic>> institutionsToDisplay = _institutions.isNotEmpty 
        ? _institutions 
        : (!_isLoading && _errorMessage != null ? _defaultStudios : []);

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
                    height: _responsiveValue(52, 72, 80),
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            size: _responsiveValue(24, 26, 28),
                            color: Colors.white,
                          ),
                        ),
                        // Title
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.skillTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(18, 22, 24),
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Spacer for symmetry
                        SizedBox(width: _responsiveValue(40, 44, 48)),
                      ],
                    ),
                  ),
                ),

                // ===== MAIN CONTENT =====
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: GlassLoader(
                            message: 'Loading institutions...',
                          ),
                        )
                      : SingleChildScrollView(
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: maxContentWidth),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ===== BANNER CAROUSEL (Full width) =====
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
                                            height: _responsiveValue(200, 280, 300),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: _responsiveValue(200, 280, 300),
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
                                                width: double.infinity,
                                                height: _responsiveValue(200, 280, 300),
                                                color: const Color(0xFF0052A2),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
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
                                  SizedBox(height: _responsiveValue(12, 16, 20)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: bannerAds.asMap().entries.map((entry) {
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: _currentCarouselIndex == entry.key 
                                          ? _responsiveValue(20, 22, 24) 
                                          : _responsiveValue(8, 9, 10),
                                        height: _responsiveValue(8, 9, 10),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: _responsiveValue(4, 5, 6),
                                        ),
                                        decoration: BoxDecoration(
                                          color: _currentCarouselIndex == entry.key
                                            ? const Color(0xFF0B5ED7)
                                            : const Color(0xFFCCCCCC),
                                          borderRadius: BorderRadius.circular(_responsiveValue(4, 5, 6)),
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
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.orange),
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

                                  // ===== SKILL DESCRIPTION =====
                                  if (widget.skillDescription.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.all(horizontalPadding),
                                      padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F8FF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE3F2FD),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: _responsiveValue(20, 22, 24),
                                            color: const Color(0xFF1976D2),
                                          ),
                                          SizedBox(width: _responsiveValue(12, 14, 16)),
                                          Expanded(
                                            child: Text(
                                              widget.skillDescription,
                                              style: TextStyle(
                                                fontSize: _responsiveValue(14, 15, 16),
                                                color: const Color(0xFF333333),
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // ===== INSTITUTIONS HEADER =====
                                  Container(
                                    margin: EdgeInsets.fromLTRB(
                                      horizontalPadding,
                                      _responsiveValue(24, 28, 32),
                                      horizontalPadding,
                                      _responsiveValue(12, 16, 20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Available Institutions',
                                          style: TextStyle(
                                            fontSize: _responsiveValue(20, 22, 24),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF004780),
                                          ),
                                        ),
                                        Text(
                                          '${institutionsToDisplay.length} found',
                                          style: TextStyle(
                                            fontSize: _responsiveValue(14, 15, 16),
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ===== INSTITUTIONS LIST =====
                                  if (institutionsToDisplay.isEmpty)
                                    Container(
                                      margin: EdgeInsets.all(horizontalPadding),
                                      padding: EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No institutions found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Check back later for listings',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                      child: Column(
                                        children: institutionsToDisplay.map((institution) {
                                          return _buildStudioCard(
                                            institution: institution,
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                  // Error message with retry
                                  if (_errorMessage != null && institutionsToDisplay.isEmpty)
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
                                            'Error loading institutions',
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
                                          if (widget.typeId != null)
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isLoading = true;
                                                  _errorMessage = null;
                                                });
                                                _loadInstitutions(widget.typeId!);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF0B5ED7),
                                              ),
                                              child: const Text('Retry'),
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
                                          vertical: _responsiveValue(12, 16, 20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Videos',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(18, 20, 22),
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
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
                                            _getVideoThumbnail(_youtubeUrls[_currentVideoIndex]),
                                          ),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {},
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: GestureDetector(
                                              onTap: () => _showUrlDialog(_youtubeUrls[_currentVideoIndex]),
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
                                          onTap: () => _showUrlDialog('https://www.youtube.com/embed/L2zqTYgcpfg'),
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
                        ),
                ),
              ],
            ),
          ),
          
          // Full screen loader
          if (_isLoading && widget.typeId != null)
            const GlassLoader(
              message: 'Loading institutions...',
            ),
        ],
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildStudioCard({
    required Map<String, dynamic> institution,
  }) {
    // Get location string
    String location = '';
    if (institution['area'] != null && institution['area'].toString().isNotEmpty) {
      location += institution['area'];
    }
    if (institution['district'] != null && institution['district'].toString().isNotEmpty) {
      if (location.isNotEmpty) location += ', ';
      location += institution['district'];
    }
    if (institution['state'] != null && institution['state'].toString().isNotEmpty) {
      if (location.isNotEmpty) location += ', ';
      location += institution['state'];
    }
    
    if (location.isEmpty) {
      location = 'Location not specified';
    }

    // Get short description as features
    List<String> features = [];
    if (institution['shortDescription'] != null && institution['shortDescription'] is List) {
      features = List<String>.from(institution['shortDescription']);
    } else {
      features = ['Dance', 'Zumba', 'Fitness'];
    }

    // Get rating
    double rating = institution['rating'] ?? 4.5;

    return GestureDetector(
      onTap: () {
        // Safely get the full data to pass to next screen
        Map<String, dynamic> dataToPass;
        if (institution.containsKey('fullData') && institution['fullData'] != null) {
          dataToPass = Map<String, dynamic>.from(institution['fullData']);
        } else {
          // Create a clean copy of the current data
          dataToPass = Map<String, dynamic>.from(institution);
          // Remove the fullData key if it exists to avoid circular reference
          dataToPass.remove('fullData');
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Extraskills4Screen(
              institution: dataToPass,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: EdgeInsets.only(bottom: _responsiveValue(16, 18, 20)),
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
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Institution Image
              Container(
                width: _responsiveValue(70, 80, 90),
                height: _responsiveValue(70, 80, 90),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD1E9FF),
                    width: 1.5,
                  ),
                ),
                child: institution['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          institution['image'],
                          width: _responsiveValue(70, 80, 90),
                          height: _responsiveValue(70, 80, 90),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.business,
                                size: _responsiveValue(40, 45, 50),
                                color: const Color(0xFF0052A2),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.business,
                          size: _responsiveValue(40, 45, 50),
                          color: const Color(0xFF0052A2),
                        ),
                      ),
              ),
              
              SizedBox(width: _responsiveValue(16, 18, 20)),
              
              // Institution Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Institution Name
                    Text(
                      institution['name'] ?? 'Unknown Institution',
                      style: TextStyle(
                        fontSize: _responsiveValue(18, 20, 22),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007BFF),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: _responsiveValue(8, 9, 10)),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: _responsiveValue(16, 17, 18),
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              color: const Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: _responsiveValue(12, 14, 16)),
                    
                    // Features
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: features.take(3).map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _responsiveValue(10, 12, 14),
                            vertical: _responsiveValue(5, 6, 7),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE3F2FD),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: _responsiveValue(12, 13, 14),
                              color: const Color(0xFF0052A2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    // Rating and Actions Row
                    SizedBox(height: _responsiveValue(12, 14, 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: _responsiveValue(18, 20, 22),
                              color: const Color(0xFFFFB800),
                            ),
                            SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: _responsiveValue(14, 15, 16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        
                        // View Details Button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _responsiveValue(16, 18, 20),
                            vertical: _responsiveValue(8, 9, 10),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0052A2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show URL dialog for YouTube
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