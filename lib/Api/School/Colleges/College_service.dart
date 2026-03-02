import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CollegeService {
  static const String baseUrl = 'https://master-backend-18ik.onrender.com/api';

  // Fetch college categories
  static Future<List<CollegeCategory>> getCollegeCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/college-categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => CollegeCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
  // Fetch college degrees
  static Future<List<CollegeDegree>> getCollegeDegrees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/degrees'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => CollegeDegree.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load degrees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching degrees: $e');
    }
  }

  // Fetch all colleges
  static Future<List<CollegeInfo>> getColleges() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/colleges'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => CollegeInfo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load colleges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching colleges: $e');
    }
  }
}

class CollegeInfo {
  final int id;
  final String name;
  final String shortName;
  final int categoryId;
  final int degreeId;
  final String ownership;
  final String collegeStatus;
  final String affiliatedUniversity;
  final String address;
  final String city;
  final String state;
  final String aboutCollege;
  final String academics;
  final List<String> departments;
  final List<String> facilities;
  final String placementInfo;
  final String admissionInfo;
  final String phone;
  final String whatsapp;
  final String email;
  final String website;
  final String mapLink;
  final String rating;
  final String logo;
  final String collegeImage;
  final String categoryName;
  final String degreeName;

  CollegeInfo({
    required this.id,
    required this.name,
    required this.shortName,
    required this.categoryId,
    required this.degreeId,
    required this.ownership,
    required this.collegeStatus,
    required this.affiliatedUniversity,
    required this.address,
    required this.city,
    required this.state,
    required this.aboutCollege,
    required this.academics,
    required this.departments,
    required this.facilities,
    required this.placementInfo,
    required this.admissionInfo,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.website,
    required this.mapLink,
    required this.rating,
    required this.logo,
    required this.collegeImage,
    required this.categoryName,
    required this.degreeName,
  });

  factory CollegeInfo.fromJson(Map<String, dynamic> json) {
    return CollegeInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      degreeId: json['degreeId'] ?? 0,
      ownership: json['ownership'] ?? '',
      collegeStatus: json['collegeStatus'] ?? '',
      affiliatedUniversity: json['affiliatedUniversity'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      aboutCollege: json['aboutCollege'] ?? '',
      academics: json['academics'] ?? '',
      departments: List<String>.from(json['departments'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      placementInfo: json['placementInfo'] ?? '',
      admissionInfo: json['admissionInfo'] ?? '',
      phone: json['phone'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      mapLink: json['mapLink'] ?? '',
      rating: json['rating'] ?? '0.0',
      logo: json['logo'] ?? '',
      collegeImage: json['collegeImage'] ?? '',
      categoryName: json['categoryName'] ?? '',
      degreeName: json['degreeName'] ?? '',
    );
  }

  // Map to format used in the College4 UI
  Map<String, dynamic> toCollegeMap() {
    return {
      'id': id.toString(),
      'name': name,
      'location': '$city · $state',
      'type': collegeStatus, // Using Autonomous/Govt/Private
      'category': ownership, // Using for filters, e.g. Private/Govt
      'degreeId': degreeId,
      'degreeName': degreeName,
      'logo': logo,
      'fullData': this, // Pass full data to view details on College5
    };
  }
}


class CollegeDegree {
  final int id;
  final String name;
  final int categoryId;
  final String description;
  final String createdAt;
  final String categoryName;

  CollegeDegree({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.createdAt,
    required this.categoryName,
  });

  factory CollegeDegree.fromJson(Map<String, dynamic> json) {
    return CollegeDegree(
      id: json['id'],
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }

  // Map to format used in the College2 UI
  Map<String, dynamic> toDegreeMap() {
    IconData icon = _getIconForDegree(name);
    return {
      'id': id,
      'title': name,
      'desc': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'icon': icon,
    };
  }

  // Temporary helper to assign an icon to degrees
  IconData _getIconForDegree(String name) {
    String lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('b.e') || lower.contains('engineering')) return Icons.memory;
    if (lower.contains('arch')) return Icons.business;
    if (lower.contains('ca') || lower.contains('computer') || lower.contains('it')) return Icons.laptop;
    if (lower.contains('sc') || lower.contains('science')) return Icons.science;
    if (lower.contains('bba') || lower.contains('mba') || lower.contains('business')) return Icons.work;
    if (lower.contains('mbbs') || lower.contains('medical') || lower.contains('health')) return Icons.medical_services;
    return Icons.school;
  }
}


class CollegeCategory {
  final int id;
  final String categoryName;
  final String categoryImage;
  final String description;
  final String createdAt;

  CollegeCategory({
    required this.id,
    required this.categoryName,
    required this.categoryImage,
    required this.description,
    required this.createdAt,
  });

  factory CollegeCategory.fromJson(Map<String, dynamic> json) {
    return CollegeCategory(
      id: json['id'],
      categoryName: json['categoryName'],
      categoryImage: json['categoryImage'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  // Map to category format used in the UI
  Map<String, dynamic> toCategoryMap() {
    // Map category names to appropriate icons and colors
    IconData icon = _getIconForCategory(categoryName);
    Color color = _getColorForCategory(categoryName);

    return {
      'id': id,
      'name': categoryName,
      'icon': icon,
      'color': color,
      'description': description,
      'image': categoryImage,
    };
  }

  // Helper method to get icon based on category name
  IconData _getIconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'engineering':
        return Icons.engineering;
      case 'arts & science':
      case 'arts and science':
        return Icons.palette;
      case 'medical':
        return Icons.medical_services;
      case 'polytechnic':
        return Icons.computer;
      case 'law':
        return Icons.gavel;
      case 'veterinary':
        return Icons.pets;
      default:
        return Icons.school;
    }
  }

  // Helper method to get color based on category name
  Color _getColorForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'engineering':
        return const Color(0xFF0B5ED7);
      case 'arts & science':
      case 'arts and science':
        return const Color(0xFFDC2626);
      case 'medical':
        return const Color(0xFF059669);
      case 'polytechnic':
        return const Color(0xFF7C3AED);
      case 'law':
        return const Color(0xFFEA580C);
      case 'veterinary':
        return const Color(0xFF0891B2);
      default:
        return const Color(0xFF0B5ED7);
    }
  }
}