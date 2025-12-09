import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

// Models
class FacultyMember {
  final String name;
  final String title;
  final String department;
  final String email;
  final String cvLink;

  FacultyMember({
    required this.name,
    required this.title,
    required this.department,
    required this.email,
    required this.cvLink,
  });

  @override
  String toString() {
    return 'Name: $name\nTitle: $title\nDepartment: $department\nEmail: $email\nCV: $cvLink\n';
  }
}

class Club {
  final String name;

  Club({required this.name});

  @override
  String toString() => name;
}

// Web Scraper Service
class HocaVeKuluepScrapper {
  static const String facultyUrl =
      'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/bilgisayar-muhendisligi/akademik-kadro';
  static const String clubsUrl =
      'https://www.gedik.edu.tr/hakkimizda/idari-birimler/saglik-kultur-ve-spor-daire-baskanligi/ogrenci-kulupleri';

  // Add proper headers to mimic browser request
  static final Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
    'Connection': 'keep-alive',
  };

  /// Fetches faculty member information including name, email, experience, and department
  Future<List<FacultyMember>> fetchFacultyMembers() async {
    try {
      final response = await http.get(
        Uri.parse(facultyUrl),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timeout after 30 seconds');
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load faculty page: ${response.statusCode}');
      }

      final document = parser.parse(response.body);
      final facultyMembers = <FacultyMember>[];

      // Find all content elements that might contain faculty info
      final contentElements = document.querySelectorAll('p, div, td');
      
      for (var element in contentElements) {
        final text = element.text.trim();
        
        // Look for faculty member patterns (Turkish academic titles)
        if (text.contains('Dr. Öğr. Üyesi') || 
            text.contains('Prof. Dr.') || 
            text.contains('Doç. Dr.') ||
            text.contains('Öğr. Gör.')) {
          
          String name = '';
          String title = '';
          String department = 'Bilgisayar Mühendisliği';
          String email = '';
          String cvLink = '';
          
          // Extract title and name from text
          final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          
          for (var line in lines) {
            // Extract academic title and name
            if (line.contains('Dr.') || line.contains('Prof.') || line.contains('Doç.') || line.contains('Öğr. Gör.')) {
              final titlePatterns = ['Prof. Dr.', 'Doç. Dr.', 'Dr. Öğr. Üyesi', 'Öğr. Gör. Dr.', 'Öğr. Gör.'];
              
              for (var pattern in titlePatterns) {
                if (line.contains(pattern)) {
                  title = pattern;
                  name = line.replaceFirst(pattern, '').trim();
                  break;
                }
              }
            }
            
            // Check for department info
            if (line.toLowerCase().contains('bölüm') || line.toLowerCase().contains('başkan')) {
              department = line;
            }
          }
          
          // Find email in element or its children
          final emailLinks = element.querySelectorAll('a[href^="mailto:"]');
          if (emailLinks.isNotEmpty) {
            email = emailLinks.first.attributes['href']?.replaceFirst('mailto:', '') ?? '';
          }
          
          // Find CV link (Öz Geçmiş - Resume link)
          final cvLinks = element.querySelectorAll('a[href*="abis.gedik.edu.tr"], a[href*="ozgecmis"]');
          if (cvLinks.isNotEmpty) {
            cvLink = cvLinks.first.attributes['href'] ?? '';
          }
          
          if (name.isNotEmpty) {
            facultyMembers.add(FacultyMember(
              name: name,
              title: title,
              department: department,
              email: email,
              cvLink: cvLink,
            ));
          }
        }
      }

      // Remove duplicates based on name
      final uniqueMembers = <String, FacultyMember>{};
      for (var member in facultyMembers) {
        uniqueMembers[member.name] = member;
      }

      return uniqueMembers.values.toList();
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: ${e.message}. Please check your internet connection.');
    } on SocketException catch (e) {
      throw Exception('No internet connection: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching faculty members: $e');
    }
  }

  /// Fetches student club information
  Future<List<Club>> fetchClubs() async {
    try {
      final response = await http.get(
        Uri.parse(clubsUrl),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timeout after 30 seconds');
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load clubs page: ${response.statusCode}');
      }

      final document = parser.parse(response.body);
      final clubs = <Club>[];

      // Find table cells containing club names
      final tableCells = document.querySelectorAll('td');
      
      for (var cell in tableCells) {
        final text = cell.text.trim();
        
        // Turkish clubs typically end with "Kulübü", "Kulüp", "Topluluğu", or "Kolu"
        if (text.isNotEmpty && 
            (text.contains('Kulübü') || 
             text.contains('Kulüp') ||
             text.contains('Topluluğu') ||
             text.contains('Kolu')) &&
            !text.contains('Kulüp Logoları')) {
          clubs.add(Club(name: text));
        }
      }

      // Remove duplicates
      final uniqueClubs = <String, Club>{};
      for (var club in clubs) {
        uniqueClubs[club.name] = club;
      }

      return uniqueClubs.values.toList();
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: ${e.message}. Please check your internet connection.');
    } on SocketException catch (e) {
      throw Exception('No internet connection: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching clubs: $e');
    }
  }

  /// Fetches all data (faculty members and clubs)
  Future<Map<String, dynamic>> fetchAllData() async {
    try {
      final results = await Future.wait([
        fetchFacultyMembers(),
        fetchClubs(),
      ]);

      return {
        'facultyMembers': results[0] as List<FacultyMember>,
        'clubs': results[1] as List<Club>,
      };
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
