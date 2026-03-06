// lib/pages/IQ/IQ1.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../components/glass_loader.dart';
import '../../api/baseurl.dart';
import 'IQ2.dart';

class IQ1Screen extends StatefulWidget {
  const IQ1Screen({super.key});

  @override
  State<IQ1Screen> createState() => _IQ1ScreenState();
}

class _IQ1ScreenState extends State<IQ1Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _iqTests = [];
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;

  final List<String> _defaultBannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  final Map<String, IconData> _testIcons = {
    'Technical': Icons.computer,
    'Advanced IQ Assessment': Icons.psychology,
    'Brain IQ test': Icons.psychology_alt,
    'Logical Reasoning': Icons.account_tree,
    'Mathematical Reasoning': Icons.calculate,
    'Spatial ability': Icons.threed_rotation,
    'Verbal Ability': Icons.chat,
    'Memory Test': Icons.memory,
  };

  final List<List<Color>> _gradientColors = [
    [const Color(0xFF0072BC), const Color(0xFF0052A2)],
    [const Color(0xFF00C9FF), const Color(0xFF0072BC)],
    [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
    [const Color(0xFF7F00FF), const Color(0xFFE100FF)],
    [const Color(0xFF00B09B), const Color(0xFF96C93D)],
    [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
  ];

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  @override
  void initState() {
    super.initState();
    _fetchIQTests();
    _loadAdvertisements();
    _startAdTimer();
  }

  Future<void> _fetchIQTests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/iq/tests'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'];
          setState(() {
            _iqTests = List<Map<String, dynamic>>.from(dataList);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'Invalid response format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load tests: ${response.statusCode}';
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

  Future<void> _loadAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=iqpage1'),
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
          setState(() => _isLoadingAds = false);
        }
      } else {
        setState(() => _isLoadingAds = false);
      }
    } catch (e) {
      debugPrint('❌ Error loading advertisements: $e');
      setState(() => _isLoadingAds = false);
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
    super.dispose();
  }

  double _scale(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return size * 1.2;
    if (screenWidth >= 768) return size * 1.1;
    return size;
  }

  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop;
    if (screenWidth >= 768) return tablet;
    return mobile;
  }

  IconData _getTestIcon(String title) => _testIcons[title] ?? Icons.quiz;

  List<Color> _getTestGradient(int index) =>
      _gradientColors[index % _gradientColors.length];

  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTube Video'),
        content: Text('Would you like to open: $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening: $url')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final double cardMargin = _responsiveValue(15, 20, 25);
    final double cardWidth = (screenWidth - cardMargin * 3) / 2;
    final double cardHeight = cardWidth;
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    height: _responsiveValue(52, 58, 64),
                    child: Row(
                      children: [
                        Container(
                          width: _scale(40),
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              size: _scale(24),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'IQ Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(17, 18, 19),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: _scale(40)),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: _scale(20)),

                            // Top Banner
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: cardMargin),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0072BC),
                                    Color(0xFF0052A2)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    BorderRadius.circular(_scale(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0072BC)
                                        .withOpacity(0.25),
                                    blurRadius: _scale(6),
                                    offset: Offset(0, _scale(2)),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(_scale(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Measure Your Intelligence',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(20, 22, 24),
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: _scale(5)),
                                  Text(
                                    'Complete tests to get your comprehensive IQ score',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(14, 15, 16),
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: _scale(20)),

                            // Section Header
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: cardMargin),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Choose Test Type',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(18, 19, 20),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF003366),
                                    ),
                                  ),
                                  Text(
                                    '${_iqTests.length} tests available',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(14, 15, 16),
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: _scale(15)),

                            // Tests Grid
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: cardMargin),
                              child: _buildTestsContent(
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                                cardMargin: cardMargin,
                              ),
                            ),

                            // Progress Section
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: cardMargin,
                                vertical: _scale(20),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(_scale(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: _scale(4),
                                    offset: Offset(0, _scale(2)),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(_scale(20)),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your Progress',
                                        style: TextStyle(
                                          fontSize:
                                              _responsiveValue(16, 17, 18),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF003366),
                                        ),
                                      ),
                                      Text(
                                        '0%',
                                        style: TextStyle(
                                          fontSize:
                                              _responsiveValue(16, 17, 18),
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0072BC),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: _scale(12)),
                                  Container(
                                    height: _scale(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9ECEF),
                                      borderRadius:
                                          BorderRadius.circular(_scale(4)),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0072BC),
                                          borderRadius:
                                              BorderRadius.circular(_scale(4)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: _scale(8)),
                                  Text(
                                    '0 of ${_iqTests.length} tests completed',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(14, 15, 16),
                                      color: const Color(0xFF666666),
                                    ),
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
                                    vertical: isTablet ? 16 : 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'IQ Test Videos',
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
                                            icon: const Icon(
                                                Icons.chevron_left,
                                                color: Color(0xFF0052A2)),
                                          ),
                                          Text(
                                            '${_currentVideoIndex + 1}/${_youtubeUrls.length}',
                                            style: const TextStyle(
                                              color: Color(0xFF0052A2),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: _nextVideo,
                                            icon: const Icon(
                                                Icons.chevron_right,
                                                color: Color(0xFF0052A2)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: _youtubeUrls.length > 1
                                      ? 0
                                      : (isTablet ? 20 : 10),
                                ),
                                width: double.infinity,
                                height:
                                    isDesktop ? 400 : (isTablet ? 320 : 250),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      _getVideoThumbnail(
                                          _youtubeUrls[_currentVideoIndex]),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () => _showUrlDialog(
                                        _youtubeUrls[_currentVideoIndex]),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
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
                            ] else
                              Container(
                                margin: EdgeInsets.only(
                                    top: isTablet ? 20 : 10),
                                width: double.infinity,
                                height:
                                    isDesktop ? 400 : (isTablet ? 320 : 250),
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
                                            color:
                                                Colors.black.withOpacity(0.3),
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
          if (_isLoading) const GlassLoader(message: 'Loading IQ tests...'),
        ],
      ),
      bottomNavigationBar: Footer(
        currentIndex: _footerIndex,
        onItemTapped: (index) {
          setState(() => _footerIndex = index);
        },
      ),
    );
  }

  Widget _buildTestsContent({
    required double cardWidth,
    required double cardHeight,
    required double cardMargin,
  }) {
    if (_isLoading) return const SizedBox(height: 200);

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load IQ tests',
                style: TextStyle(
                  fontSize: _responsiveValue(16, 17, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _responsiveValue(14, 15, 16),
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchIQTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052A2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_iqTests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.quiz_outlined, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No IQ tests available',
                style: TextStyle(
                  fontSize: _responsiveValue(16, 17, 18),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: cardMargin,
      runSpacing: cardMargin,
      children: _iqTests.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map<String, dynamic> test = entry.value;
        final String title = test['title'] ?? 'Untitled Test';
        final int totalQuestions = test['total_questions'] ?? 0;
        final int timeLimitMinutes = test['time_limit_minutes'] ?? 0;
        final String difficultyLevel = test['difficulty_level'] ?? 'medium';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IQ2Screen(testData: test),
              ),
            );
          },
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_scale(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: _scale(8),
                  offset: Offset(0, _scale(4)),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Gradient Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getTestGradient(index),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(_scale(16)),
                  ),
                  child: Center(
                    child: Icon(
                      _getTestIcon(title),
                      size: cardWidth * 0.3,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_scale(16)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                // Text Content
                Positioned(
                  bottom: _scale(12),
                  left: _scale(12),
                  right: _scale(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _responsiveValue(16, 17, 18),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.75),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              difficultyLevel.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$totalQuestions Q · ${timeLimitMinutes}m',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Play button
                Positioned(
                  top: _scale(12),
                  right: _scale(12),
                  child: Container(
                    width: _scale(28),
                    height: _scale(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052A2).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(_scale(14)),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: _scale(1.5),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: _scale(12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}