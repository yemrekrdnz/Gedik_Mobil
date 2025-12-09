
import 'package:flutter/material.dart';
import 'package:gedik_mobil/features/hocaVeKuluep/pages/hoca_ve_kuluep_scrapper.dart';

class HocaVeKuluep extends StatefulWidget {
  const HocaVeKuluep({super.key});

  @override
  State<HocaVeKuluep> createState() => _HocaVeKuluepState();
}

class _HocaVeKuluepState extends State<HocaVeKuluep> {
  final HocaVeKuluepScrapper _scraper = HocaVeKuluepScrapper();
  
  List<FacultyMember> _facultyMembers = [];
  List<Club> _clubs = [];
  
  bool _isLoadingFaculty = false;
  bool _isLoadingClubs = false;
  
  String? _facultyError;
  String? _clubsError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadFacultyMembers(),
      _loadClubs(),
    ]);
  }

  Future<void> _loadFacultyMembers() async {
    setState(() {
      _isLoadingFaculty = true;
      _facultyError = null;
    });

    try {
      final members = await _scraper.fetchFacultyMembers();
      setState(() {
        _facultyMembers = members;
        _isLoadingFaculty = false;
      });
    } catch (e) {
      setState(() {
        _facultyError = e.toString();
        _isLoadingFaculty = false;
      });
    }
  }

  Future<void> _loadClubs() async {
    setState(() {
      _isLoadingClubs = true;
      _clubsError = null;
    });

    try {
      final clubs = await _scraper.fetchClubs();
      setState(() {
        _clubs = clubs;
        _isLoadingClubs = false;
      });
    } catch (e) {
      setState(() {
        _clubsError = e.toString();
        _isLoadingClubs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFacultySection(),
            const SizedBox(height: 32),
            _buildClubsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Akademik Kadro',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_isLoadingFaculty)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_facultyError != null)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _facultyError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_facultyMembers.isEmpty && !_isLoadingFaculty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Akademik kadro bulunamadı'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _facultyMembers.length,
            itemBuilder: (context, index) {
              final member = _facultyMembers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                    child: Text(
                      member.name.isNotEmpty ? member.name[0] : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    member.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (member.title.isNotEmpty)
                        Text(member.title),
                      if (member.department.isNotEmpty)
                        Text(member.department, style: const TextStyle(fontSize: 12)),
                      if (member.email.isNotEmpty)
                        Text(
                          member.email,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 136, 31, 96),
                          ),
                        ),
                    ],
                  ),
                  trailing: member.cvLink.isNotEmpty
                      ? const Icon(Icons.link)
                      : null,
                  isThreeLine: true,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildClubsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Öğrenci Kulüpleri',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_isLoadingClubs)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_clubs.length} kulüp bulundu',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        if (_clubsError != null)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _clubsError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_clubs.isEmpty && !_isLoadingClubs)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Kulüp bulunamadı'),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _clubs.map((club) {
              return Chip(
                label: Text(club.name),
                backgroundColor: const Color.fromARGB(255, 136, 31, 96).withOpacity(0.1),
              );
            }).toList(),
          ),
      ],
    );
  }
}