import 'dart:async';
import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class KulupInfo {
  final String name;
  final String? link;

  const KulupInfo({required this.name, this.link});
}

class HocaInfo {
  final String name;
  final String? title;
  final String? email;
  final String? cvUrl;
  final String? imageUrl;
  final String sourceUrl;

  const HocaInfo({
    required this.name,
    this.title,
    this.email,
    this.cvUrl,
    this.imageUrl,
    required this.sourceUrl,
  });
}

class HocaKulupScraper {
  static const _clubsUrl =
      'https://www.gedik.edu.tr/hakkimizda/idari-birimler/saglik-kultur-ve-spor-daire-baskanligi/ogrenci-kulupleri';
  static const _pageSitemapUrl = 'https://www.gedik.edu.tr/page-sitemap.xml';
  static const _defaultMaxPages = 5; // sınırsız taramaya karşı güvenli sınır

  // CORS proxy URLs for web platform
  static const List<String> _corsProxies = [
    'https://api.codetabs.com/v1/proxy?quest=',
    'https://corsproxy.io/?',
  ];

  int _proxyIndex = 0;
  static const _fallbackImageBase = 'https://api.codetabs.com/v1/proxy?quest=';
  static const List<HocaInfo> _fallbackHocalar = [
    HocaInfo(
      name: 'Dr. Öğr. Üyesi Başak Buluz Kömeçoğlu',
      title: 'Bilgisayar Mühendisliği Bölüm Başkanı',
      email: 'basak.komecoglu@gedik.edu.tr',
      cvUrl: 'https://abis.gedik.edu.tr/basak-buluz-komecoglu',
      imageUrl:
          '${_fallbackImageBase}https%3A%2F%2Fwww.gedik.edu.tr%2Fwp-content%2Fuploads%2F2025%2F06%2Fbasak-buluz-komecoglu-400x300.jpg',
      sourceUrl:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/bilgisayar-muhendisligi/akademik-kadro',
    ),
    HocaInfo(
      name: 'Dr. Öğr. Üyesi Burcu Bektaş Güneş',
      title: 'Bilgisayar Mühendisliği',
      email: 'burcu.gunes@gedik.edu.tr',
      cvUrl: 'https://abis.gedik.edu.tr/burcu-bektas-gunes',
      imageUrl:
          '${_fallbackImageBase}https%3A%2F%2Fwww.gedik.edu.tr%2Fwp-content%2Fuploads%2F2025%2F04%2Fburcu-bektas-gunes-400x300.jpg',
      sourceUrl:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/bilgisayar-muhendisligi/akademik-kadro',
    ),
    HocaInfo(
      name: 'Dr. Öğr. Üyesi Pegah Mutlu',
      title: 'Bilgisayar Mühendisliği',
      email: 'pegah.mutlu@gedik.edu.tr',
      cvUrl: 'https://abis.gedik.edu.tr/pegah-mutlu',
      imageUrl:
          '${_fallbackImageBase}https%3A%2F%2Fwww.gedik.edu.tr%2Fwp-content%2Fuploads%2FPegah-Mutlu-400x300.jpg',
      sourceUrl:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/bilgisayar-muhendisligi/akademik-kadro',
    ),
    HocaInfo(
      name: 'Doç. Dr. Mustafa Yağımlı',
      title: 'Bilgisayar Mühendisliği',
      email: 'mustafa.yagimli@gedik.edu.tr',
      cvUrl: 'https://abis.gedik.edu.tr/mustafa-yagimli',
      imageUrl:
          '${_fallbackImageBase}https%3A%2F%2Fwww.gedik.edu.tr%2Fwp-content%2Fuploads%2FMustafa-ayagimli-400x300.jpg',
      sourceUrl:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/bilgisayar-muhendisligi/akademik-kadro',
    ),
  ];
  static const List<KulupInfo> _fallbackClubs = [
    KulupInfo(name: 'Bilgisayar ve Yazılım Kulübü'),
    KulupInfo(name: 'IEEE Gedik Öğrenci Kolu'),
    KulupInfo(name: 'Robotik ve Yapay Zeka Kulübü'),
    KulupInfo(name: 'Gedik Teknoloji Topluluğu'),
    KulupInfo(name: 'Siber Güvenlik Kulübü'),
    KulupInfo(name: 'Girişimcilik Kulübü'),
  ];

  final http.Client _client;

  HocaKulupScraper({http.Client? client}) : _client = client ?? http.Client();

  Future<List<KulupInfo>> fetchKulupler() async {
    try {
      final response = await _get(_clubsUrl);
      if (response.statusCode != 200) return _fallbackClubs;

      final body = utf8.decode(response.bodyBytes);
      final document = html_parser.parse(body);
      final table = document.querySelector('table');
      if (table == null) return _fallbackClubs;

      final rows = table.querySelectorAll('tbody tr');
      final items = <KulupInfo>[];

      for (final row in rows) {
        final cell = row.querySelector('td');
        if (cell == null) continue;

        final linkEl = cell.querySelector('a');
        final name = _cleanText(linkEl?.text ?? cell.text);
        if (name.isEmpty) continue;

        final href = linkEl?.attributes['href'];
        items.add(KulupInfo(name: name, link: href));
      }

      return items.isNotEmpty ? items : _fallbackClubs;
    } catch (_) {
      return _fallbackClubs;
    }
  }

  Future<List<HocaInfo>> fetchHocalar({int? maxPages}) async {
    try {
      final links = await _fetchAkademikKadroLinks();
      final limit = maxPages ?? _defaultMaxPages;
      final limitedLinks = links.take(limit).toList();

      final results = <HocaInfo>[];
      for (final url in limitedLinks) {
        final pageItems = await _fetchHocalarFromPage(url);
        results.addAll(pageItems);
      }
      return results.isNotEmpty ? results : _fallbackHocalar;
    } catch (_) {
      return _fallbackHocalar;
    }
  }

  /// Fetch academic staff from a specific department URL
  Future<List<HocaInfo>> fetchHocalarFromDepartment(
    String departmentUrl,
  ) async {
    try {
      final pageItems = await _fetchHocalarFromPage(departmentUrl);
      return pageItems.isNotEmpty ? pageItems : _fallbackHocalar;
    } catch (_) {
      return _fallbackHocalar;
    }
  }

  Future<List<String>> _fetchAkademikKadroLinks() async {
    try {
      final response = await _get(_pageSitemapUrl);
      final body = utf8.decode(response.bodyBytes);
      final doc = XmlDocument.parse(body);
      final urls = doc
          .findAllElements('loc')
          .map((e) => e.text.trim())
          .where((url) => url.contains('/akademik-kadro'))
          .toSet();
      return urls.toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<HocaInfo>> _fetchHocalarFromPage(String url) async {
    try {
      final response = await _get(url);
      final body = utf8.decode(response.bodyBytes);
      final document = html_parser.parse(body);
      final cards = document.querySelectorAll('.personnel-item');

      final items = <HocaInfo>[];
      for (final card in cards) {
        final info = card.querySelector('.personnel-info');
        if (info == null) continue;

        final name = _cleanText(info.querySelector('.personnel-author')?.text);
        if (name.isEmpty) continue;

        final positions = info
            .querySelectorAll('.personnel-position')
            .map((e) => _cleanText(e.text))
            .where((e) => e.isNotEmpty)
            .toList();

        final emailHref = info
            .querySelector('a[href^="mailto:"]')
            ?.attributes['href']
            ?.replaceFirst('mailto:', '')
            .trim();

        final cvHref = info
            .querySelectorAll('a')
            .map((a) => a.attributes['href'])
            .firstWhere(
              (href) => href != null && !href.startsWith('mailto:'),
              orElse: () => null,
            );

        final imageUrl = card.querySelector('img')?.attributes['src'];
        final proxiedImageUrl = imageUrl != null && imageUrl.isNotEmpty
            ? '${_corsProxies[0]}${Uri.encodeComponent(imageUrl)}'
            : null;

        items.add(
          HocaInfo(
            name: name,
            title: positions.isNotEmpty ? positions.first : null,
            email: emailHref?.isNotEmpty == true ? emailHref : null,
            cvUrl: cvHref,
            imageUrl: proxiedImageUrl,
            sourceUrl: url,
          ),
        );
      }

      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<http.Response> _get(String url) async {
    // Try direct connection first
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119 Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response;
      }
    } catch (e) {
      // If direct connection fails, try CORS proxies
      for (int i = 0; i < _corsProxies.length; i++) {
        try {
          final proxyUrl =
              _corsProxies[(_proxyIndex + i) % _corsProxies.length];
          final proxiedUrl = proxyUrl + Uri.encodeComponent(url);

          final response = await _client
              .get(
                Uri.parse(proxiedUrl),
                headers: const {
                  'User-Agent':
                      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119 Safari/537.36',
                },
              )
              .timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            _proxyIndex = (_proxyIndex + i) % _corsProxies.length;
            return response;
          }
        } catch (_) {
          continue;
        }
      }
    }

    throw Exception('Failed to fetch data from $url');
  }

  String _cleanText(String? value) {
    if (value == null) return '';
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Returns a proxied image URL for web platform to avoid CORS issues
  String getProxiedImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return imageUrl;
    // Use the first CORS proxy for images
    return '${_corsProxies[0]}${Uri.encodeComponent(imageUrl)}';
  }

  /// Fetches additional details from ABIS profile page
  Future<Map<String, String>> fetchAbisDetails(String abisUrl) async {
    final details = <String, String>{};

    try {
      final response = await _get(abisUrl);
      final body = utf8.decode(response.bodyBytes);
      final document = html_parser.parse(body);

      // Look for all table rows which typically contain the information
      final allRows = document.querySelectorAll('tr, .info-item, .detail-item');

      for (final row in allRows) {
        final cells = row.querySelectorAll('td, th, .label, .value');
        if (cells.length >= 2) {
          final label = _cleanText(cells[0].text.toLowerCase());
          final value = _cleanText(cells[1].text);

          if (value.isEmpty || value == '-') continue;

          // Department (Departman)
          if (label.contains('departman') || label.contains('department')) {
            details['department'] = value;
          }
          // Title/Position (Unvan)
          else if (label.contains('unvan') ||
              label.contains('title') ||
              label.contains('pozisyon')) {
            details['title'] = value;
          }
          // Email (E-posta)
          else if (label.contains('e-posta') ||
              label.contains('e-mail') ||
              label.contains('email')) {
            details['email'] = value;
          }
          // Phone (Telefon)
          else if (label.contains('telefon') || label.contains('phone')) {
            details['telephone'] = value;
          }
          // Extension (Dahili)
          else if (label.contains('dahili') ||
              label.contains('extension') ||
              label.contains('dahilî')) {
            details['extension'] = value;
          }
          // Location (Lokasyon/Yerleşke)
          else if (label.contains('lokasyon') ||
              label.contains('location') ||
              label.contains('yerleşke') ||
              label.contains('campus') ||
              label.contains('yerleske')) {
            details['location'] = value;
          }
          // Office/Room (Oda/Ofis)
          else if (label.contains('oda') ||
              label.contains('ofis') ||
              label.contains('room') ||
              label.contains('office')) {
            details['officeNumber'] = value;
          }
          // Building (Bina)
          else if (label.contains('bina') ||
              label.contains('building') ||
              label.contains('blok')) {
            details['building'] = value;
          }
        }
      }

      // Also check for phone links
      final phoneElement = document.querySelector('a[href^="tel:"]');
      if (phoneElement != null && !details.containsKey('telephone')) {
        final phone = _cleanText(phoneElement.text);
        if (phone.isNotEmpty) {
          details['telephone'] = phone;
        }
      }

      // Check for email links
      final emailElement = document.querySelector('a[href^="mailto:"]');
      if (emailElement != null && !details.containsKey('email')) {
        final email = emailElement.attributes['href']
            ?.replaceFirst('mailto:', '')
            .trim();
        if (email != null && email.isNotEmpty) {
          details['email'] = email;
        }
      }
    } catch (e) {
      // Silently fail, return whatever we found
    }

    return details;
  }
}
