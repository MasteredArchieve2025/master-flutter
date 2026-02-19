import 'dart:convert';
import 'package:http/http.dart' as http;
import '../baseurl.dart';

class SchoolService {
  static String get baseUrl => '${BaseUrl.baseUrl}/api';
  
  static final SchoolService _instance = SchoolService._internal();
  factory SchoolService() => _instance;
  SchoolService._internal();

  Future<List<dynamic>> fetchSchools() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/schools'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        return [];
      } else {
        throw Exception('Failed to load schools: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching schools: $e');
    }
  }

  Future<Map<String, dynamic>> fetchSchoolById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/schools/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final school = School.fromJson(data['data']);
          return school.toJson();
        }
        throw Exception('School not found');
      } else {
        throw Exception('Failed to load school: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching school details: $e');
    }
  }
}

class School {
  final int id;
  final String schoolName;
  final List<String> category;
  final String? schoolLogo;
  final double rating;
  final String result;
  final List<String> classes;
  final List<String> classesOffered;
  final List<String> teachingMode;
  final String location;
  final String? mapLink;
  final String about;
  final String mobileNumber;
  final String whatsappNumber;
  final List<String> gallery;

  School({
    required this.id,
    required this.schoolName,
    required this.category,
    this.schoolLogo,
    required this.rating,
    required this.result,
    required this.classes,
    required this.classesOffered,
    required this.teachingMode,
    required this.location,
    this.mapLink,
    required this.about,
    required this.mobileNumber,
    required this.whatsappNumber,
    required this.gallery,
  });

 factory School.fromJson(Map<String, dynamic> json) {
  // ================= IMAGE URL FIX =================
  String? logo;

  // Get logo from possible keys
  final logoKeys = [
    'schoolLogo',
    'school_logo',
    'image',
    'schoolImage',
    'school_image',
    'logo'
  ];

  for (var key in logoKeys) {
    if (json[key] != null && json[key].toString().trim().isNotEmpty) {
      logo = json[key].toString().trim();
      break;
    }
  }

  // Convert relative path → full URL
  if (logo != null && !logo.startsWith('http')) {
    final base = BaseUrl.baseUrl.endsWith('/')
        ? BaseUrl.baseUrl.substring(0, BaseUrl.baseUrl.length - 1)
        : BaseUrl.baseUrl;

    final path = logo.startsWith('/') ? logo : '/$logo';

    logo = base + path;
    
    // Safety encode (optional, but good for spaces)
    try {
        logo = Uri.encodeFull(logo!);
    } catch (_) {}
  }

  // ================= GALLERY FIX =================
  List<String> galleryUrls = [];

  if (json['gallery'] != null && json['gallery'] is List) {
    galleryUrls = (json['gallery'] as List).map((url) {
      String urlStr = url.toString().trim();

      if (urlStr.isNotEmpty && !urlStr.startsWith('http')) {
        final base = BaseUrl.baseUrl.endsWith('/')
            ? BaseUrl.baseUrl.substring(0, BaseUrl.baseUrl.length - 1)
            : BaseUrl.baseUrl;

        final path = urlStr.startsWith('/') ? urlStr : '/$urlStr';

        urlStr = base + path;
        
        try {
            urlStr = Uri.encodeFull(urlStr);
        } catch (_) {}
      }

      return urlStr;
    }).toList();
  }

  // ================= RETURN MODEL =================
  return School(
    id: json['id'] ?? 0,

    schoolName: json['schoolName'] ?? '',

    category: json['category'] != null
        ? List<String>.from(json['category'])
            .map((e) => e.toString().toUpperCase().trim())
            .toList()
        : [],

    schoolLogo: logo,

    rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,

    result: json['result'] ?? '',

    classes: json['classes'] != null
        ? List<String>.from(json['classes'])
        : [],

    classesOffered: json['classesOffered'] != null
        ? List<String>.from(json['classesOffered'])
        : [],

    teachingMode: json['teachingMode'] != null
        ? List<String>.from(json['teachingMode'])
        : [],

    location: json['location'] ?? '',

    mapLink: json['mapLink'],

    about: json['about'] ?? '',

    mobileNumber: json['mobileNumber'] ?? '',

    whatsappNumber: json['whatsappNumber'] ?? '',

    gallery: galleryUrls,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolName': schoolName,
      'category': category,
      'schoolLogo': schoolLogo,
      'rating': rating.toString(),
      'result': result,
      'classes': classes,
      'classesOffered': classesOffered,
      'teachingMode': teachingMode,
      'location': location,
      'mapLink': mapLink,
      'about': about,
      'mobileNumber': mobileNumber,
      'whatsappNumber': whatsappNumber,
      'gallery': gallery,
    };
  }

  String get board => category.isNotEmpty ? category.first : '';
}
