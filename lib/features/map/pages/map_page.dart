import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  // 1. Kampüs koordinatı
  final double latitude1 = 40.901562939743194;
  final double longitude1 = 29.219376509577515;

  // 2. Yeni konum koordinatı
  final double latitude2 = 40.902221896711495;
  final double longitude2 = 29.27526517498325;

  // Web + Mobil uyumlu URL açma
  Future<void> openMapsWebSafe(String url) async {
    if (kIsWeb) {
      // Web'de normal launchUrlString açıyor
      await launchUrlString(url);
    } else {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication, // Mobil için dış uygulamada aç
      );
    }
  }

  // İlk kampüs
  void openMaps1() {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$latitude1,$longitude1&travelmode=driving";
    openMapsWebSafe(url);
  }

  // İkinci kampüs
  void openMaps2() {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$latitude2,$longitude2&travelmode=driving";
    openMapsWebSafe(url);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 25),

          const Text(
            "Kampüs Haritası",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 136, 31, 96),
            ),
          ),

          const SizedBox(height: 20),

          // ⭐ 1. Harita Kutusu ⭐
          _buildMapBox(
            context,
            tag: "map1",
            image: "assets/images/harita.jpg",
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 450),
                  pageBuilder: (_, __, ___) => const FullscreenMapImage(
                    tag: "map1",
                    image: "assets/images/harita.jpg",
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          _buildButton(
            text: "Google Maps ile Yol Tarifi Al (Kartal Kampüsü)",
            onPressed: openMaps1,
          ),

          const SizedBox(height: 40),

          // ⭐ 2. Harita Kutusu ⭐
          _buildMapBox(
            context,
            tag: "map2",
            image: "assets/images/harita2.jpg",
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 450),
                  pageBuilder: (_, __, ___) => const FullscreenMapImage(
                    tag: "map2",
                    image: "assets/images/harita2.jpg",
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          _buildButton(
            text: "Google Maps ile Yol Tarifi Al (Halil Kaya Kampüsü)",
            onPressed: openMaps2,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---------- Harita Kutusu ----------
  Widget _buildMapBox(
    BuildContext context, {
    required String tag,
    required String image,
    required VoidCallback onTap,
  }) {
    return Hero(
      tag: tag,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(image, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  // ---------- Buton ----------
  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.navigation_rounded, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 136, 31, 96),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onPressed,
          label: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ),
    );
  }
}

// ---------- FULLSCREEN GÖRSEL ----------
class FullscreenMapImage extends StatelessWidget {
  final String tag;
  final String image;

  const FullscreenMapImage({super.key, required this.tag, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: InteractiveViewer(maxScale: 5.0, child: Image.asset(image)),
        ),
      ),
    );
  }
}
