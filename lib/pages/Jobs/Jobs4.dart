import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../Widgets/Footer.dart';
import 'Jobs3.dart'; // for JobDetail model

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

  bool get isIOS {
    if (kIsWeb) return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  String _getFontFamily() {
    if (kIsWeb) return 'Roboto';
    return isIOS ? '.SF Pro Text' : 'Roboto';
  }

  // ── Deadline formatting ───────────────────────────────────────────────────

  String _formatDeadline(String raw) {
    if (raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    isTablet = screenSize.width >= 768;
    isWeb = screenSize.width >= 1024;

    final job = widget.job;
    final deadlinePassed = _isDeadlinePassed(job.applicationDeadline);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Fixed Header ──
          SafeArea(
            bottom: false,
            child: _buildHeader(context),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                                color: const Color(0xFF0052A2).withOpacity(0.15)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.companyName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B).withOpacity(0.7),
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
                      _infoRow(
                          Icons.location_on_outlined, job.location, Colors.grey.shade600),
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
                      _infoRow(Icons.access_time,
                          job.postedTimeLabel, Colors.grey.shade500),

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
                            borderColor:
                                const Color(0xFF0052A2).withOpacity(0.12),
                            labelColor: const Color(0xFF0052A2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoBox(
                            label: 'DEADLINE',
                            value: _formatDeadline(job.applicationDeadline),
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
                      body: job.experience.isNotEmpty ? job.experience : '—',
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
                              border: Border.all(color: Colors.grey.shade200),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.open_in_new,
                                      size: 16, color: Color(0xFF0052A2)),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              deadlinePassed ? 'Applications Closed' : 'Apply Now',
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
          ),

          // ── Footer ──
          const Footer(),
        ],
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
        constraints:
            BoxConstraints(maxWidth: isWeb ? 1200 : double.infinity),
        padding: EdgeInsets.symmetric(horizontal: hPad),
        height: headerHeight,
        child: Row(
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

  Widget _tagChip(String label,
      {required Color bg, required Color color}) {
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