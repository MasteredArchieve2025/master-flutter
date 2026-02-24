// lib/pages/Institute/InstitutionsList.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';
import 'InstituteDetails.dart';
import '../../Widgets/CommonYoutubePlayer.dart';

class InstitutionsListScreen extends StatefulWidget {
  final int? typeId; // TypeId passed from Exam3
  
  const InstitutionsListScreen({
    super.key,
    this.typeId,
  });

  @override
  State<InstitutionsListScreen> createState() => _InstitutionsListScreenState();
}

class _InstitutionsListScreenState extends State<InstitutionsListScreen> {
  int _activeAdIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;
  String _searchQuery = '';
  String _selectedArea = 'all';
  final TextEditingController _searchController = TextEditingController();

  // Loading states
  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;
  String? _adErrorMessage;

  // API Data
  List<Map<String, dynamic>> institutionsData = [];
  List<String> adImages = [];
  List<String> youtubeUrls = [];

  // Available areas (will be populated from API data)
  final List<String> areas = ['all'];

  @override
  void initState() {
    super.initState();
    _fetchInstitutions();
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

    // Listen to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _fetchInstitutions() async {
    debugPrint('🔄 Loading institutions...');
    
    try {
      String apiUrl;
      if (widget.typeId != null) {
        // Fetch institutions filtered by typeId
        apiUrl = '${BaseUrl.baseUrl}/api/institutions?typeId=${widget.typeId}';
      } else {
        // Fetch all institutions
        apiUrl = '${BaseUrl.baseUrl}/api/institutions';
      }
      
      debugPrint('📡 Fetching institutions from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Institutions API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} institutions');

        setState(() {
          institutionsData = data.map((item) {
            // Fix image URL if needed
            String? imageUrl = item['institutionImage'];
            if (imageUrl != null && imageUrl.isNotEmpty) {
              if (!imageUrl.startsWith('http')) {
                imageUrl = '${BaseUrl.baseUrl}$imageUrl';
              }
            }

            // Extract location string and determine area/district
            String location = item['location'] ?? 'Unknown';
            List<String> locationParts = location.split(',');
            String area = locationParts.isNotEmpty ? locationParts[0].trim() : location;
            String district = locationParts.length > 1 ? locationParts[1].trim() : location;

            // Add unique areas to filter list
            if (!areas.contains(area) && area != 'Unknown') {
              areas.add(area);
            }

            return {
              'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
              'name': item['institutionName'] ?? 'Unknown Institution',
              'area': area,
              'district': district,
              'type': _getInstitutionType(item['category']),
              'image': imageUrl,
              'rating': item['rating'] != null ? double.tryParse(item['rating'].toString()) ?? 0.0 : 0.0,
              'result': item['result'] ?? '',
              'shortDescription': item['shortDescription'] ?? '',
              'originalData': item, // Keep full data for details page
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

  Future<void> _fetchAdvertisements() async {
    debugPrint('🔄 Loading advertisements for examinstitutions...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=examinstitutions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (mounted) {
            setState(() {
              adImages = List<String>.from(data['data']['images'] ?? []);
              youtubeUrls = List<String>.from(data['data']['youtube_urls'] ?? []);
              _isLoadingAds = false;
            });
            debugPrint('✅ Loaded ${adImages.length} ad images for examinstitutions');
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

  String _getInstitutionType(dynamic category) {
    if (category == null) return 'Institute';
    if (category is List) {
      if (category.isNotEmpty) {
        return category.join(', ');
      }
    } else if (category is String) {
      return category;
    }
    return 'Institute';
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _isLoadingAds = true;
      _errorMessage = null;
      _adErrorMessage = null;
    });
    _fetchInstitutions();
    _fetchAdvertisements();
  }

  // Filter institutions
  List<Map<String, dynamic>> get _filteredInstitutions {
    return institutionsData.where((institute) {
      final matchesSearch = _searchQuery.isEmpty ||
          institute['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          institute['area'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          institute['district'].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesArea = _selectedArea == 'all' || institute['area'] == _selectedArea;

      return matchesSearch && matchesArea;
    }).toList();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    _searchController.dispose();
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
    final double adHeight = _responsiveValue(180, 300, 240);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

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
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    height: _responsiveValue(52, 72, 80),
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
                              'Institutions',
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
                            message: 'Loading institutions...',
                          ),
                        )
                      : _errorMessage != null
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
                          : SingleChildScrollView(
                              child: Center(
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ===== ADVERTISEMENT BANNER =====
                                      if (adImages.isNotEmpty)
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                          padding: EdgeInsets.only(top: _responsiveValue(16, 20, 24)),
                                          child: SizedBox(
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
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: screenWidth,
                                                      height: adHeight,
                                                      color: Colors.black12,
                                                      child: const Center(
                                                        child: Icon(Icons.broken_image, color: Colors.grey),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      else if (_isLoadingAds)
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                          padding: EdgeInsets.only(top: _responsiveValue(16, 20, 24)),
                                          child: Container(
                                            height: adHeight,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(_scale(12)),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),

                                      // ===== PAGINATION DOTS =====
                                      if (adImages.length > 1)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF6F9FF),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: _scale(12)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: List.generate(adImages.length, (index) {
                                              return AnimatedContainer(
                                                duration: const Duration(milliseconds: 300),
                                                width: _activeAdIndex == index ? _scale(16) : _scale(8),
                                                height: _scale(8),
                                                margin: EdgeInsets.symmetric(horizontal: _scale(4)),
                                                decoration: BoxDecoration(
                                                  color: _activeAdIndex == index 
                                                    ? const Color(0xFF0B5ED7) 
                                                    : const Color(0xFFCCCCCC),
                                                  borderRadius: BorderRadius.circular(_scale(4)),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),

                                      // ===== SEARCH BAR =====
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: horizontalPadding,
                                          vertical: _responsiveValue(16, 20, 24),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: _responsiveValue(14, 16, 18),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(_scale(10)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: _scale(6),
                                                offset: Offset(0, _scale(2)),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.search,
                                                size: _scale(20),
                                                color: const Color(0xFF666666),
                                              ),
                                              SizedBox(width: _scale(10)),
                                              Expanded(
                                                child: TextField(
                                                  controller: _searchController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Search institutions...',
                                                    hintStyle: TextStyle(
                                                      color: const Color(0xFF999999),
                                                      fontSize: _responsiveValue(14, 15, 16),
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.zero,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: _responsiveValue(14, 15, 16),
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
                                                    size: _scale(20),
                                                    color: const Color(0xFF999999),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(
                                                    minWidth: _scale(36),
                                                    minHeight: _scale(36),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // ===== FILTER CHIPS =====
                                      if (areas.length > 1)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.only(
                                            left: horizontalPadding,
                                            right: horizontalPadding,
                                            bottom: _responsiveValue(16, 20, 24),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Filter by Area:',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(14, 15, 16),
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF003366),
                                                ),
                                              ),
                                              SizedBox(height: _scale(8)),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: areas.map((area) {
                                                    bool isActive = _selectedArea == area;
                                                    return Container(
                                                      margin: EdgeInsets.only(right: _scale(8)),
                                                      child: ChoiceChip(
                                                        label: Text(
                                                          area == 'all' ? 'All Areas' : area,
                                                          style: TextStyle(
                                                            fontSize: _responsiveValue(13, 14, 15),
                                                            fontWeight: FontWeight.w600,
                                                            color: isActive ? Colors.white : const Color(0xFF666666),
                                                          ),
                                                        ),
                                                        selected: isActive,
                                                        onSelected: (selected) {
                                                          setState(() {
                                                            _selectedArea = area;
                                                          });
                                                        },
                                                        backgroundColor: const Color(0xFFF0F0F0),
                                                        selectedColor: const Color(0xFF4A90E2),
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: _scale(14),
                                                          vertical: _scale(8),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(_scale(16)),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // ===== RESULTS COUNT =====
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                        margin: EdgeInsets.only(bottom: _responsiveValue(12, 16, 20)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_filteredInstitutions.length} Institutions Found',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(16, 18, 20),
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF003366),
                                              ),
                                            ),
                                            SizedBox(height: _scale(4)),
                                            Text(
                                              'Showing ${_selectedArea == 'all' ? 'all areas' : _selectedArea}',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(13, 14, 15),
                                                color: const Color(0xFF666666),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ===== INSTITUTIONS GRID =====
                                      if (_filteredInstitutions.isNotEmpty) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              // Calculate responsive card width
                                              double cardWidth;
                                              int crossAxisCount;
                                              
                                              if (isDesktop) {
                                                crossAxisCount = 3;
                                                cardWidth = (constraints.maxWidth - _scale(16) * (crossAxisCount - 1)) / crossAxisCount;
                                              } else if (isTablet) {
                                                crossAxisCount = 2;
                                                cardWidth = (constraints.maxWidth - _scale(12) * (crossAxisCount - 1)) / crossAxisCount;
                                              } else {
                                                // Mobile - full width with horizontal padding
                                                cardWidth = constraints.maxWidth;
                                              }
                                              
                                              return Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: _responsiveValue(8, 12, 16),
                                                runSpacing: _responsiveValue(12, 16, 20),
                                                children: _filteredInstitutions.map((institution) {
                                                  return Container(
                                                    width: isMobile ? constraints.maxWidth : cardWidth,
                                                    margin: isMobile 
                                                      ? EdgeInsets.only(bottom: _scale(12))
                                                      : EdgeInsets.zero,
                                                    child: _buildInstitutionCard(institution, isMobile: isMobile, isTablet: isTablet, isDesktop: isDesktop),
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                        ),
                                      ] else ...[
                                        // ===== NO RESULTS =====
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            vertical: _responsiveValue(40, 50, 60),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.search_outlined,
                                                size: _scale(50),
                                                color: const Color(0xFFCCCCCC),
                                              ),
                                              SizedBox(height: _scale(16)),
                                              Text(
                                                'No institutions found',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(16, 18, 20),
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF666666),
                                                ),
                                              ),
                                              SizedBox(height: _scale(8)),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                                child: Text(
                                                  'Try changing your search or filters',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: _responsiveValue(13, 14, 15),
                                                    color: const Color(0xFF999999),
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      // ===== YOUTUBE VIDEO SECTION =====
                                      if (youtubeUrls.isNotEmpty) ...[
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: horizontalPadding,
                                            vertical: _responsiveValue(16, 20, 24),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.play_circle_fill, color: Colors.red),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Institution Tutorials',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(18, 20, 22),
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF003366),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...youtubeUrls.map((url) => Container(
                                          width: screenWidth,
                                          margin: EdgeInsets.only(
                                            bottom: _responsiveValue(16, 20, 24),
                                          ),
                                          child: CommonYoutubePlayer(
                                            youtubeUrl: url,
                                            height: isDesktop ? 360 : (isTablet ? 280 : 220),
                                            placeholderThumbnail: _getYoutubeThumbnail(url),
                                            borderRadius: 0,
                                          ),
                                        )).toList(),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
          
          // Full screen loader for initial loading
          if (_isLoading && institutionsData.isEmpty)
            const GlassLoader(
              message: 'Loading institutions...',
            ),
        ],
      ),
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }

  // Build Institution Card Widget
  Widget _buildInstitutionCard(Map<String, dynamic> institution, {
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    bool hasImage = institution['image'] != null && 
                    institution['image'].toString().isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : _scale(2),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstituteDetailsScreen(
                institutionId: institution['id'],
                institutionData: institution['originalData'],
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_scale(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: _scale(8),
                offset: Offset(0, _scale(2)),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo/Image Placeholder
                Container(
                  width: _scale(45),
                  height: _scale(45),
                  decoration: BoxDecoration(
                    color: hasImage ? null : const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_scale(8)),
                    border: Border.all(
                      color: const Color(0xFF4A90E2).withOpacity(0.2),
                      width: 1,
                    ),
                    image: hasImage
                        ? DecorationImage(
                            image: NetworkImage(institution['image']),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                  child: !hasImage
                      ? Icon(
                          Icons.school,
                          size: _scale(22),
                          color: const Color(0xFF4A90E2),
                        )
                      : null,
                ),
                SizedBox(width: _scale(10)),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Institution Name
                      Text(
                        institution['name'],
                        style: TextStyle(
                          fontSize: _responsiveValue(14, 15, 16),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF003366),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _scale(6)),

                      // Location Container
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Area
                          Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                size: _scale(11),
                                color: const Color(0xFF4A90E2),
                              ),
                              SizedBox(width: _scale(4)),
                              Expanded(
                                child: Text(
                                  institution['area'],
                                  style: TextStyle(
                                    fontSize: _responsiveValue(11, 12, 13),
                                    color: const Color(0xFF666666),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _scale(3)),
                          
                          // Rating if available
                          if (institution['rating'] > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: _scale(11),
                                  color: const Color(0xFFFFD700),
                                ),
                                SizedBox(width: _scale(4)),
                                Text(
                                  '${institution['rating']}',
                                  style: TextStyle(
                                    fontSize: _responsiveValue(11, 12, 13),
                                    color: const Color(0xFF666666),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: _scale(6)),

                      // Type Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _scale(8),
                          vertical: _scale(3),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(_scale(6)),
                        ),
                        child: Text(
                          institution['type'].length > 20 
                              ? '${institution['type'].substring(0, 20)}...'
                              : institution['type'],
                          style: TextStyle(
                            fontSize: _responsiveValue(10, 11, 12),
                            color: const Color(0xFF4A90E2),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron Icon
                Icon(
                  Icons.chevron_right,
                  size: _scale(18),
                  color: const Color(0xFF999999),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}