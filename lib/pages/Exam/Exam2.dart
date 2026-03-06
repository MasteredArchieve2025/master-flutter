// lib/pages/Exam/Exam2.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../components/glass_loader.dart';
import 'Exam3.dart';

class Exam2Screen extends StatefulWidget {
  final Map<String, dynamic>? examData; // Exam data passed from Exam1

  const Exam2Screen({
    super.key,
    this.examData,
  });

  @override
  State<Exam2Screen> createState() => _Exam2ScreenState();
}

class _Exam2ScreenState extends State<Exam2Screen> {
  int _activeAdIndex = 0;
  int _activeTabIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Loading states
  bool _isLoading = true;
  bool _isAdsLoading = true;
  String? _errorMessage;

  // API Data
  List<Map<String, dynamic>> examTypes = [];
  List<String> adImages = [];
  List<String> youtubeUrls = [];

  // Tab categories - will be dynamically created from API data
  final List<Map<String, dynamic>> tabs = [
    {'id': 'all', 'label': 'All Exams'},
  ];

  // Color palette for exam cards
  final List<Color> cardColors = [
    const Color(0xFF4A90E2), // Blue
    const Color(0xFF50C878), // Green
    const Color(0xFFFF6B6B), // Red
    const Color(0xFFFFA500), // Orange
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF1ABC9C), // Turquoise
    const Color(0xFFE67E22), // Carrot
    const Color(0xFF3498DB), // Light Blue
    const Color(0xFFE74C3C), // Red
    const Color(0xFF2ECC71), // Emerald
    const Color(0xFFF1C40F), // Yellow
    const Color(0xFF8E44AD), // Wisteria
  ];

  @override
  void initState() {
    super.initState();
    _fetchExamTypes();
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
    debugPrint('🔄 Loading advertisements for exampage2...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=exampage2'),
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

  Future<void> _fetchExamTypes() async {
    debugPrint('🔄 Loading exam types...');

    // Get categoryId from examData if available
    final categoryId = widget.examData?['id'];
    final apiUrl = categoryId != null
        ? '${BaseUrl.baseUrl}/api/exam-types?categoryId=$categoryId'
        : '${BaseUrl.baseUrl}/api/exam-types';

    debugPrint('📡 Fetching exam types from: $apiUrl');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Exam Types API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} exam types');

        setState(() {
          examTypes = data.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;

            // Fix image URL if needed
            String? imageUrl = item['image'];
            if (imageUrl != null && imageUrl.isNotEmpty) {
              // Check if URL is valid
              if (!imageUrl.startsWith('http')) {
                imageUrl = '${BaseUrl.baseUrl}$imageUrl';
              }
            }

            // Get unique exam types for tabs
            String examName = item['name'] ?? 'Unknown';

            return {
              'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
              'title': examName,
              'description':
                  item['shortDescription'] ?? 'No description available',
              'image': imageUrl,
              'categoryId': item['categoryId'] ?? widget.examData?['id'],
              'color': cardColors[index % cardColors.length],
              'type': _getExamTypeFromName(examName),
            };
          }).toList();

          // Dynamically create tabs from unique exam types
          _createTabsFromData();

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load exam types. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading exam types: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getExamTypeFromName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mains')) return 'mains';
    if (lowerName.contains('advanced')) return 'advanced';
    if (lowerName.contains('prelims')) return 'prelims';
    if (lowerName.contains('supplementary')) return 'supplementary';
    if (lowerName.contains('annual')) return 'annual';
    if (lowerName.contains('model')) return 'model';
    if (lowerName.contains('practical')) return 'practical';
    return 'other';
  }

  void _createTabsFromData() {
    // Get unique types from examTypes
    final Set<String> uniqueTypes = {};
    for (var exam in examTypes) {
      uniqueTypes.add(exam['type']);
    }

    // Convert to list and create tabs
    final List<String> typeList = uniqueTypes.toList()..sort();

    // Clear existing tabs except 'All Exams'
    tabs.clear();
    tabs.add({'id': 'all', 'label': 'All Exams'});

    // Add type-specific tabs
    for (String type in typeList) {
      if (type != 'other') {
        // Skip 'other' or include it if you want
        String label = type.substring(0, 1).toUpperCase() + type.substring(1);
        tabs.add({'id': type, 'label': '$label Exams'});
      }
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _isAdsLoading = true;
      _errorMessage = null;
    });
    _fetchExamTypes();
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

  // Filter exams based on active tab
  List<Map<String, dynamic>> get _filteredExams {
    if (examTypes.isEmpty) return [];

    final activeTab = tabs[_activeTabIndex]['id'];
    if (activeTab == 'all') return examTypes;
    return examTypes.where((exam) => exam['type'] == activeTab).toList();
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
    final double adHeight = _responsiveValue(200, 300, 300);
    final int gridColumns = _getGridColumns();

    // Calculate card dimensions
    final double gap = _responsiveValue(8, 12, 16);
    final double availableWidth = screenWidth - (horizontalPadding * 2);
    final double totalGap = gap * (gridColumns - 1);
    final double cardWidth = (availableWidth - totalGap) / gridColumns;
    final double cardHeight = cardWidth * 0.9;

    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    final String examTitle = widget.examData?['title'] ?? 'Exam Types';

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
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                              'Exam Types',
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
                  child: _isLoading
                      ? const Center(
                          child: GlassLoader(
                            message: 'Loading exam types...',
                          ),
                        )
                      : _errorMessage != null && examTypes.isEmpty
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
                                    'Error loading exam types',
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
                                                      margin: EdgeInsets.only(
                                                          bottom:
                                                              _responsiveValue(
                                                                  16, 20, 24)),
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 6,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                      ),
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
                                                                    ? _scale(10)
                                                                    : _scale(6),
                                                            height: _scale(6),
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

                                                  // ===== EXAM CATEGORY HEADER =====
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      horizontalPadding,
                                                      _responsiveValue(
                                                          20, 24, 28),
                                                      horizontalPadding,
                                                      _responsiveValue(
                                                          16, 20, 24),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: const Color(
                                                              0xFFF0F0F0),
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          examTitle,
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
                                                        Text(
                                                          examTypes.isNotEmpty
                                                              ? '${examTypes.length} exam ${examTypes.length == 1 ? 'type' : 'types'} available'
                                                              : 'Select exam type to view detailed syllabus, patterns, and resources',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    13, 14, 15),
                                                            color: const Color(
                                                                0xFF666666),
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // ===== TAB NAVIGATION (only show if multiple tabs) =====
                                                  if (tabs.length > 1)
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical:
                                                            _responsiveValue(
                                                                10, 12, 14),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color: const Color(
                                                                0xFFE0E0E0),
                                                            width: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children:
                                                              List.generate(
                                                                  tabs.length,
                                                                  (index) {
                                                            final tab =
                                                                tabs[index];
                                                            return Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                left: index == 0
                                                                    ? horizontalPadding
                                                                    : 0,
                                                                right: index <
                                                                        tabs.length -
                                                                            1
                                                                    ? _responsiveValue(
                                                                        12,
                                                                        16,
                                                                        20)
                                                                    : horizontalPadding,
                                                              ),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _activeTabIndex =
                                                                        index;
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom:
                                                                          BorderSide(
                                                                        color: _activeTabIndex ==
                                                                                index
                                                                            ? const Color(0xFF0B5ED7)
                                                                            : Colors.transparent,
                                                                        width:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        _responsiveValue(
                                                                            12,
                                                                            16,
                                                                            20),
                                                                    vertical:
                                                                        _responsiveValue(
                                                                            8,
                                                                            10,
                                                                            12),
                                                                  ),
                                                                  child: Text(
                                                                    tab['label']
                                                                        as String,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          _responsiveValue(
                                                                              13,
                                                                              14,
                                                                              15),
                                                                      fontWeight: _activeTabIndex ==
                                                                              index
                                                                          ? FontWeight
                                                                              .w700
                                                                          : FontWeight
                                                                              .w500,
                                                                      color: _activeTabIndex ==
                                                                              index
                                                                          ? const Color(
                                                                              0xFF0B5ED7)
                                                                          : const Color(
                                                                              0xFF666666),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ),
                                                    ),

                                                  // ===== EXAM TYPES GRID =====
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      horizontalPadding,
                                                      _responsiveValue(
                                                          20, 24, 28),
                                                      horizontalPadding,
                                                      _responsiveValue(
                                                          10, 15, 20),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child: _filteredExams
                                                            .isEmpty
                                                        ? const Center(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(20),
                                                              child: Text(
                                                                  'No exam types available'),
                                                            ),
                                                          )
                                                        : Wrap(
                                                            spacing: gap,
                                                            runSpacing: gap,
                                                            children:
                                                                _filteredExams
                                                                    .map(
                                                                        (exam) {
                                                              return _buildExamCard(
                                                                exam: exam,
                                                                width:
                                                                    cardWidth,
                                                                height:
                                                                    cardHeight,
                                                              );
                                                            }).toList(),
                                                          ),
                                                  ),

                                                  // ===== AVAILABLE BANNER =====
                                                  Container(
                                                    width: screenWidth,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          horizontalPadding,
                                                      vertical:
                                                          _responsiveValue(
                                                              16, 20, 24),
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        _responsiveValue(
                                                            16, 20, 24)),
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
                                                          'Complete Exam Resources',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    16, 18, 20),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: _scale(8)),
                                                        Text(
                                                          'Access syllabus, model papers, answer keys, and preparation guides',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    13, 14, 15),
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
                                                Column(children: [
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
                                                            color: Colors.red),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          'Video tutorials',
                                                          style: TextStyle(
                                                            fontSize:
                                                                _responsiveValue(
                                                                    16, 18, 20),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: const Color(
                                                                0xFF003366),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  ...youtubeUrls
                                                      .map((url) => Container(
                                                            width: screenWidth,
                                                            margin: EdgeInsets
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
                                                ])
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

          // Full screen loader for initial loading
          if (_isLoading && examTypes.isEmpty)
            const GlassLoader(
              message: 'Loading exam types...',
            ),
        ],
      ),
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }

  Widget _buildExamCard({
    required Map<String, dynamic> exam,
    required double width,
    required double height,
  }) {
    // Check if we have an image from API and it's valid
    bool hasValidImage =
        exam['image'] != null && exam['image'].toString().isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Navigate to Exam3 screen when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Exam3Screen(
              examData: {
                'id': exam['id'],
                'title': exam['title'],
                'description': exam['description'],
                'type': exam['type'],
                'categoryId': exam['categoryId'],
              },
            ),
          ),
        );
      },
      child: Container(
        width: width * 0.9,
        margin: EdgeInsets.symmetric(
            horizontal: width * 0.05), // Center the smaller card
        padding: EdgeInsets.all(_responsiveValue(14, 18, 22)),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image/Icon Container - Centered
            Container(
              width: _responsiveValue(
                  70, 80, 90), // Increased from 40/50/60 to 80/100/120
              height: _responsiveValue(
                  70, 80, 90), // Increased from 40/50/60 to 80/100/120
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    _scale(16)), // Slightly larger border radius
                image: hasValidImage
                    ? DecorationImage(
                        image: NetworkImage(exam['image']),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Fallback to color on error
                        },
                      )
                    : null,
                color: hasValidImage ? null : const Color(0xFFE6F0FF),
              ),
              child: !hasValidImage
                  ? Center(
                      child: Icon(
                        Icons.image,
                        size: _responsiveValue(
                            25, 30, 35), // Increased from 22/26/30 to 40/50/60
                        color: const Color(0xFF0052A2).withOpacity(0.5),
                      ),
                    )
                  : null,
            ),
            SizedBox(height: _scale(14)), // Slightly increased spacing

            // Title - Centered
            Text(
              exam['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _responsiveValue(14, 16, 18),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: _scale(6)),

            // Description - Centered
            Text(
              exam['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _responsiveValue(11, 12, 13),
                color: const Color(0xFF666666),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: _scale(10)),

            // Footer - Centered
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Type Badge (if not 'other')
                if (exam['type'] != 'other')
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _scale(8),
                      vertical: _scale(4),
                    ),
                    decoration: BoxDecoration(
                      color: (exam['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(_scale(6)),
                    ),
                    child: Text(
                      (exam['type'] as String).toUpperCase(),
                      style: TextStyle(
                        fontSize: _responsiveValue(9, 10, 11),
                        fontWeight: FontWeight.w600,
                        color: exam['color'] as Color,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                if (exam['type'] != 'other') SizedBox(width: _scale(8)),

                // Arrow Icon
                Container(
                  width: _responsiveValue(20, 24, 28),
                  height: _responsiveValue(20, 24, 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(_scale(12)),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: _responsiveValue(14, 16, 18),
                    color: exam['color'] as Color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
