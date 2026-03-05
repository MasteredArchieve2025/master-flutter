import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../Widgets/Footer.dart';
import 'Jobs3.dart'; // for JobDetail model
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';
import '../../Widgets/CommonYoutubePlayer.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobDetail job;

  const JobDetailsScreen({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late bool isTablet;
  late bool isWeb;

  // ── Ad Banner ──
  int currentAdIndex = 0;
  late PageController _pageController;
  Timer? _adTimer;
  bool _isAutoScrollStarted = false;

  // Advertisement API Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  String? _pageName;
  bool _isLoadingAds = true;

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

  bool get isIOS {
    if (kIsWeb) return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  String _getFontFamily() {
    if (kIsWeb) return 'Roboto';
    return isIOS ? '.SF Pro Text' : 'Roboto';
  }

  // ── Fetch advertisements ─────────────────────────────────────────────────

  Future<void> _fetchAdvertisements() async {
    setState(() {
      _isLoadingAds = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=jobpage4'),
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
            if (apiData['youtube_urls'] != null &&
                apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }

            _isLoadingAds = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingAds = false;
      });
      debugPrint('Failed to fetch advertisements: $e');
    }
  }

  // ── Ad auto-scroll ────────────────────────────────────────────────────────

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
        int itemCount =
            _adImages.isNotEmpty ? _adImages.length : fallbackAds.length;
        if (nextPage >= itemCount) nextPage = 0;

        _pageController
            .animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        )
            .then((_) {
          if (mounted) _autoScrollNext();
        }).catchError((e) {
          _isAutoScrollStarted = false;
        });
      } else {
        _isAutoScrollStarted = false;
      }
    });
  }

  // ── Deadline formatting ───────────────────────────────────────────────────

  String _formatDeadline(String raw) {
    if (raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  bool _isDeadlinePassed(String raw) {
    if (raw.isEmpty) return false;
    try {
      return DateTime.parse(raw).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // ── URL launcher ──────────────────────────────────────────────────────────

  Future<void> _launch(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    isTablet = screenSize.width >= 768;
    isWeb = screenSize.width >= 1024;
    final adHeight = isWeb ? 300.0 : (isTablet ? 300.0 : 200.0);

    final job = widget.job;
    final deadlinePassed = _isDeadlinePassed(job.applicationDeadline);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // ── Fixed Header ──
              SafeArea(
                bottom: false,
                child: _buildHeader(context),
              ),

              // ── Scrollable Content ──
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Ad Banner ──
                    SliverToBoxAdapter(
                      child: _buildAdBanner(context, adHeight),
                    ),

                    // ── Job Details Content ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Company & Job Title ──
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Company logo placeholder
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFF0052A2)
                                            .withOpacity(0.15)),
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: Color(0xFF0052A2),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job.companyName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E293B)
                                              .withOpacity(0.7),
                                          fontFamily: _getFontFamily(),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        job.jobName,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Location ──
                            if (job.location.isNotEmpty) ...[
                              _infoRow(Icons.location_on_outlined, job.location,
                                  Colors.grey.shade600),
                              const SizedBox(height: 10),
                            ],

                            // ── Tags ──
                            if (job.tags.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  ...job.tags.map((tag) => _tagChip(tag,
                                      bg: const Color(0xFFEFF6FF),
                                      color: const Color(0xFF0052A2))),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // ── Posted time ──
                            if (job.postedTimeLabel.isNotEmpty)
                              _infoRow(Icons.access_time, job.postedTimeLabel,
                                  Colors.grey.shade500),

                            const SizedBox(height: 24),
                            _divider(),
                            const SizedBox(height: 24),

                            // ── Salary & Deadline row ──
                            Row(
                              children: [
                                Expanded(
                                  child: _infoBox(
                                    label: 'SALARY',
                                    value: job.salaryRange.isNotEmpty
                                        ? job.salaryRange
                                        : '—',
                                    sub: 'Per annum',
                                    bgColor: const Color(0xFFEFF6FF),
                                    borderColor: const Color(0xFF0052A2)
                                        .withOpacity(0.12),
                                    labelColor: const Color(0xFF0052A2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoBox(
                                    label: 'DEADLINE',
                                    value: _formatDeadline(
                                        job.applicationDeadline),
                                    sub: deadlinePassed
                                        ? 'Applications closed'
                                        : 'Applications close',
                                    bgColor: deadlinePassed
                                        ? const Color(0xFFFEF3F2)
                                        : const Color(0xFFF0FFF4),
                                    borderColor: deadlinePassed
                                        ? Colors.red.withOpacity(0.12)
                                        : Colors.green.withOpacity(0.12),
                                    labelColor: deadlinePassed
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ── Job Description ──
                            _sectionTitle('Job Description'),
                            const SizedBox(height: 12),
                            _contentCard(
                              child: Text(
                                job.jobDescription.isNotEmpty
                                    ? job.jobDescription
                                    : '—',
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.65,
                                  color: Colors.grey.shade700,
                                  fontFamily: _getFontFamily(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Requirements ──
                            _sectionTitle('Requirements'),
                            const SizedBox(height: 12),
                            _labeledCard(
                              label: 'SKILLS & TOOLS',
                              labelColor: const Color(0xFF0052A2),
                              body: job.requirements.isNotEmpty
                                  ? job.requirements
                                  : '—',
                            ),
                            const SizedBox(height: 12),

                            // ── Experience ──
                            _labeledCard(
                              label: 'EXPERIENCE',
                              labelColor: const Color(0xFF0052A2),
                              body: job.experience.isNotEmpty
                                  ? job.experience
                                  : '—',
                            ),
                            const SizedBox(height: 24),

                            // ── Map Section ──
                            _sectionTitle('Location'),
                            const SizedBox(height: 12),
                            _contentCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Map placeholder
                                  Container(
                                    height: 140,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            size: 40,
                                            color: const Color(0xFF0052A2)
                                                .withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            job.location.isNotEmpty
                                                ? job.location
                                                : 'Location not specified',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (job.mapLink.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () => _launch(job.mapLink),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.open_in_new,
                                              size: 16,
                                              color: Color(0xFF0052A2)),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'View on Map',
                                            style: TextStyle(
                                              color: Color(0xFF0052A2),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ── Apply Now Button ──
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: deadlinePassed
                                    ? null
                                    : () => _launch(job.applyLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0052A2),
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      deadlinePassed
                                          ? 'Applications Closed'
                                          : 'Apply Now',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (!deadlinePassed) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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

              // ── Footer ──
              const Footer(),
            ],
          ),

          // Glass Loader for ads
          if (_isLoadingAds)
            const GlassLoader(
              message: 'Loading content...',
            ),
        ],
      ),
    );
  }

  // ── Ad Banner (with API images) ──────────────────────────────────────────

  Widget _buildAdBanner(BuildContext context, double adHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool useApiImages = _adImages.isNotEmpty;
    int itemCount = useApiImages ? _adImages.length : fallbackAds.length;

    if (itemCount == 0) return const SizedBox.shrink();

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
                        SnackBar(
                            content:
                                Text('Opening advertisement ${index + 1}')),
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
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
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

  // ── Video player (with API YouTube URL) ─────────────────────────

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

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    double headerHeight = isWeb ? 64 : (isTablet ? 58 : 52);
    double fontSize = isWeb ? 19 : (isTablet ? 18 : 17);
    double hPad = isWeb ? 40 : (isTablet ? 24 : 16);

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
        constraints: BoxConstraints(maxWidth: isWeb ? 1200 : double.infinity),
        padding: EdgeInsets.symmetric(horizontal: hPad),
        height: headerHeight,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon:
                    const Icon(Icons.arrow_back, size: 24, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Job Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 17, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontFamily: _getFontFamily(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tagChip(String label, {required Color bg, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(thickness: 1, height: 1, color: Colors.grey.shade200);
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _contentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _labeledCard({
    required String label,
    required Color labelColor,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 0.5,
              fontFamily: _getFontFamily(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.5,
              fontFamily: _getFontFamily(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required String label,
    required String value,
    required String sub,
    required Color bgColor,
    required Color borderColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
