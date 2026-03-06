// lib/pages/Exam/Exam3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/footer.dart';
import 'Exam_details.dart';
import 'Exam_institution_list.dart';
import '../../Api/baseurl.dart';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../components/glass_loader.dart';

class Exam3Screen extends StatefulWidget {
  final Map<String, dynamic>? examData;

  const Exam3Screen({
    super.key,
    this.examData,
  });

  @override
  State<Exam3Screen> createState() => _Exam3ScreenState();
}

class _Exam3ScreenState extends State<Exam3Screen> {
  // Loading states
  bool _isLoadingAds = true;
  String? _adErrorMessage;

  // API Data
  List<String> adImages = [];
  List<String> youtubeUrls = [];

  // Grid items
  final List<Map<String, dynamic>> gridItems = [
    {
      'title': 'Exam Details',
      'subtitle': 'Explore complete exam information',
      'icon': Icons.description,
      'color': Color(0xFF4A90E2),
      'route': 'ExamDetailsFull',
    },
    {
      'title': 'Institutions',
      'subtitle': 'Explore top tuition centers',
      'icon': Icons.business,
      'color': Color(0xFF50C878),
      'route': 'InstitutionsList',
    },
  ];

  int _activeBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();

    // Auto scroll banners
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients && mounted && adImages.isNotEmpty) {
        int nextPage = _activeBannerIndex + 1;
        if (nextPage >= adImages.length) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _fetchAdvertisements() async {
    debugPrint('🔄 Loading advertisements for exampage3...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=exampage3'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (mounted) {
            setState(() {
              adImages = List<String>.from(data['data']['images'] ?? []);
              youtubeUrls =
                  List<String>.from(data['data']['youtube_urls'] ?? []);
              _isLoadingAds = false;
            });
            debugPrint('✅ Loaded ${adImages.length} images from API');
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingAds = false;
            _adErrorMessage = 'Failed to load ads';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading advertisements: $e');
      if (mounted) {
        setState(() {
          _isLoadingAds = false;
          _adErrorMessage = e.toString();
        });
      }
    }
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
    _bannerTimer?.cancel();
    _bannerController.dispose();
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

  // Show URL dialog
  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External Link'),
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

    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double bannerHeight = _responsiveValue(200, 300, 300);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0052A2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: _responsiveValue(52, 58, 80),
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
                          'Exam Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(18, 20, 22),
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
              child: LayoutBuilder(
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
                            constraints:
                                BoxConstraints(maxWidth: maxContentWidth),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ===== BANNER SLIDER =====
                                    if (adImages.isNotEmpty)
                                      SizedBox(
                                        width: screenWidth,
                                        height: bannerHeight,
                                        child: PageView.builder(
                                          controller: _bannerController,
                                          itemCount: adImages.length,
                                          onPageChanged: (index) {
                                            setState(() {
                                              _activeBannerIndex = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            return Image.network(
                                              adImages[index],
                                              width: screenWidth,
                                              height: bannerHeight,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: screenWidth,
                                                  height: bannerHeight,
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
                                    else if (_isLoadingAds)
                                      Container(
                                        width: screenWidth,
                                        height: bannerHeight,
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
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F8FF),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: _scale(12)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                              adImages.length, (index) {
                                            return AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              width: _activeBannerIndex == index
                                                  ? _scale(16)
                                                  : _scale(8),
                                              height: _scale(8),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: _scale(4)),
                                              decoration: BoxDecoration(
                                                color: _activeBannerIndex ==
                                                        index
                                                    ? const Color(0xFF0B5ED7)
                                                    : const Color(0xFFCCCCCC),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        _scale(4)),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),

                                    // ===== BREATHING SPACE AFTER BANNER =====
                                    SizedBox(
                                        height: _responsiveValue(24, 130, 40)),
                                    
                                    // ===== 2 COLUMN GRID =====
                                    // Center the grid section
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: horizontalPadding),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: gridItems.map((item) {
                                            return Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  right: item == gridItems.first
                                                      ? _scale(12)
                                                      : 0,
                                                  left: item == gridItems.last
                                                      ? _scale(12)
                                                      : 0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (item['route'] ==
                                                        'ExamDetailsFull') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ExamDetailsFullScreen(
                                                            examData:
                                                                widget.examData,
                                                          ),
                                                        ),
                                                      );
                                                    } else if (item['route'] ==
                                                        'InstitutionsList') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              InstitutionsListScreen(),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              _scale(22)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.08),
                                                          blurRadius: _scale(8),
                                                          offset: Offset(
                                                              0, _scale(4)),
                                                        ),
                                                      ],
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        _responsiveValue(
                                                            20, 24, 28)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: _scale(50),
                                                          height: _scale(50),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: (item['color']
                                                                    as Color)
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        _scale(
                                                                            12)),
                                                          ),
                                                          child: Icon(
                                                            item['icon']
                                                                as IconData,
                                                            size: _scale(30),
                                                            color: item['color']
                                                                as Color,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: _scale(12)),
                                                        Text(
                                                          item['title']
                                                              as String,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    14, 16, 18),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: const Color(
                                                                0xFF003366),
                                                            height: 1.2,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: _scale(6)),
                                                        Text(
                                                          item['subtitle']
                                                              as String,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    11, 12, 13),
                                                            color: const Color(
                                                                0xFF666666),
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),

                                    // ===== ADDITIONAL SPACING BEFORE VIDEOS =====
                                    if (youtubeUrls.isNotEmpty)
                                      SizedBox(
                                          height: _responsiveValue(24, 32, 40)),
                                  ],
                                ),

                                // ===== YOUTUBE VIDEO SECTION =====
                                if (youtubeUrls.isNotEmpty)
                                  Column(
                                    children: [
                                      // Center the video title
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: horizontalPadding,
                                          vertical:
                                              _responsiveValue(8, 12, 16),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.red,
                                                  size: 28),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Video Tutorials',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(
                                                      18, 20, 22),
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFF003366),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Center the videos
                                      ...youtubeUrls
                                          .map((url) => Center(
                                                child: Container(
                                                  width: screenWidth,
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          maxContentWidth),
                                                  child: CommonYoutubePlayer(
                                                    youtubeUrl: url,
                                                    height: isDesktop
                                                        ? 400
                                                        : (isTablet ? 320 : 250),
                                                    placeholderThumbnail:
                                                        _getYoutubeThumbnail(
                                                            url),
                                                    borderRadius: 0,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  )
                                else
                                  const SizedBox.shrink(),
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
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }
}