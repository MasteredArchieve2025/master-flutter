// lib/pages/Charity/Charity.dart
import 'package:flutter/material.dart';
import '../../widgets/footer.dart';

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            height: 50, // Taller header
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0077C2), Color(0xFF004BA0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Back Button
                Positioned(
                  top: 10,
                  left: 15,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Header Text
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10), // Moves text down
                    child: Text(
                      'Charity Club',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== MAIN CONTENT =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== IMAGE CARD =====
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1509099836639-18ba1795216d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3wzMjM4NDZ8MHwxfHNlYXJjaHwxfHxsZWFybmluZyUyMGNoaWxkfGVufDB8fHx8MTY5NzI4NDM0OXww&ixlib=rb-4.0.3&q=80&w=800',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // ===== NEW VOLUNTEER =====
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          size: 40,
                          color: Color(0xFF0077C2),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'New Volunteer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0077C2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== SUPPORT US =====
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support Us !',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077C2),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Join us in transforming lives through education—your support can shape a brighter future for every child.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            height: 1.43, // Equivalent to lineHeight: 20
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== DONATION BUTTONS =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Column(
                      children: [500, 1000, 2000].map((amount) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077C2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              '₹ $amount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ===== CUSTOM AMOUNT & DONATE NOW =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Column(
                      children: [
                        // Custom Amount Button
                        SizedBox(
                          width: 280,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE0E0E0),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              '₹ Custom Amount',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Donate Now Button
                        SizedBox(
                          width: 280,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077C2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Donate Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== MISSION =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077C2),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'An education charity mission aims to provide quality learning opportunities to underprivileged children and youth. It focuses on empowering communities through access to schools, scholarships, and educational resources. The mission envisions a future where every child has the tools to succeed, regardless of background.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== VISION =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vision',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077C2),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Our vision is to create a world where every child has access to quality education, regardless of their background.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            height: 1.43,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'We aim to empower underprivileged communities through learning opportunities and holistic support. By fostering knowledge, we envision a future driven by equality, dignity, and hope.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== OUR VOLUNTEERS =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our Volunteers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077C2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            'https://randomuser.me/api/portraits/men/32.jpg',
                            'https://randomuser.me/api/portraits/women/44.jpg',
                            'https://randomuser.me/api/portraits/men/65.jpg',
                            'https://randomuser.me/api/portraits/women/12.jpg',
                            'https://randomuser.me/api/portraits/men/23.jpg',
                          ].map((uri) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(uri),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}