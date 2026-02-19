// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import '../../widgets/footer.dart';

// class JobDetailsScreen extends StatefulWidget {
//   const JobDetailsScreen({Key? key}) : super(key: key);

//   @override
//   State<JobDetailsScreen> createState() => _JobDetailsScreenState();
// }

// class _JobDetailsScreenState extends State<JobDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               height: 60,
//               color: const Color(0xFF0052A2),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const Text(
//                     "Job Details",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Company and Title
//                     const Text(
//                       "TechCorp Solutions",
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const Text(
//                       "Senior Product Designer",
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Job Details Icons
//                     _buildInfoRow(Icons.location_on, "San Francisco, CA"),
//                     _buildInfoRow(Icons.calendar_today, "Full-time"),
//                     _buildInfoRow(Icons.link, "Remote"),
//                     const SizedBox(height: 24),

//                     // Divider
//                     const Divider(),
//                     const SizedBox(height: 16),

//                     // Description
//                     const Text(
//                       "Job Description",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "We are looking for a passionate designer to join our education-focused team. You will be responsible for creating intuitive user experiences for students and freshers entering the workforce.",
//                       style: TextStyle(fontSize: 15, height: 1.5),
//                     ),
//                     const SizedBox(height: 24),

//                     // Requirements
//                     const Text(
//                       "Requirements",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildRequirementBox(
//                       "ELIGIBILITY",
//                       "Bachelor's in Design, CS or related field",
//                     ),
//                     const SizedBox(height: 12),
                    
//                     _buildRequirementBox(
//                       "EXPERIENCE",
//                       "3–5 Years (Freshers with strong portfolio welcome)",
//                     ),
//                     const SizedBox(height: 24),

//                     // Salary and Deadline
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildInfoBox(
//                             "SALARY",
//                             "\$80k – \$120k",
//                             "Per annum",
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _buildInfoBox(
//                             "DEADLINE",
//                             "Oct 24, 2023",
//                             "Applications close",
//                             isDeadline: true,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),

//                     // Map
//                     const Text(
//                       "Map",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       height: 150,
//                       color: Colors.grey[200],
//                       child: const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.map, size: 40, color: Colors.grey),
//                             SizedBox(height: 8),
//                             Text("Main Headquarters"),
//                             SizedBox(height: 4),
//                             Text(
//                               "View on Map",
//                               style: TextStyle(color: Colors.blue),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Apply Button
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: () {},
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0052A2),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 40,
//                             vertical: 14,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text("Apply Now", style: TextStyle(fontSize: 16)),
//                             SizedBox(width: 8),
//                             Icon(Icons.arrow_forward, size: 18),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer
//             const AppFooter(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Text(text, style: const TextStyle(fontSize: 15)),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequirementBox(String title, String description) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[800],
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(description, style: const TextStyle(fontSize: 15)),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoBox(String title, String value, String subtitle, {bool isDeadline = false}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDeadline ? Colors.red[50] : Colors.blue[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isDeadline ? Colors.red[100]! : Colors.blue[100]!,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: isDeadline ? Colors.red[800] : Colors.blue[800],
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../Widgets/Footer.dart';

class JobDetailsScreen extends StatefulWidget {
  final String? jobTitle;
  final String? company;
  final String? location;
  final List<String>? tags;
  final String? salary;
  final String? postedTime;
  final bool? isNew;

  const JobDetailsScreen({
    Key? key,
    this.jobTitle,
    this.company,
    this.location,
    this.tags,
    this.salary,
    this.postedTime,
    this.isNew,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late bool isTablet;
  late bool isWeb;

  bool get isIOS {
    if (kIsWeb) return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  String _getFontFamily() {
    if (kIsWeb) return 'Roboto';
    return isIOS ? '.SF Pro Text' : 'Roboto';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    isTablet = screenSize.width >= 768;
    isWeb = screenSize.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header with SafeArea (fixed style like other screens)
          SafeArea(
            bottom: false,
            child: _buildHeader(context),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NEW tag if applicable
                    if (widget.isNew == true) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                      const SizedBox(height: 12),
                    ],

                    // Company and Title Section
                    Text(
                      widget.company ?? "TechCorp Solutions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B).withOpacity(0.8),
                        fontFamily: _getFontFamily(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.jobTitle ?? "Senior Product Designer",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Job Meta Info
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.location ?? "San Francisco, CA",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Tags
                    if (widget.tags != null && widget.tags!.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.tags!.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Salary
                    if (widget.salary != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.salary!,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Posted time
                    if (widget.postedTime != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.postedTime!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 24),

                    // Divider
                    Divider(
                      thickness: 1,
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 24),

                    // Job Description Section
                    const Text(
                      "Job Description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We are looking for a passionate designer to join our education-focused team. You will be responsible for creating intuitive user experiences for students and freshers entering the workforce. You'll collaborate with product managers and engineers to build the next generation of career tools.",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey.shade700,
                        fontFamily: _getFontFamily(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Requirements Section
                    const Text(
                      "Requirements",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Eligibility
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ELIGIBILITY",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0052A2),
                              letterSpacing: 0.5,
                              fontFamily: _getFontFamily(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Bachelor's in Design, CS or related field",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.4,
                              fontFamily: _getFontFamily(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Experience
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "EXPERIENCE",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0052A2),
                              letterSpacing: 0.5,
                              fontFamily: _getFontFamily(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "3–5 Years (Freshers with strong portfolio welcome)",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.4,
                              fontFamily: _getFontFamily(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Salary and Deadline Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF0052A2).withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SALARY",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0052A2),
                                    letterSpacing: 0.5,
                                    fontFamily: _getFontFamily(),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.salary ?? "\$80k – \$120k",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Per annum",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontFamily: _getFontFamily(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "DEADLINE",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red.shade700,
                                    letterSpacing: 0.5,
                                    fontFamily: _getFontFamily(),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Oct 24, 2023",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Applications close",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontFamily: _getFontFamily(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Map Section
                    Container(
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
                          const Text(
                            "Map",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Map Placeholder
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    size: 40,
                                    color: const Color(0xFF0052A2).withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Main Headquarters",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                      fontFamily: _getFontFamily(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton.icon(
                                    onPressed: () {
                                      // Handle view on map
                                    },
                                    icon: const Icon(Icons.open_in_new, size: 16),
                                    label: const Text("View on Map"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF0052A2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Apply Now Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Applied to ${widget.jobTitle ?? "job"} successfully!'),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052A2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Apply Now",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          const Footer(),
        ],
      ),
    );
  }

  // Fixed Header matching other screens
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
                  "Job Details",
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
}