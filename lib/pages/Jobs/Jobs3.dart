import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/Footer.dart';
import '../../Api/baseurl.dart';
import 'Jobs4.dart';
import '../../components/glass_loader.dart';
import '../../Widgets/CommonYoutubePlayer.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class JobDetail {
  final int id;
  final int jobCategoryId;
  final String companyName;
  final String jobName;
  final String area;
  final String district;
  final String state;
  final List<String> tags;
  final String salaryRange;
  final String jobDescription;
  final String requirements;
  final String experience;
  final String applicationDeadline;
  final String mapLink;
  final String applyLink;
  final String createdAt;

  JobDetail({
    required this.id,
    required this.jobCategoryId,
    required this.companyName,
    required this.jobName,
    required this.area,
    required this.district,
    required this.state,
    required this.tags,
    required this.salaryRange,
    required this.jobDescription,
    required this.requirements,
    required this.experience,
    required this.applicationDeadline,
    required this.mapLink,
    required this.applyLink,
    required this.createdAt,
  });

  factory JobDetail.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        parsedTags = List<String>.from(json['tags']);
      } else if (json['tags'] is String) {
        // Split by comma if it's a comma-separated string
        parsedTags = (json['tags'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return JobDetail(
      id: json['id'] ?? 0,
      jobCategoryId: json['jobCategoryId'] ?? 0,
      companyName: json['companyName'] ?? '',
      jobName: json['jobName'] ?? '',
      area: json['area'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      tags: parsedTags,
      salaryRange: json['salaryRange'] ?? '',
      jobDescription: json['jobDescription'] ?? '',
      requirements: json['requirements'] ?? '',
      experience: json['experience'] ?? '',
      applicationDeadline: json['applicationDeadline'] ?? '',
      mapLink: json['mapLink'] ?? '',
      applyLink: json['applyLink'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get location =>
      [area, district, state].where((s) => s.isNotEmpty).join(', ');

  String get postedTimeLabel {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return 'Posted ${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      if (diff.inHours > 0) return 'Posted ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      return 'Posted just now';
    } catch (_) {
      return '';
    }
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ITSoftwareJobsScreen extends StatefulWidget {
  final String categoryName;
  const ITSoftwareJobsScreen({
    Key? key,
    this.categoryName = 'IT & Software',
  }) : super(key: key);

  @override
  State<ITSoftwareJobsScreen> createState() => _ITSoftwareJobsScreenState();
}

class _ITSoftwareJobsScreenState extends State<ITSoftwareJobsScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "Full Time", "Internship", "Remote"];

  // ── Ad Banner ──
  int currentAdIndex = 0;
  late PageController _pageController;
  Timer? _adTimer;
  late bool isTablet;
  late bool isWeb;
  bool _isAutoScrollStarted = false;

  // Advertisement API Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  String? _pageName;

  // Fallback ads
  final List<Map<String, String>> fallbackAds = [
    {
      "id": "1",
      "title": "Study Abroad Scholarships",
      "description": "Get up to 50% scholarship on international programs",
      "image":
          "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&h=300&fit=crop",
    },
    {
      "id": "2",
      "title": "Online Learning Platform",
      "description": "Access 1000+ courses for free this month",
      "image":
          "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=300&fit=crop",
    },
    {
      "id": "3",
      "title": "Career Development Program",
      "description": "Boost your career with our certified programs",
      "image":
          "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=300&fit=crop",
    },
  ];

  // ── API state ──
  List<JobDetail> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool get isIOS {
    if (kIsWeb) return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  String _getFontFamily() {
    if (kIsWeb) return 'Roboto';
    return isIOS ? '.SF Pro Text' : 'Roboto';
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchJobs();
    _fetchAdvertisements();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ── Fetch jobs ────────────────────────────────────────────────────────────

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/job-details'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          List<JobDetail> loaded = [];

          if (data is List) {
            loaded = data
                .map((item) => JobDetail.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (data is Map<String, dynamic>) {
            loaded = [JobDetail.fromJson(data)];
          }

          setState(() {
            _jobs = loaded;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No jobs found.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load jobs.\n$e';
        _isLoading = false;
      });
    }
  }

  // ── Fetch advertisements ─────────────────────────────────────────────────

  Future<void> _fetchAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=jobpage3'),
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
      // Silently fail - will use fallback ads
      debugPrint('Failed to fetch advertisements: $e');
    }
  }

  // ── Filter jobs (FIXED) ───────────────────────────────────────────────────

  List<JobDetail> get _filteredJobs {
    if (selectedFilter == 'All') return _jobs;
    
    return _jobs.where((job) {
      // Check each tag for a match
      for (String tag in job.tags) {
        if (tag.toLowerCase().contains(selectedFilter.toLowerCase())) {
          return true;
        }
        // Also check if the tag contains variations like "fulltime" without space
        if (selectedFilter.toLowerCase() == "full time" && 
            tag.toLowerCase().contains("full")) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  // ── Ad auto-scroll (FIXED) ────────────────────────────────────────────────

  void _startAutoScroll() {
    if (_isAutoScrollStarted) return;
    _isAutoScrollStarted = true;
    _autoScrollNext();
  }

  void _autoScrollNext() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_pageController.hasClients) {
        int nextPage = currentAdIndex + 1;
        int itemCount = _adImages.isNotEmpty ? _adImages.length : fallbackAds.length;
        if (nextPage >= itemCount) nextPage = 0;
        
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ).then((_) {
          if (mounted) _autoScrollNext();
        }).catchError((e) {
          _isAutoScrollStarted = false;
        });
      } else {
        _isAutoScrollStarted = false;
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    isTablet = screenSize.width >= 768;
    isWeb = screenSize.width >= 1024;
    final adHeight =
        screenSize.height * 0.25 > 200 ? 200.0 : screenSize.height * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Ad Banner ──
                    SliverToBoxAdapter(
                      child: _buildAdBanner(context, adHeight),
                    ),

                    // ── Main Content ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              "${widget.categoryName} Job List",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Title
                            Text(
                              "${widget.categoryName} Jobs",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Filter Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: filters.map((filter) {
                                  final isSelected = selectedFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: FilterChip(
                                      label: Text(
                                        filter,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          selectedFilter = filter;
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      selectedColor: const Color(0xFF0052A2),
                                      checkmarkColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Job Cards / States ──
                            _buildJobList(),
                          ],
                        ),
                      ),
                    ),

                    // ── Video player ──
                    SliverToBoxAdapter(
                      child: _buildVideoPlayer(),
                    ),
                  ],
                ),
              ),

              // Footer
              Footer(
                currentIndex: 0,
                onItemTapped: (index) {},
              ),
            ],
          ),
          
          // Glass Loader
          if (_isLoading)
            const GlassLoader(
              message: 'Loading jobs...',
            ),
        ],
      ),
    );
  }

  // ── Job list: loading / error / data ─────────────────────────────────────

  Widget _buildJobList() {
    // Hide inline loading indicator when GlassLoader is showing
    if (_isLoading) {
      return Container();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontFamily: _getFontFamily(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchJobs,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052A2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final jobs = _filteredJobs;

    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_off_outlined,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No jobs found for this filter.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  fontFamily: _getFontFamily(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: jobs.map((job) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildJobCard(job),
        );
      }).toList(),
    );
  }

  // ── Job Card ──────────────────────────────────────────────────────────────

  Widget _buildJobCard(JobDetail job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.jobName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                // Show "NEW" if posted within last 3 days
                if (_isNew(job.createdAt))
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Company
            Text(
              job.companyName,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            // Location
            if (job.location.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Tags + salary
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...job.tags.map((tag) => _chip(tag)),
                if (job.salaryRange.isNotEmpty) _chip(job.salaryRange),
                if (job.experience.isNotEmpty) _chip(job.experience),
              ],
            ),
            const SizedBox(height: 12),

            // Posted time + View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job.postedTimeLabel,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500),
                ),
                const Text(
                  "View Details",
                  style: TextStyle(
                    color: Color(0xFF0052A2),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _isNew(String createdAt) {
    if (createdAt.isEmpty) return false;
    try {
      final dt = DateTime.parse(createdAt);
      return DateTime.now().difference(dt).inDays <= 3;
    } catch (_) {
      return false;
    }
  }

  // ── Header ────────────────────────────────────────────────────────────────

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
        padding: EdgeInsets.symmetric(horizontal: getHorizontalPadding()),
        height: getHeaderHeight(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back,
                    size: 24, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.categoryName,
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

  // ── Ad Banner (UPDATED with API images) ──────────────────────────────────

  Widget _buildAdBanner(BuildContext context, double adHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool useApiImages = _adImages.isNotEmpty;
    int itemCount = useApiImages ? _adImages.length : fallbackAds.length;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: adHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: itemCount,
              onPageChanged: (index) {
                setState(() => currentAdIndex = index);
              },
              itemBuilder: (context, index) {
                if (useApiImages) {
                  // Show API image
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening advertisement ${index + 1}')),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _adImages[index],
                          width: screenWidth,
                          height: adHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
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
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Ad",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show fallback ad with text overlay
                  final ad = fallbackAds[index];
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening: ${ad['title']}')),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          ad['image']!,
                          width: screenWidth,
                          height: adHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ad['title']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isIOS ? 18 : 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ad['description']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isIOS ? 14 : 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Ad",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // Dots
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(itemCount, (index) {
                return Container(
                  width: currentAdIndex == index ? 20.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: currentAdIndex == index
                        ? const Color(0xFF0B5ED7)
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Video player (UPDATED with API YouTube URL) ─────────────────────────

  Widget _buildVideoPlayer() {
    // Use first YouTube URL from API if available, otherwise use default
    String videoUrl = _youtubeUrls.isNotEmpty 
        ? _youtubeUrls.first 
        : 'https://www.youtube.com/embed/qYapc_bkfxw';
    
    // Extract video ID for thumbnail
    String thumbnailUrl = '';
    if (videoUrl.contains('youtube.com/embed/')) {
      final videoId = videoUrl.split('/').last;
      thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    } else {
      thumbnailUrl = 'https://img.youtube.com/vi/qYapc_bkfxw/maxresdefault.jpg';
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: CommonYoutubePlayer(
        youtubeUrl: videoUrl,
        height: isWeb ? 400 : (isTablet ? 320 : 250),
        placeholderThumbnail: thumbnailUrl,
        borderRadius: 0,
      ),
    );
  }
}