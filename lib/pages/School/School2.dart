import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master/components/glass_loader.dart';
import '../../Widgets/Footer.dart';
import '../../Api/School/school_service.dart';
import '../../Api/baseurl.dart';

// ==================== SCHOOL LIST SCREEN ====================
class School2Screen extends StatefulWidget {
  final String? initialCategory;
  const School2Screen({super.key, this.initialCategory});

  @override
  State<School2Screen> createState() => _School2ScreenState();
}

class _School2ScreenState extends State<School2Screen> {
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentBannerIndex = 0;
  int _currentVideoIndex = 0;
  int _footerIndex = 0;
  late String _selectedCategory;
  String _searchQuery = "";
  bool _showFilters = false;
  bool _isLoading = true;
  String? _errorMessage;
  late bool isTablet;
  late bool isWeb;

  // API Data
  List<School> _schools = [];
  List<School> _filteredSchools = [];
  
  // Advertisement Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  String? _pageName;

  // Default banner images (fallback if API fails)
  final List<String> defaultBannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop",
  ];

  // Get all categories from schools
  List<String> get categories {
    Set<String> categorySet = {'All'};
    for (var school in _schools) {
      categorySet.addAll(school.category);
    }
    return categorySet.toList();
  }

  List<String> get bannerAds => _adImages.isNotEmpty ? _adImages : defaultBannerAds;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? "All";
    _loadAdvertisements();
    _loadSchools();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  Future<void> _loadAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=schoolpage2'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          
          setState(() {
            _pageName = apiData['page_name'];
            
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
      // Continue with default banners
    }
  }

  Future<void> _loadSchools() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schoolsData = await SchoolService().fetchSchools();
      final schools = schoolsData.map((json) => School.fromJson(json)).toList();
      
      // Small delay to ensure loader is visible
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _schools = schools;
          _filterSchools();
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

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= bannerAds.length) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  void _filterSchools() {
    setState(() {
      _filteredSchools = _schools.where((school) {
        final matchesCategory = _selectedCategory == "All" || 
            school.category.contains(_selectedCategory);
        
        final schoolName = school.schoolName.toLowerCase();
        final location = school.location.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        final matchesSearch = _searchQuery.isEmpty || 
            schoolName.contains(query) ||
            location.contains(query);
        
        return matchesCategory && matchesSearch;
      }).toList();
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

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    isTablet = size.width >= 768;
    isWeb = size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: _buildHeader(context),
              ),
              Expanded(
                child: _buildContent(context, size),
              ),
              Footer(
                currentIndex: _footerIndex,
                onItemTapped: (index) {
                  if (mounted) {
                    setState(() {
                      _footerIndex = index;
                    });
                  }
                },
              ),
            ],
          ),
          
          // Glass Loader - covers entire screen when loading
          if (_isLoading)
            const GlassLoader(
              message: 'Loading schools...',
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    double getHeaderHeight() {
      if (isWeb) return 64;
      if (isTablet) return 58;
      return 52;
    }

    double getTitleFontSize() {
      if (isWeb) return 19;
      if (isTablet) return 18;
      return 17;
    }

    double getHorizontalPadding() {
      if (isWeb) return 40;
      if (isTablet) return 24;
      return 16;
    }

    double maxContentWidth = isWeb ? 1200 : double.infinity;

    return Container(
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
          horizontal: getHorizontalPadding(),
        ),
        height: getHeaderHeight(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
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
                child: Text(
                  "Schools",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getTitleFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Size size) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 64 : 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              "Error loading schools",
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSchools,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5ED7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAdBanner(size.width),
          _buildPaginationDots(),
          _buildSearchFilterRow(),
          if (_showFilters) _buildFilterOptions(),
          _buildCategories(),
          _buildSchoolsHeader(),
          _buildSchoolsList(),
          _buildVideoHeader(),
          _buildVideoSection(),
        ],
      ),
    );
  }

  Widget _buildAdBanner(double screenWidth) {
    return SizedBox(
      height: isTablet ? 200 : 180,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: bannerAds.length,
        onPageChanged: (index) {
          if (mounted) {
            setState(() {
              _currentBannerIndex = index;
            });
          }
        },
        itemBuilder: (context, index) {
          return SizedBox(
            width: screenWidth,
            height: isTablet ? 200 : 180,
            child: Image.network(
              bannerAds[index],
              width: screenWidth,
              height: isTablet ? 200 : 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: screenWidth,
                height: isTablet ? 200 : 180,
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
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: screenWidth,
                  height: isTablet ? 200 : 180,
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
    );
  }

  Widget _buildPaginationDots() {
    return Container(
      height: 20,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(bannerAds.length, (index) {
          return Container(
            width: _currentBannerIndex == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _currentBannerIndex == index 
                ? const Color(0xFF0B5ED7) 
                : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchFilterRow() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
        vertical: isTablet ? 20 : 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: EdgeInsets.all(isTablet ? 14 : 10),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: isTablet ? 20 : 16,
                    color: const Color(0xFF666666),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterSchools();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search by name, location...",
                        hintStyle: TextStyle(
                          color: const Color(0xFF666666),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchQuery = "";
                          _searchController.clear();
                          _filterSchools();
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: isTablet ? 20 : 16,
                        color: const Color(0xFF999999),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: _showFilters 
                  ? const Color(0xFF0B5ED7) 
                  : Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: EdgeInsets.all(isTablet ? 14 : 10),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: isTablet ? 22 : 18,
                    color: _showFilters 
                      ? Colors.white 
                      : const Color(0xFF0B5ED7),
                  ),
                  if (_showFilters) ...[
                    const SizedBox(width: 8),
                    Text(
                      "Filters",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
        vertical: isTablet ? 20 : 16,
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter Options",
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((category) {
              return _buildFilterOption(category, category);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
          _filterSchools();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF0B5ED7) 
            : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF666666),
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final cats = categories;
    
    if (cats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
        vertical: isTablet ? 20 : 16,
      ),
      height: isTablet ? 50 : 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final category = cats[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: EdgeInsets.only(right: isTablet ? 12 : 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _filterSchools();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(0xFF0B5ED7) 
                    : const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : const Color(0xFF5F6F81),
                    fontSize: isTablet ? 16 : 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchoolsHeader() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
        vertical: isTablet ? 16 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Available Schools",
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Text(
            "${_filteredSchools.length} schools found",
            style: TextStyle(
              fontSize: isTablet ? 16 : 13,
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsList() {
    if (_filteredSchools.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
        ),
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: isTablet ? 60 : 48,
              color: const Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 16),
            Text(
              "No schools found",
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try changing your search or filter criteria",
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSchools.length,
      itemBuilder: (context, index) {
        final school = _filteredSchools[index];
        return _buildSchoolCard(school);
      },
    );
  }

  Widget _buildSchoolCard(School school) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/school3',
          arguments: school.toJson(),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
          vertical: isTablet ? 9 : 7,
        ),
        padding: EdgeInsets.all(isTablet ? 18 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // School Logo
            Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                color: const Color(0xFFF0F4F8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                child: school.schoolLogo != null && school.schoolLogo!.isNotEmpty
                    ? Image.network(
                        school.schoolLogo!,
                        width: isTablet ? 100 : 80,
                        height: isTablet ? 100 : 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B5ED7)),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF0F4F8),
                            child: Icon(
                              Icons.school_outlined,
                              size: isTablet ? 40 : 32,
                              color: const Color(0xFF0052A2).withOpacity(0.5),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFFF0F4F8),
                        child: Icon(
                          Icons.school_outlined,
                          size: isTablet ? 40 : 32,
                          color: const Color(0xFF0052A2).withOpacity(0.5),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 14),
            
            // School Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          school.schoolName,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 6,
                          vertical: isTablet ? 4 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: isTablet ? 16 : 14,
                              color: const Color(0xFFFFB703),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              school.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
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
                  
                  // Location
                  Text(
                    "📍 ${school.location}",
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: const Color(0xFF5F6F81),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Result info
                  Text(
                    "📊 ${school.result}",
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      color: const Color(0xFF4B5563),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category Tags
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: school.category.map((cat) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: isTablet ? 5 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0B5ED7),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Chevron Icon
            Icon(
              Icons.chevron_right,
              size: isTablet ? 24 : 20,
              color: const Color(0xFF0B5ED7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoHeader() {
    if (_youtubeUrls.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.only(
        top: isTablet ? 24 : 20,
        bottom: isTablet ? 16 : 12,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _youtubeUrls.length > 1 ? "School Tours" : "School Tour",
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
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    if (_youtubeUrls.isEmpty) {
      return Container(
        margin: EdgeInsets.only(
          top: isTablet ? 32 : 24,
          bottom: 0,
        ),
        width: double.infinity,
        height: isTablet ? 320 : 220,
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: NetworkImage(
              'https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
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
      );
    }

    final currentVideoUrl = _youtubeUrls[_currentVideoIndex];
    final thumbnailUrl = _getVideoThumbnail(currentVideoUrl);

    return GestureDetector(
      onTap: () {
        // Open YouTube video in browser
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening video: $_youtubeUrls'),
            duration: const Duration(seconds: 2),
          ),
        );
        // In a real app: launchUrl(Uri.parse(currentVideoUrl));
      },
      child: Container(
        margin: EdgeInsets.only(
          top: isTablet ? 32 : 24,
          bottom: 0,
        ),
        width: double.infinity,
        height: isTablet ? 320 : 220,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: NetworkImage(thumbnailUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Fallback handled by Container color
            },
          ),
        ),
        child: Center(
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
    );
  }
}