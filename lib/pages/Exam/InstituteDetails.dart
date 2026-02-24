// lib/pages/Institute/InstituteDetails.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';

class InstituteDetailsScreen extends StatefulWidget {
  final int? institutionId;
  final Map<String, dynamic>? institutionData;
  
  const InstituteDetailsScreen({
    super.key,
    this.institutionId,
    this.institutionData,
  });

  @override
  State<InstituteDetailsScreen> createState() => _InstituteDetailsScreenState();
}

class _InstituteDetailsScreenState extends State<InstituteDetailsScreen> {
  int _activeAdIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Loading states
  bool _isLoading = true;
  String? _errorMessage;

  // API Data
  Map<String, dynamic>? institution;

  // Advertisement banners data (static)
  final List<Map<String, dynamic>> ads = [
    {
      'id': '1',
      'title': 'Premium Education Facilities',
      'description': 'State-of-the-art infrastructure for better learning',
      'color': Color(0xFF4A90E2),
    },
    {
      'id': '2',
      'title': 'Expert Faculty Members',
      'description': 'Learn from industry professionals and experienced educators',
      'color': Color(0xFF50C878),
    },
    {
      'id': '3',
      'title': 'Modern Campus Facilities',
      'description': 'Advanced labs, libraries, and sports amenities',
      'color': Color(0xFFFF6B6B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchInstitutionDetails();
    
    // Auto scroll ads
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adController.hasClients && mounted) {
        int nextPage = _activeAdIndex + 1;
        if (nextPage >= ads.length) nextPage = 0;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _fetchInstitutionDetails() async {
    debugPrint('🔄 Loading institution details...');
    
    try {
      // If we already have full data from list page, use it
      if (widget.institutionData != null && widget.institutionData!.isNotEmpty) {
        setState(() {
          institution = _mapApiDataToModel(widget.institutionData!);
          _isLoading = false;
        });
        return;
      }
      
      // Otherwise fetch by ID
      if (widget.institutionId == null) {
        setState(() {
          _errorMessage = 'Institution ID not provided';
          _isLoading = false;
        });
        return;
      }
      
      String apiUrl = '${BaseUrl.baseUrl}/api/institutions/${widget.institutionId}';
      debugPrint('📡 Fetching institution from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Institution Details API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded institution details');

        setState(() {
          institution = _mapApiDataToModel(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load institution details. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading institution details: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _mapApiDataToModel(Map<String, dynamic> data) {
    // Parse category
    List<String> categories = [];
    if (data['category'] is List) {
      categories = List<String>.from(data['category']);
    } else if (data['category'] is String) {
      categories = [data['category']];
    }

    // Parse subjectsOffered
    List<String> subjects = [];
    if (data['subjectsOffered'] is List) {
      subjects = List<String>.from(data['subjectsOffered']);
    } else if (data['subjectsOffered'] is String) {
      subjects = [data['subjectsOffered']];
    }

    // Parse teachingMode
    List<String> teachingModes = [];
    if (data['teachingMode'] is List) {
      teachingModes = List<String>.from(data['teachingMode']);
    } else if (data['teachingMode'] is String) {
      teachingModes = [data['teachingMode']];
    }

    // Parse gallery
    List<String> gallery = [];
    if (data['gallery'] is List) {
      gallery = List<String>.from(data['gallery']);
    }

    // Parse location
    String location = data['location'] ?? 'Unknown';
    List<String> locationParts = location.split(',');
    String area = locationParts.isNotEmpty ? locationParts[0].trim() : location;
    String district = locationParts.length > 1 ? locationParts[1].trim() : location;

    // Parse rating
    double rating = 0.0;
    if (data['rating'] != null) {
      rating = double.tryParse(data['rating'].toString()) ?? 0.0;
    }

    // Create features list from various data
    List<String> features = [];
    features.addAll(categories);
    if (subjects.isNotEmpty) features.add('${subjects.length}+ Subjects');
    if (teachingModes.isNotEmpty) features.addAll(teachingModes);
    
    // Create facilities list
    List<String> facilities = [];
    if (teachingModes.contains('Online')) facilities.add('Online Classes');
    if (teachingModes.contains('Offline')) facilities.add('Offline Classes');
    facilities.add('Expert Faculty');
    if (data['result'] != null) facilities.add('Proven Results');

    return {
      'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': data['institutionName'] ?? 'Unknown Institution',
      'type': categories.isNotEmpty ? categories.join(', ') : 'Institute',
      'rating': rating,
      'area': area,
      'district': district,
      'established': _extractYear(data['createdAt']),
      'description': data['about'] ?? data['shortDescription'] ?? 'No description available',
      'students': 'N/A',
      'courses': '${subjects.length}+ Programs',
      'features': features,
      'facilities': facilities,
      'image': data['institutionImage'],
      'result': data['result'] ?? 'Results not available',
      'subjects': subjects,
      'teachingModes': teachingModes,
      'categories': categories,
      'gallery': gallery,
      'mapLink': data['mapLink'],
      'contact': {
        'phone': data['mobileNumber'] ?? 'Not available',
        'whatsapp': data['whatsappNumber'] ?? data['mobileNumber'] ?? 'Not available',
        'email': 'Not available', // Email not in API response
        'website': 'Not available', // Website not in API response
      }
    };
  }

  String _extractYear(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      return DateTime.parse(dateTime).year.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchInstitutionDetails();
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty || url == 'Not available') return;
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber == 'Not available') return;
    
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not call $phoneNumber'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber == 'Not available') return;
    
    final Uri uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  // Build star ratings
  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(
          Icons.star,
          size: _scale(16),
          color: const Color(0xFFFFD700),
        ));
      } else {
        stars.add(Icon(
          Icons.star_border,
          size: _scale(16),
          color: const Color(0xFFFFD700),
        ));
      }
    }
    
    return Row(
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double adHeight = _responsiveValue(200, 240, 260);
    final double videoHeight = _responsiveValue(220, 280, 320);
    final double logoSize = _responsiveValue(80, 100, 120);
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
                              'Institute Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(18, 20, 22),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Home Button
                        IconButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          icon: Icon(
                            Icons.home_outlined,
                            size: _scale(24),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== MAIN CONTENT =====
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: GlassLoader(
                            message: 'Loading institute details...',
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
                                    'Error loading institute details',
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
                                      SizedBox(
                                        width: screenWidth,
                                        height: adHeight,
                                        child: PageView.builder(
                                          controller: _adController,
                                          itemCount: ads.length,
                                          onPageChanged: (index) {
                                            setState(() {
                                              _activeAdIndex = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            final ad = ads[index];
                                            return GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text(ad['title'] as String),
                                                    content: Text('This ad would open: ${ad['description']}'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: ad['color'] as Color,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      (ad['color'] as Color).withOpacity(0.9),
                                                      (ad['color'] as Color).withOpacity(0.7),
                                                    ],
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // Content
                                                    Padding(
                                                      padding: EdgeInsets.all(horizontalPadding),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: _scale(8),
                                                              vertical: _scale(4),
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.3),
                                                              borderRadius: BorderRadius.circular(_scale(4)),
                                                            ),
                                                            child: Text(
                                                              'AD',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: _responsiveValue(10, 12, 12),
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: _scale(12)),
                                                          Text(
                                                            ad['title'] as String,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: _responsiveValue(18, 20, 22),
                                                              fontWeight: FontWeight.w700,
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                          SizedBox(height: _scale(8)),
                                                          Text(
                                                            ad['description'] as String,
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.9),
                                                              fontSize: _responsiveValue(14, 15, 16),
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // ===== PAGINATION DOTS =====
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF6F9FF),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: _scale(12)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(ads.length, (index) {
                                            return AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              width: _activeAdIndex == index ? _scale(10) : _scale(6),
                                              height: _scale(6),
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

                                      // ===== INSTITUTE HEADER =====
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                        padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(_scale(16)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: _scale(8),
                                              offset: Offset(0, _scale(4)),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Logo/Image Placeholder
                                            Container(
                                              width: logoSize,
                                              height: logoSize,
                                              decoration: BoxDecoration(
                                                color: institution!['image'] != null 
                                                    ? null 
                                                    : const Color(0xFF4A90E2).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(_scale(12)),
                                                border: Border.all(
                                                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                                                  width: 2,
                                                ),
                                                image: institution!['image'] != null
                                                    ? DecorationImage(
                                                        image: NetworkImage(institution!['image']),
                                                        fit: BoxFit.cover,
                                                        onError: (exception, stackTrace) {},
                                                      )
                                                    : null,
                                              ),
                                              child: institution!['image'] == null
                                                  ? Icon(
                                                      Icons.school,
                                                      size: _scale(40),
                                                      color: const Color(0xFF4A90E2),
                                                    )
                                                  : null,
                                            ),
                                            SizedBox(width: _scale(16)),
                                            
                                            // Title and Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Text(
                                                      institution!['name'],
                                                      style: TextStyle(
                                                        fontSize: _responsiveValue(20, 22, 24),
                                                        fontWeight: FontWeight.w700,
                                                        color: const Color(0xFF003366),
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(height: _scale(8)),
                                                  
                                                  if (isMobile) ...[
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: _scale(12),
                                                            vertical: _scale(6),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFE3F2FD),
                                                            borderRadius: BorderRadius.circular(_scale(6)),
                                                          ),
                                                          child: Text(
                                                            institution!['type'],
                                                            style: TextStyle(
                                                              fontSize: _responsiveValue(12, 13, 14),
                                                              fontWeight: FontWeight.w600,
                                                              color: const Color(0xFF1565C0),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: _scale(8)),
                                                        Row(
                                                          children: [
                                                            _buildStars(institution!['rating']),
                                                            SizedBox(width: _scale(8)),
                                                            Text(
                                                              '${institution!['rating']}/5',
                                                              style: TextStyle(
                                                                fontSize: _responsiveValue(14, 16, 18),
                                                                fontWeight: FontWeight.w600,
                                                                color: const Color(0xFF666666),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ] else ...[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        // Type Badge
                                                        Container(
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: _scale(12),
                                                            vertical: _scale(6),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFE3F2FD),
                                                            borderRadius: BorderRadius.circular(_scale(6)),
                                                          ),
                                                          child: Text(
                                                            institution!['type'],
                                                            style: TextStyle(
                                                              fontSize: _responsiveValue(12, 13, 14),
                                                              fontWeight: FontWeight.w600,
                                                              color: const Color(0xFF1565C0),
                                                            ),
                                                          ),
                                                        ),
                                                        // Rating
                                                        Row(
                                                          children: [
                                                            _buildStars(institution!['rating']),
                                                            SizedBox(width: _scale(8)),
                                                            Text(
                                                              '${institution!['rating']}/5',
                                                              style: TextStyle(
                                                                fontSize: _responsiveValue(14, 16, 18),
                                                                fontWeight: FontWeight.w600,
                                                                color: const Color(0xFF666666),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ===== LOCATION DETAILS =====
                                      _buildSectionCard(
                                        icon: Icons.location_pin,
                                        title: 'Location Details',
                                        child: Column(
                                          children: [
                                            _buildDetailRow(
                                              icon: Icons.location_city,
                                              label: 'Area',
                                              value: institution!['area'],
                                            ),
                                            SizedBox(height: _scale(12)),
                                            _buildDetailRow(
                                              icon: Icons.apartment,
                                              label: 'District',
                                              value: institution!['district'],
                                            ),
                                            SizedBox(height: _scale(12)),
                                            _buildDetailRow(
                                              icon: Icons.calendar_today,
                                              label: 'Established',
                                              value: institution!['established'],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ===== ABOUT INSTITUTE =====
                                      _buildSectionCard(
                                        icon: Icons.info,
                                        title: 'About Institute',
                                        child: Text(
                                          institution!['description'],
                                          style: TextStyle(
                                            fontSize: _responsiveValue(14, 15, 16),
                                            color: const Color(0xFF666666),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),

                                      // ===== RESULT HIGHLIGHT =====
                                      if (institution!['result'] != 'Results not available')
                                        _buildSectionCard(
                                          icon: Icons.emoji_events,
                                          title: 'Achievements',
                                          child: Container(
                                            padding: EdgeInsets.all(_scale(12)),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3E0),
                                              borderRadius: BorderRadius.circular(_scale(8)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.military_tech,
                                                  color: const Color(0xFFFFA500),
                                                  size: _scale(24),
                                                ),
                                                SizedBox(width: _scale(12)),
                                                Expanded(
                                                  child: Text(
                                                    institution!['result'],
                                                    style: TextStyle(
                                                      fontSize: _responsiveValue(14, 15, 16),
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFFB95F00),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      // ===== SUBJECTS OFFERED =====
                                      if (institution!['subjects'].isNotEmpty)
                                        _buildSectionCard(
                                          icon: Icons.subject,
                                          title: 'Subjects Offered',
                                          child: Wrap(
                                            spacing: _scale(8),
                                            runSpacing: _scale(8),
                                            children: (institution!['subjects'] as List).map<Widget>((subject) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: _scale(12),
                                                  vertical: _scale(6),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF0F7FF),
                                                  borderRadius: BorderRadius.circular(_scale(16)),
                                                ),
                                                child: Text(
                                                  subject,
                                                  style: TextStyle(
                                                    fontSize: _responsiveValue(12, 13, 14),
                                                    color: const Color(0xFF4A90E2),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),

                                      // ===== TEACHING MODES =====
                                      if (institution!['teachingModes'].isNotEmpty)
                                        _buildSectionCard(
                                          icon: Icons.school,
                                          title: 'Teaching Modes',
                                          child: Row(
                                            children: (institution!['teachingModes'] as List).map<Widget>((mode) {
                                              return Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(right: _scale(8)),
                                                  padding: EdgeInsets.all(_scale(12)),
                                                  decoration: BoxDecoration(
                                                    color: mode == 'Online' 
                                                        ? const Color(0xFFE3F2FD)
                                                        : const Color(0xFFE8F5E9),
                                                    borderRadius: BorderRadius.circular(_scale(8)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        mode == 'Online' 
                                                            ? Icons.computer
                                                            : Icons.people,
                                                        size: _scale(24),
                                                        color: mode == 'Online'
                                                            ? const Color(0xFF1976D2)
                                                            : const Color(0xFF388E3C),
                                                      ),
                                                      SizedBox(height: _scale(8)),
                                                      Text(
                                                        mode,
                                                        style: TextStyle(
                                                          fontSize: _responsiveValue(13, 14, 15),
                                                          fontWeight: FontWeight.w600,
                                                          color: mode == 'Online'
                                                              ? const Color(0xFF1976D2)
                                                              : const Color(0xFF388E3C),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),

                                      // ===== CONTACT INFORMATION =====
                                      _buildSectionCard(
                                        icon: Icons.contact_phone,
                                        title: 'Contact Information',
                                        child: Column(
                                          children: [
                                            if (institution!['contact']['phone'] != 'Not available')
                                              _buildContactItem(
                                                icon: Icons.call,
                                                title: 'Phone',
                                                value: institution!['contact']['phone'],
                                                onTap: () => _makePhoneCall(institution!['contact']['phone']),
                                              ),
                                            if (institution!['contact']['whatsapp'] != 'Not available')
                                              Padding(
                                                padding: EdgeInsets.only(top: _scale(16)),
                                                child: _buildContactItem(
                                                  icon: Icons.message,
                                                  title: 'WhatsApp',
                                                  value: institution!['contact']['whatsapp'],
                                                  onTap: () => _openWhatsApp(institution!['contact']['whatsapp']),
                                                ),
                                              ),
                                            if (institution!['mapLink'] != null && institution!['mapLink'].isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: _scale(16)),
                                                child: _buildContactItem(
                                                  icon: Icons.map,
                                                  title: 'Location',
                                                  value: 'View on Map',
                                                  onTap: () => _launchURL(institution!['mapLink']),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // ===== YOUTUBE VIDEO SECTION =====
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                        margin: EdgeInsets.only(top: _responsiveValue(20, 24, 28),
                                        bottom:0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Video Header
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.play_circle_filled,
                                                  color: const Color(0xFFFF0000),
                                                  size: _scale(24),
                                                ),
                                                SizedBox(width: _scale(8)),
                                                Text(
                                                  'Campus Tour',
                                                  style: TextStyle(
                                                    fontSize: _responsiveValue(16, 18, 20),
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF333333),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: _responsiveValue(12, 16, 20)),

                                            // Video Container
                                            Container(
                                              height: videoHeight,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(_scale(12)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.15),
                                                    blurRadius: _scale(10),
                                                    offset: Offset(0, _scale(4)),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(_scale(12)),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: Text('Campus Tour Video'),
                                                        content: Text('This would play a video tour of ${institution!['name']}'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context),
                                                            child: const Text('OK'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                    ),
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.play_circle_filled,
                                                            size: _scale(60),
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(height: _scale(12)),
                                                          Text(
                                                            'Take a virtual tour of',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: _responsiveValue(16, 18, 20),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: _scale(8)),
                                                          Text(
                                                            institution!['name'],
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: _responsiveValue(16, 18, 20),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ===== ACTION BUTTONS =====
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                        margin: EdgeInsets.only(
                                          top: _responsiveValue(24, 28, 32),
                                          bottom: _responsiveValue(16, 20, 24),
                                        ),
                                        child: Row(
                                          children: [
                                            // Visit Website Button (if available)
                                            if (institution!['contact']['website'] != 'Not available')
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(right: _scale(8)),
                                                  child: ElevatedButton(
                                                    onPressed: () => _launchURL(institution!['contact']['website']),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF4A90E2),
                                                      padding: EdgeInsets.symmetric(
                                                        vertical: _scale(14),
                                                        horizontal: _scale(12),
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(_scale(10)),
                                                      ),
                                                    ),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.language,
                                                            size: _scale(18),
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: _scale(6)),
                                                          Text(
                                                            'Visit Website',
                                                            style: TextStyle(
                                                              fontSize: _responsiveValue(13, 15, 16),
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            
                                            // Call Now Button (if available)
                                            if (institution!['contact']['phone'] != 'Not available')
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    left: institution!['contact']['website'] != 'Not available' 
                                                        ? _scale(8) 
                                                        : 0,
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () => _makePhoneCall(institution!['contact']['phone']),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF50C878),
                                                      padding: EdgeInsets.symmetric(
                                                        vertical: _scale(14),
                                                        horizontal: _scale(12),
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(_scale(10)),
                                                      ),
                                                    ),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.call,
                                                            size: _scale(18),
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: _scale(6)),
                                                          Text(
                                                            'Call Now',
                                                            style: TextStyle(
                                                              fontSize: _responsiveValue(13, 15, 16),
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.white,
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

                                      // ===== BOTTOM SPACER =====
                                      SizedBox(height: _responsiveValue(80, 100, 120)),
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
          if (_isLoading && institution == null)
            const GlassLoader(
              message: 'Loading institute details...',
            ),
        ],
      ),
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }

  // Helper function to get facility icon
  Widget _getFacilityIcon(String facility) {
    final lowerFacility = facility.toLowerCase();
    if (lowerFacility.contains('online')) {
      return Icon(Icons.computer, size: _scale(20), color: const Color(0xFF4A90E2));
    } else if (lowerFacility.contains('offline')) {
      return Icon(Icons.people, size: _scale(20), color: const Color(0xFF50C878));
    } else if (lowerFacility.contains('faculty')) {
      return Icon(Icons.school, size: _scale(20), color: const Color(0xFFFF6B6B));
    } else if (lowerFacility.contains('result')) {
      return Icon(Icons.emoji_events, size: _scale(20), color: const Color(0xFFFFA500));
    } else {
      return Icon(Icons.check_circle, size: _scale(20), color: const Color(0xFF4A90E2));
    }
  }

  // Helper Widget: Section Card
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _responsiveValue(16, 24, 32),
        vertical: _responsiveValue(8, 12, 16),
      ),
      padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_scale(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: _scale(8),
            offset: Offset(0, _scale(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                icon,
                size: _scale(24),
                color: const Color(0xFF4A90E2),
              ),
              SizedBox(width: _scale(12)),
              Text(
                title,
                style: TextStyle(
                  fontSize: _responsiveValue(16, 18, 20),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF003366),
                ),
              ),
            ],
          ),
          SizedBox(height: _scale(20)),
          // Section Content
          child,
        ],
      ),
    );
  }

  // Helper Widget: Detail Row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: _scale(40),
          height: _scale(40),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(_scale(20)),
          ),
          child: Icon(
            icon,
            size: _scale(20),
            color: const Color(0xFF666666),
          ),
        ),
        SizedBox(width: _scale(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: _responsiveValue(12, 13, 14),
                  color: const Color(0xFF666666),
                ),
              ),
              SizedBox(height: _scale(4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: _responsiveValue(14, 16, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget: Contact Item with onTap
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _scale(40),
            height: _scale(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(_scale(20)),
            ),
            child: Icon(
              icon,
              size: _scale(20),
              color: const Color(0xFF4A90E2),
            ),
          ),
          SizedBox(width: _scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _responsiveValue(12, 13, 14),
                    color: const Color(0xFF666666),
                  ),
                ),
                SizedBox(height: _scale(4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: _responsiveValue(13, 15, 16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF003366),
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              size: _scale(20),
              color: const Color(0xFF999999),
            ),
        ],
      ),
    );
  }
}