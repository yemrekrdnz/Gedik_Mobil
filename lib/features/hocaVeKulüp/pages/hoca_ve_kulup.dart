import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/academic_staff.dart';
import '../models/club.dart';
import '../models/department.dart';
import '../services/hoca_kulup_scraper.dart';

class HocaVeKuluep extends StatefulWidget {
  const HocaVeKuluep({super.key});

  @override
  State<HocaVeKuluep> createState() => _HocaVeKuluepState();
}

class _HocaVeKuluepState extends State<HocaVeKuluep>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HocaKulupScraper _scraperService = HocaKulupScraper();

  List<AcademicStaff> _academicStaff = [];
  List<AcademicStaff> _filteredStaff = [];
  List<Club> _clubs = [];
  List<Club> _filteredClubs = [];

  bool _isLoadingStaff = false;
  bool _isLoadingClubs = false;

  String? _staffError;
  String? _clubsError;

  bool _isUsingMockData = false;

  Department _selectedDepartment = Departments.defaultDepartment;

  final TextEditingController _staffSearchController = TextEditingController();
  final TextEditingController _clubSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _staffSearchController.dispose();
    _clubSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadAcademicStaff();
    _loadClubs();
  }

  Future<void> _loadAcademicStaff({bool reset = true}) async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
    });

    try {
      // Fetch from selected department only
      final hocalar = await _scraperService.fetchHocalarFromDepartment(
        _selectedDepartment.url,
      );
      setState(() {
        _academicStaff = hocalar
            .map(
              (hoca) => AcademicStaff(
                name: hoca.name,
                email: hoca.email ?? '',
                telephone: '', // Not available from new scraper
                faculty: hoca.title ?? '',
                pastExperience: '', // Not available from new scraper
                imageUrl: hoca.imageUrl,
                cvUrl: hoca.cvUrl,
                sourceUrl: hoca.sourceUrl,
                officeNumber: null,
                building: null,
              ),
            )
            .toList();
        _filteredStaff = _academicStaff;
        _isLoadingStaff = false;
        _isUsingMockData = hocalar.length == 4; // Fallback has 4 items
        if (_academicStaff.isEmpty) {
          _staffError = 'Akademik kadro bilgisi bulunamadı.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingStaff = false;
        _staffError = 'Veri yüklenirken hata oluştu: $e';
      });
    }
  }

  void _onDepartmentChanged(Department? newDepartment) {
    if (newDepartment == null || newDepartment == _selectedDepartment) return;

    setState(() {
      _selectedDepartment = newDepartment;
      _staffSearchController.clear();
    });

    _loadAcademicStaff();
  }

  void _filterStaff(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStaff = _academicStaff;
      } else {
        _filteredStaff = _academicStaff.where((staff) {
          return staff.name.toLowerCase().contains(query.toLowerCase()) ||
              staff.email.toLowerCase().contains(query.toLowerCase()) ||
              staff.faculty.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _loadClubs() async {
    setState(() {
      _isLoadingClubs = true;
      _clubsError = null;
    });

    try {
      final kulupler = await _scraperService.fetchKulupler();
      setState(() {
        _clubs = kulupler
            .map(
              (kulup) => Club(
                name: kulup.name,
                description: '', // Not available from new scraper
                imageUrl: null, // Not available from new scraper
                contactInfo: kulup.link ?? '',
              ),
            )
            .toList();
        _filteredClubs = _clubs;
        _isLoadingClubs = false;
        _isUsingMockData = kulupler.length == 6; // Fallback has 6 items
        if (_clubs.isEmpty) {
          _clubsError = 'Kulüp bilgisi bulunamadı.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingClubs = false;
        _clubsError = 'Veri yüklenirken hata oluştu: $e';
      });
    }
  }

  void _filterClubs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredClubs = _clubs;
      } else {
        _filteredClubs = _clubs.where((club) {
          return club.name.toLowerCase().contains(query.toLowerCase()) ||
              club.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akademik Kadro & Kulüpler'),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Akademik Kadro'),
            Tab(icon: Icon(Icons.groups), text: 'Kulüpler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAcademicStaffTab(), _buildClubsTab()],
      ),
    );
  }

  Widget _buildAcademicStaffTab() {
    if (_isLoadingStaff) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color.fromARGB(255, 136, 31, 96)),
            SizedBox(height: 16),
            Text('Akademik kadro bilgileri yükleniyor...'),
          ],
        ),
      );
    }

    if (_staffError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_staffError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAcademicStaff,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_academicStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Akademik kadro bilgisi bulunamadı.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAcademicStaff,
              child: const Text('Yenile'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAcademicStaff(reset: true),
      color: const Color.fromARGB(255, 136, 31, 96),
      child: Column(
        children: [
          // Info banner - only show if using fallback data
          if (_isUsingMockData)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo verisi gösteriliyor - Web sitesine erişilemiyor',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Department Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.school,
                  color: Color.fromARGB(255, 136, 31, 96),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Department>(
                      value: _selectedDepartment,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      items: Departments.all.map((Department department) {
                        return DropdownMenuItem<Department>(
                          value: department,
                          child: Text(
                            department.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _onDepartmentChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _staffSearchController,
              decoration: InputDecoration(
                hintText: 'Hoca ara (isim, email, bölüm)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _staffSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _staffSearchController.clear();
                          _filterStaff('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterStaff,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredStaff.length,
              itemBuilder: (context, index) {
                final staff = _filteredStaff[index];
                return _buildStaffCard(staff);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(AcademicStaff staff) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (staff.imageUrl != null)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(
                        255,
                        136,
                        31,
                        96,
                      ).withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        staff.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Show placeholder icon on error
                          return const Icon(
                            Icons.person,
                            size: 40,
                            color: Color.fromARGB(255, 136, 31, 96),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: const Color.fromARGB(255, 136, 31, 96),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        136,
                        31,
                        96,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color.fromARGB(255, 136, 31, 96),
                    ),
                  ),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 136, 31, 96),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.faculty,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Contact Information
            if (staff.email.isNotEmpty)
              _buildInfoRow(
                Icons.email,
                'E-posta',
                staff.email,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: staff.email));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('E-posta kopyalandı: ${staff.email}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

            if (staff.telephone.isNotEmpty)
              _buildInfoRow(
                Icons.phone,
                'Telefon',
                staff.telephone,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: staff.telephone));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Telefon numarası kopyalandı: ${staff.telephone}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

            if (staff.officeNumber != null && staff.officeNumber!.isNotEmpty)
              _buildInfoRow(Icons.meeting_room, 'Ofis No', staff.officeNumber!),

            if (staff.building != null && staff.building!.isNotEmpty)
              _buildInfoRow(Icons.business, 'Bina', staff.building!),

            // CV/Academic Page Link
            if (staff.cvUrl != null && staff.cvUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showStaffDetails(staff),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Detaylı Bilgi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            136,
                            31,
                            96,
                          ),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 136, 31, 96),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: staff.cvUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('CV linki kopyalandı'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Linki Kopyala',
                      color: const Color.fromARGB(255, 136, 31, 96),
                    ),
                  ],
                ),
              ),

            // Past Experience
            if (staff.pastExperience.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.work_history,
                'Deneyim',
                staff.pastExperience,
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color.fromARGB(255, 136, 31, 96)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        if (onTap != null) Icon(Icons.copy, size: 16, color: Colors.grey[400]),
      ],
    );

    if (onTap != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: row,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: row,
    );
  }

  Future<void> _showStaffDetails(AcademicStaff staff) async {
    if (staff.cvUrl == null || staff.cvUrl!.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 136, 31, 96),
        ),
      ),
    );

    try {
      final details = await _scraperService.fetchAbisDetails(staff.cvUrl!);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Update staff with new details if found
      final updatedStaff = AcademicStaff(
        name: staff.name,
        email: details['email']?.isNotEmpty == true
            ? details['email']!
            : staff.email,
        telephone: details['telephone']?.isNotEmpty == true
            ? details['telephone']!
            : staff.telephone,
        faculty: staff.faculty,
        pastExperience: staff.pastExperience,
        imageUrl: staff.imageUrl,
        cvUrl: staff.cvUrl,
        sourceUrl: staff.sourceUrl,
        officeNumber: details['officeNumber'] ?? staff.officeNumber,
        building: details['building'] ?? staff.building,
        department: details['department'],
        title: details['title'],
        extension: details['extension'],
        location: details['location'],
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  staff.name,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 136, 31, 96),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (updatedStaff.imageUrl != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        updatedStaff.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Color.fromARGB(255, 136, 31, 96),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  updatedStaff.faculty,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                // Work Information Section
                if (updatedStaff.department != null ||
                    updatedStaff.title != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Çalışma Bilgileri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 136, 31, 96),
                    ),
                  ),
                  const Divider(height: 16),
                  if (updatedStaff.department != null &&
                      updatedStaff.department!.isNotEmpty)
                    _buildDetailRow(
                      Icons.account_balance,
                      'Departman',
                      updatedStaff.department!,
                    ),
                  if (updatedStaff.title != null &&
                      updatedStaff.title!.isNotEmpty)
                    _buildDetailRow(Icons.badge, 'Unvan', updatedStaff.title!),
                ],

                // Contact Information Section
                const SizedBox(height: 16),
                const Text(
                  'İletişim',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 136, 31, 96),
                  ),
                ),
                const Divider(height: 16),
                if (updatedStaff.email.isNotEmpty)
                  _buildDetailRow(Icons.email, 'E-posta', updatedStaff.email),
                if (updatedStaff.telephone.isNotEmpty)
                  _buildDetailRow(
                    Icons.phone,
                    'Telefon',
                    updatedStaff.telephone,
                  ),
                if (updatedStaff.extension != null &&
                    updatedStaff.extension!.isNotEmpty)
                  _buildDetailRow(
                    Icons.dialpad,
                    'Dahili',
                    updatedStaff.extension!,
                  ),
                if (updatedStaff.location != null &&
                    updatedStaff.location!.isNotEmpty)
                  _buildDetailRow(
                    Icons.location_on,
                    'Lokasyon',
                    updatedStaff.location!,
                  ),
                if (updatedStaff.officeNumber != null &&
                    updatedStaff.officeNumber!.isNotEmpty)
                  _buildDetailRow(
                    Icons.meeting_room,
                    'Ofis/Oda',
                    updatedStaff.officeNumber!,
                  ),
                if (updatedStaff.building != null &&
                    updatedStaff.building!.isNotEmpty)
                  _buildDetailRow(
                    Icons.business,
                    'Bina',
                    updatedStaff.building!,
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: staff.cvUrl!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('CV linki kopyalandı'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('CV Linkini Kopyala'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detaylı bilgi alınamadı'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 136, 31, 96)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            color: const Color.fromARGB(255, 136, 31, 96),
            tooltip: 'Kopyala',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label kopyalandı'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClubsTab() {
    if (_isLoadingClubs) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color.fromARGB(255, 136, 31, 96)),
            SizedBox(height: 16),
            Text('Kulüp bilgileri yükleniyor...'),
          ],
        ),
      );
    }

    if (_clubsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_clubsError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadClubs,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_clubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Kulüp bilgisi bulunamadı.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadClubs, child: const Text('Yenile')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClubs,
      color: const Color.fromARGB(255, 136, 31, 96),
      child: Column(
        children: [
          // Info banner - only show if using fallback data
          if (_isUsingMockData)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo verisi gösteriliyor - Web sitesine erişilemiyor',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _clubSearchController,
              decoration: InputDecoration(
                hintText: 'Kulüp ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _clubSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _clubSearchController.clear();
                          _filterClubs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterClubs,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredClubs.length,
              itemBuilder: (context, index) {
                final club = _filteredClubs[index];
                return _buildClubCard(club);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(Club club) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club Image
          if (club.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              child: Image.network(
                club.imageUrl!,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: const Color.fromARGB(
                      255,
                      136,
                      31,
                      96,
                    ).withOpacity(0.1),
                    child: const Center(
                      child: Icon(
                        Icons.groups,
                        size: 60,
                        color: Color.fromARGB(255, 136, 31, 96),
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Club Name
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 136, 31, 96),
                  ),
                ),

                // Description
                if (club.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    club.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Contact Info
                if (club.contactInfo != null &&
                    club.contactInfo!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: club.contactInfo!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('İletişim bilgisi kopyalandı'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Kulüp Sayfası'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 136, 31, 96),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 136, 31, 96),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
