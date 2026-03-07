import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../Widgets/Footer.dart';
import '../../Api/baseurl.dart';
import '../../services/auth_token_manager.dart';
import '../../components/glass_loader.dart';
import '../../Widgets/CommonYoutubePlayer.dart';
import 'Jobs2.dart';

// ==================== JOB SCREEN ====================
class Job1Screen extends StatefulWidget {
  const Job1Screen({super.key});

  @override
  State<Job1Screen> createState() => _Job1ScreenState();
}

class _Job1ScreenState extends State<Job1Screen> with WidgetsBindingObserver {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  int _footerIndex = 0;
  bool _isAutoScrollStarted = false;
  late bool isTablet;
  late bool isWeb;

  // API Data
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  String? _pageName;

  // Resume Upload Variables (Web Compatible)
  final AuthTokenManager _authManager = AuthTokenManager.instance;
  PlatformFile? _selectedFile;
  String? _fileName;
  String? _fileSize;
  bool _isUploading = false;
  String? _uploadErrorMessage;
  String? _uploadSuccessMessage;

  // Check if user already has a resume
  bool _hasExistingResume = false;
  String? _existingResumeName;
  String? _existingResumeUrl;
  bool _isCheckingResume = false;
  bool _resumeCheckedOnce = false; // prevents double-fire on first build

  // Banner Data (fallback if API fails)
  final List<Map<String, String>> bannerData = [
    {
      "title": "Find Your Dream Job at",
      "line1": "TOP COMPANIES",
      "line2": "HIRING NOW",
      "info": "1000+ Jobs Available",
    },
    {
      "title": "Build Your Career With",
      "line1": "BEST JOB",
      "line2": "OPPORTUNITIES",
      "info": "Apply Today",
    },
    {
      "title": "Connect. Apply. Succeed.",
      "line1": "YOUR NEXT",
      "line2": "CAREER AWAITS",
      "info": "Start Your Journey",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // re-check on app resume
    _fetchAdvertisements();
    _checkExistingResume();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check resume when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _checkExistingResume();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Skip first call — initState already triggered the check.
    // Subsequent calls mean we returned from a child route.
    if (_resumeCheckedOnce) {
      _checkExistingResume();
    } else {
      _resumeCheckedOnce = true;
    }
  }

  // ─── Check if user already has a resume ───────────────────────────────────
  Future<void> _checkExistingResume() async {
    // Skip if already checking to avoid duplicate requests
    if (_isCheckingResume) return;

    if (!mounted) return;
    setState(() => _isCheckingResume = true);

    try {
      final token = await _authManager.getToken();
      if (token == null) {
        if (mounted) setState(() => _isCheckingResume = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/resumes/my-resume'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('[Resume Check] status: ${response.statusCode}');
      print('[Resume Check] body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle both { success, data: {...} } and { data: {...} } formats
        final resumeData = data['data'];

        if (resumeData != null) {
          // Support multiple possible field names from different backends
          final fileName = resumeData['file_name'] ??
              resumeData['filename'] ??
              resumeData['original_name'] ??
              resumeData['name'] ??
              'Resume uploaded';

          final fileUrl = resumeData['file_url'] ??
              resumeData['url'] ??
              resumeData['path'] ??
              resumeData['resume_url'];

          setState(() {
            _hasExistingResume = true;
            _existingResumeName = fileName;
            _existingResumeUrl = fileUrl;
          });
        } else if (data['success'] == false || data['resume'] == null) {
          // Explicitly no resume
          setState(() {
            _hasExistingResume = false;
            _existingResumeName = null;
            _existingResumeUrl = null;
          });
        }
      } else if (response.statusCode == 404) {
        // 404 = no resume exists yet for this user
        setState(() {
          _hasExistingResume = false;
          _existingResumeName = null;
          _existingResumeUrl = null;
        });
      } else if (response.statusCode == 401) {
        // Token expired
        await _authManager.clearAll();
      }
    } on Exception catch (e) {
      print('[Resume Check] Error: $e');
      // Don't reset _hasExistingResume on network error —
      // keep whatever state we had before
    } finally {
      if (mounted) setState(() => _isCheckingResume = false);
    }
  }

  Future<void> _fetchAdvertisements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=jobs1page'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          setState(() {
            _pageName = apiData['page_name'];
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
            }
            if (apiData['youtube_urls'] != null &&
                apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load advertisements';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAutoScroll() {
    if (_isAutoScrollStarted) return;
    _isAutoScrollStarted = true;
    _autoScrollNext();
  }

  void _autoScrollNext() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        int itemCount =
            _adImages.isNotEmpty ? _adImages.length : bannerData.length;
        if (nextPage >= itemCount) nextPage = 0;

        _bannerController
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    isTablet = size.width >= 768;
    isWeb = size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: _buildHeader(context),
              ),
              Expanded(child: _buildContent(context, size)),
              Footer(
                currentIndex: _footerIndex,
                onItemTapped: (index) {
                  if (mounted) {
                    setState(() => _footerIndex = index);
                    _handleFooterNavigation(index, context);
                  }
                },
              ),
            ],
          ),

          if (_isLoading || _isUploading || _isCheckingResume)
            GlassLoader(
              message: _isUploading
                  ? (_hasExistingResume
                      ? 'Updating resume...'
                      : 'Uploading resume...')
                  : (_isCheckingResume
                      ? 'Checking resume...'
                      : 'Loading content...'),
            ),
        ],
      ),
    );
  }

  void _handleFooterNavigation(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
    }
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
                  "Jobs & Careers",
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
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load content',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAdvertisements,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5ED7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBannerSlider(size.width),
          _buildJobGridSection(),

          // Show resume section when: file selected, has existing resume, or has messages
          if (_selectedFile != null ||
              _uploadErrorMessage != null ||
              _uploadSuccessMessage != null ||
              _hasExistingResume)
            _buildResumeUploadSection(),

          _buildBrowseByCategorySection(),
          _buildVideoPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildBannerSlider(double bannerWidth) {
    bool useApiImages = _adImages.isNotEmpty;
    int itemCount = useApiImages ? _adImages.length : bannerData.length;

    return Column(
      children: [
        SizedBox(
          height: isTablet ? 300 : 200,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: itemCount,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentBannerIndex = index);
            },
            itemBuilder: (context, index) {
              if (useApiImages) {
                return SizedBox(
                  width: bannerWidth,
                  height: isTablet ? 300 : 200,
                  child: Image.network(
                    _adImages[index],
                    width: bannerWidth,
                    height: isTablet ? 300 : 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: bannerWidth,
                      height: isTablet ? 300 : 200,
                      color: const Color(0xFF0052A2),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 50,
                                color: Colors.white.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            Text('Image ${index + 1}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: bannerWidth,
                        height: isTablet ? 300 : 200,
                        color: const Color(0xFF0052A2),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
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
              } else {
                final item = bannerData[index];
                return SizedBox(
                  width: bannerWidth,
                  height: isTablet ? 300 : 200,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/Global.png',
                        width: bannerWidth,
                        height: isTablet ? 300 : 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: bannerWidth,
                          height: isTablet ? 300 : 200,
                          color: const Color(0xFF0052A2),
                        ),
                      ),
                      Container(
                        width: bannerWidth,
                        height: isTablet ? 300 : 200,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45)),
                        padding: EdgeInsets.all(isTablet ? 32 : 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["title"]!,
                                style: TextStyle(
                                    color: const Color(0xFFE8F0FF),
                                    fontSize: isTablet ? 16 : 14)),
                            const SizedBox(height: 6),
                            Text(item["line1"]!,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 28 : 22,
                                    fontWeight: FontWeight.w800)),
                            Text(item["line2"]!,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 28 : 22,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            Text(item["info"]!,
                                style: TextStyle(
                                    color: const Color(0xFFFFD966),
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemCount, (index) {
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
      ],
    );
  }

  Widget _buildJobGridSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
      ),
      margin: EdgeInsets.only(top: isTablet ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Upload / Update Resume Card
          Expanded(
            child: GestureDetector(
              onTap: _handleUploadResumeTap,
              child: Container(
                margin: EdgeInsets.only(right: 8, top: isTablet ? 20 : 15),
                child: _buildJobGridCard(
                  icon: Icons.upload_file,
                  title: _hasExistingResume ? "Update Resume" : "Upload Resume",
                  subtitle: _hasExistingResume
                      ? "Replace existing resume"
                      : "Get Noticed",
                  isSelected: _selectedFile != null || _hasExistingResume,
                ),
              ),
            ),
          ),

          // Search Jobs Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const JobCategoriesScreen()),
                );
              },
              child: Container(
                margin: EdgeInsets.only(left: 8, top: isTablet ? 20 : 15),
                child: _buildJobGridCard(
                  icon: Icons.search,
                  title: "Search Jobs",
                  subtitle: "Find Your Perfect Job",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobGridCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSelected = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F0FE) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isSelected
            ? Border.all(color: const Color(0xFF0B5ED7), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isWeb ? 40 : (isTablet ? 32 : 27)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: isTablet ? 48 : 40, color: const Color(0xFF0B5ED7)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: const Color(0xFF666666),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0B5ED7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _hasExistingResume ? 'Resume Uploaded' : 'File Selected',
                style: TextStyle(
                  fontSize: isTablet ? 10 : 8,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Main tap handler — decides upload vs update ──────────────────────────
  // If user has resume, the Replace button in the card handles it.
  // This tap handler is only used when NO resume exists yet.
  Future<void> _handleUploadResumeTap() async {
    final hasToken = await _authManager.hasToken();
    if (!hasToken) {
      _showLoginRequiredDialog();
      return;
    }
    if (!_hasExistingResume) {
      await _pickFile();
    }
    // When _hasExistingResume == true, user taps the Replace button in the card below.
  }


  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to upload your resume.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5ED7)),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        final file = result.files.first;

        // Validate size (max 5 MB)
        if (file.size > 5 * 1024 * 1024) {
          setState(() {
            _uploadErrorMessage = 'File size must be less than 5MB';
            _uploadSuccessMessage = null;
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileName = file.name;
          _fileSize = _formatFileSize(file.size);
          _uploadErrorMessage = null;
          _uploadSuccessMessage = null;
        });

        // Auto upload or update after picking
        _uploadOrUpdateResume();
      }
    } catch (e) {
      setState(() {
        _uploadErrorMessage = 'Error picking file: $e';
        _uploadSuccessMessage = null;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024)
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ─── Upload (new) OR Update (existing) ────────────────────────────────────
  // • No existing resume  → POST /api/resumes/upload-resume
  // • Has existing resume → POST /api/resumes/update-resume
  Future<void> _uploadOrUpdateResume() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadErrorMessage = null;
      _uploadSuccessMessage = null;
    });

    try {
      final token = await _authManager.getToken();

      if (token == null) {
        setState(() {
          _isUploading = false;
          _uploadErrorMessage =
              'Authentication required. Please login again.';
        });
        _showLoginRequiredDialog();
        return;
      }

      // ── Choose endpoint based on whether a resume already exists ──────────
      final String endpoint = _hasExistingResume
          ? '${BaseUrl.baseUrl}/api/resumes/update-resume'
          : '${BaseUrl.baseUrl}/api/resumes/upload-resume';

      var request = http.MultipartRequest('POST', Uri.parse(endpoint));

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Attach file — web uses bytes, mobile uses path
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'resume',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'resume',
            _selectedFile!.path!,
            filename: _selectedFile!.name,
          ),
        );
      }

      print('Sending to endpoint: $endpoint');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Capture the new file name before clearing _selectedFile
        final String newFileName = _selectedFile!.name;

        setState(() {
          _isUploading = false;
          _uploadSuccessMessage = responseData['message'] ??
              (_hasExistingResume
                  ? 'Resume updated successfully!'
                  : 'Resume uploaded successfully!');
          _hasExistingResume = true;
          _existingResumeName = newFileName; // show updated name in the card
          _selectedFile = null;             // clear file picker state
          _fileName = null;
          _fileSize = null;
        });

        // Auto-clear success banner after 3 s so the card stays clean
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _uploadSuccessMessage = null);
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _isUploading = false;
          _uploadErrorMessage = 'Session expired. Please login again.';
        });
        await _authManager.clearAll();
        _showLoginRequiredDialog();
      } else {
        setState(() {
          _isUploading = false;
          _uploadErrorMessage = _parseErrorMessage(response.body);
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadErrorMessage = 'Network error: $e';
      });
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final data = json.decode(responseBody);
      return data['message'] ??
          data['error'] ??
          'Operation failed. Please try again.';
    } catch (e) {
      return 'Operation failed. Please try again.';
    }
  }

  Widget _buildResumeUploadSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
        vertical: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B5ED7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.upload_file,
                    color: Color(0xFF0B5ED7), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _hasExistingResume ? 'Resume Management' : 'Resume Upload',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (_selectedFile != null)
                IconButton(
                  onPressed: _clearSelectedFile,
                  icon: const Icon(Icons.close,
                      size: 20, color: Color(0xFFEF4444)),
                ),
            ],
          ),

          // Current resume info + Replace button (shown when no new file picked)
          if (_hasExistingResume && _selectedFile == null) ...[
            const SizedBox(height: 16),
            // Current resume file row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBDEFB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF22C55E), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Resume',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _existingResumeName ?? 'Resume uploaded',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_existingResumeUrl != null)
                    IconButton(
                      onPressed: () {
                        // Use url_launcher to open _existingResumeUrl
                      },
                      icon: const Icon(Icons.visibility,
                          size: 20, color: Color(0xFF0B5ED7)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Replace / Update Resume button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text(
                  'Replace Resume',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B5ED7),
                  side: const BorderSide(
                      color: Color(0xFF0B5ED7), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Accepted: PDF, DOC, DOCX (max 5MB)',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ),
          ],

          // Newly selected file info
          if (_selectedFile != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_getFileIcon(),
                      color: const Color(0xFF0B5ED7), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileName ?? 'Selected file',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fileSize ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Error message
          if (_uploadErrorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _uploadErrorMessage!,
                      style: const TextStyle(
                          color: Color(0xFF991B1B), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success message
          if (_uploadSuccessMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Color(0xFF22C55E), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _uploadSuccessMessage!,
                      style: const TextStyle(
                          color: Color(0xFF166534), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    if (_fileName == null) return Icons.insert_drive_file;
    final extension = _fileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _fileSize = null;
      _uploadErrorMessage = null;
      _uploadSuccessMessage = null;
    });
  }

  Widget _buildBrowseByCategorySection() {
    final List<Map<String, dynamic>> jobCategories = [
      {
        "title": "IT & Software",
        "icon": Icons.computer,
        "color": const Color(0xFF4F46E5)
      },
      {
        "title": "Healthcare",
        "icon": Icons.local_hospital,
        "color": const Color(0xFF059669)
      },
      {
        "title": "Finance",
        "icon": Icons.account_balance,
        "color": const Color(0xFFDC2626)
      },
      {
        "title": "Education",
        "icon": Icons.school,
        "color": const Color(0xFFEA580C)
      },
      {
        "title": "Marketing",
        "icon": Icons.trending_up,
        "color": const Color(0xFF2563EB)
      },
      {
        "title": "Engineering",
        "icon": Icons.engineering,
        "color": const Color(0xFF7C3AED)
      },
      {
        "title": "Sales",
        "icon": Icons.attach_money,
        "color": const Color(0xFFB45309)
      },
      {"title": "HR", "icon": Icons.people, "color": const Color(0xFF0F766E)},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
      ),
      margin: EdgeInsets.only(top: isTablet ? 40 : 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Browse Jobs by Category",
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isTablet ? 140 : 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: jobCategories.length,
              itemBuilder: (context, index) {
                final cat = jobCategories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/job_listings',
                      arguments: cat["title"],
                    );
                  },
                  child: Container(
                    width: isTablet ? 140 : 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cat["color"].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat["icon"],
                            color: cat["color"],
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            cat["title"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    String videoUrl = _youtubeUrls.isNotEmpty
        ? _youtubeUrls.first
        : 'https://img.youtube.com/vi/qYapc_bkfxw/maxresdefault.jpg';

    String thumbnailUrl = videoUrl;
    if (videoUrl.contains('youtube.com/embed/')) {
      final videoId = videoUrl.split('/').last;
      thumbnailUrl =
          'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }

    final String currentVideoUrl = _youtubeUrls.isNotEmpty
        ? _youtubeUrls.first
        : 'https://www.youtube.com/embed/qYapc_bkfxw';

    return Container(
      margin: EdgeInsets.only(top: isTablet ? 70 : 55),
      width: double.infinity,
      child: CommonYoutubePlayer(
        youtubeUrl: currentVideoUrl,
        height: isWeb ? 400 : (isTablet ? 320 : 250),
        placeholderThumbnail: thumbnailUrl,
        borderRadius: 0,
      ),
    );
  }
}