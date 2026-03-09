// lib/pages/Extraskills/Extraskills3.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/CommonYoutubePlayer.dart';
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
  int _activeAdIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Loading states
  bool _isLoading = true;
  bool _isAdsLoading = true;
  String? _errorMessage;

  // API Data
  List<Map<String, dynamic>> institutions = [];
  List<String> adImages = [];
  List<String> youtubeUrls = [];

  // Default studios data (fallback if API fails)
  final List<Map<String, dynamic>> _defaultStudios = [
    {
      'id': 1,
      'name': 'eMotion Dance Studio',
      'area': 'Nagercoil',
      'district': 'Kanyakumari',
      'state': 'Tamil Nadu',
      'image':
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=400&fit=crop',
      'rating': 4.8,
      'shortDescription': [
        'Certified Trainers',
        'Practical Sessions',
        '5.0 Rating'
      ],
    },
    {
      'id': 2,
      'name': 'StepUp Dance Academy',
      'area': 'Marthandam',
      'district': 'Kanyakumari',
      'state': 'Tamil Nadu',
      'image':
          'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=400&h=400&fit=crop',
      'rating': 4.7,
      'shortDescription': [
        'Expert Trainers',
        'Modern Facilities',
        'Flexible Timing'
      ],
    },
    {
      'id': 3,
      'name': 'Rhythm & Beats Studio',
      'area': 'Kanyakumari',
      'district': 'Kanyakumari',
      'state': 'Tamil Nadu',
      'image':
          'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400&h=400&fit=crop',
      'rating': 4.9,
      'shortDescription': [
        'Professional Setup',
        'Group Classes',
        'Performance Opportunities'
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();
    if (widget.typeId != null) {
      _fetchInstitutions(widget.typeId!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }

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
    debugPrint('🔄 Loading advertisements for extraskillpage3...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=extraskillpage3'),
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

  Future<void> _fetchInstitutions(int typeId) async {
    debugPrint('🔄 Loading institutions for type $typeId...');

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/extra-skill-institutions/type/$typeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Institutions API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} institutions');

        setState(() {
          institutions = data.map((item) {
            // Fix image URL if needed
            String? imageUrl = item['image'];
            if (imageUrl != null && imageUrl.isNotEmpty) {
              if (!imageUrl.startsWith('http')) {
                imageUrl = '${BaseUrl.baseUrl}$imageUrl';
              }
            }

            // Calculate a rating (you can replace this logic)
            double rating = 4.5 + (item['id'] % 5) * 0.1;

            return {
              'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
              'name': item['name'] ?? 'Unknown Institution',
              'image': imageUrl,
              'shortDescription':
                  item['shortDescription'] ?? ['Dance', 'Zumba', 'Fitness'],
              'area': item['area'] ?? '',
              'district': item['district'] ?? '',
              'state': item['state'] ?? '',
              'rating': rating,
              'fullData': item, // Store the full data separately
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load institutions. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading institutions: $e');
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
    _fetchAdvertisements();
    if (widget.typeId != null) {
      _fetchInstitutions(widget.typeId!);
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
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;

    // Calculate header height
    final double headerHeight = _responsiveValue(52, 58, 80);

    // Determine which institutions to display
    List<Map<String, dynamic>> institutionsToDisplay = institutions.isNotEmpty
        ? institutions
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
                              widget.skillTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(20, 22, 24),
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
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
                            message: 'Loading institutions...',
                          ),
                        )
                      : _errorMessage != null && institutions.isEmpty && institutionsToDisplay.isEmpty
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

                                                  // ===== SKILL DESCRIPTION SECTION =====
                                                  if (widget.skillDescription.isNotEmpty)
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
                                                            'About',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  _responsiveValue(
                                                                      20, 22, 24),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: const Color(
                                                                  0xFF003366),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  _scale(8)),

                                                          // Description
                                                          Container(
                                                            padding: EdgeInsets.all(
                                                                _responsiveValue(
                                                                    16,
                                                                    18,
                                                                    20)),
                                                            decoration: BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF0F8FF),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border: Border.all(
                                                                color: const Color(
                                                                    0xFFE3F2FD),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .info_outline,
                                                                  size:
                                                                      _responsiveValue(
                                                                          20,
                                                                          22,
                                                                          24),
                                                                  color:
                                                                      const Color(
                                                                          0xFF1976D2),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        _responsiveValue(
                                                                            12,
                                                                            14,
                                                                            16)),
                                                                Expanded(
                                                                  child: Text(
                                                                    widget
                                                                        .skillDescription,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          _responsiveValue(
                                                                              14,
                                                                              15,
                                                                              16),
                                                                      color: const Color(
                                                                          0xFF333333),
                                                                      height:
                                                                          1.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  // ===== INSTITUTIONS SECTION =====
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
                                                        // Section Title with count
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Available Institutions',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    _responsiveValue(
                                                                        20,
                                                                        22,
                                                                        24),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    const Color(
                                                                        0xFF003366),
                                                              ),
                                                            ),
                                                            Text(
                                                              '${institutionsToDisplay.length} found',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    _responsiveValue(
                                                                        14,
                                                                        15,
                                                                        16),
                                                                color: Colors
                                                                    .grey[600],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                _responsiveValue(
                                                                    20,
                                                                    24,
                                                                    28)),

                                                        // Institutions List
                                                        if (institutionsToDisplay
                                                            .isEmpty)
                                                          Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(32),
                                                              child: Column(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .location_off,
                                                                    size: 64,
                                                                    color: Colors
                                                                            .grey[
                                                                        400],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),
                                                                  Text(
                                                                    'No institutions found',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height: 8),
                                                                  Text(
                                                                    'Check back later for listings',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                              .grey[
                                                                          500],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        else
                                                          Column(
                                                            children:
                                                                institutionsToDisplay
                                                                    .map((institution) {
                                                              return _buildInstitutionCard(
                                                                institution:
                                                                    institution,
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
                                                          'Expert Training Institutes',
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
                                                          'Get trained by professionals and achieve your goals',
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
          if (_isLoading && widget.typeId != null)
            const GlassLoader(
              message: 'Loading institutions...',
            ),
        ],
      ),
    );
  }

  Widget _buildInstitutionCard({
    required Map<String, dynamic> institution,
  }) {
    // Get location string
    String location = '';
    if (institution['area'] != null &&
        institution['area'].toString().isNotEmpty) {
      location += institution['area'];
    }
    if (institution['district'] != null &&
        institution['district'].toString().isNotEmpty) {
      if (location.isNotEmpty) location += ', ';
      location += institution['district'];
    }
    if (institution['state'] != null &&
        institution['state'].toString().isNotEmpty) {
      if (location.isNotEmpty) location += ', ';
      location += institution['state'];
    }

    if (location.isEmpty) {
      location = 'Location not specified';
    }

    // Get short description as features
    List<String> features = [];
    if (institution['shortDescription'] != null &&
        institution['shortDescription'] is List) {
      features = List<String>.from(institution['shortDescription']);
    } else {
      features = ['Dance', 'Zumba', 'Fitness'];
    }

    // Get rating
    double rating = institution['rating'] ?? 4.5;

    return GestureDetector(
      onTap: () {
        // Get the full data to pass to next screen
        Map<String, dynamic> dataToPass;
        if (institution.containsKey('fullData') &&
            institution['fullData'] != null) {
          dataToPass = Map<String, dynamic>.from(institution['fullData']);
        } else {
          dataToPass = Map<String, dynamic>.from(institution);
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
      child: Container(
        margin: EdgeInsets.only(bottom: _responsiveValue(16, 18, 20)),
        padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Institution Image
            Container(
              width: _responsiveValue(80, 90, 100),
              height: _responsiveValue(80, 90, 100),
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
                        width: _responsiveValue(80, 90, 100),
                        height: _responsiveValue(80, 90, 100),
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
                      fontSize: _responsiveValue(16, 18, 20),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF007BFF),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: _responsiveValue(6, 7, 8)),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: _responsiveValue(14, 15, 16),
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: _responsiveValue(12, 13, 14),
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: _responsiveValue(10, 12, 14)),

                  // Features
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: features.take(3).map((feature) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _responsiveValue(8, 10, 12),
                          vertical: _responsiveValue(4, 5, 6),
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
                            fontSize: _responsiveValue(11, 12, 13),
                            color: const Color(0xFF0052A2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Rating and Actions Row
                  SizedBox(height: _responsiveValue(10, 12, 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: _responsiveValue(16, 18, 20),
                            color: const Color(0xFFFFB800),
                          ),
                          SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: _responsiveValue(13, 14, 15),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),

                      // View Details Button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _responsiveValue(12, 14, 16),
                          vertical: _responsiveValue(6, 7, 8),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052A2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: _responsiveValue(12, 13, 14),
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
    );
  }
}