import 'package:flutter/material.dart';
import 'package:gedik_mobil/models/career_plan.dart';
import 'package:gedik_mobil/services/career_plan_service.dart';
import 'ai_settings_page.dart';

class CareerPlanPage extends StatefulWidget {
  const CareerPlanPage({super.key});

  @override
  State<CareerPlanPage> createState() => _CareerPlanPageState();
}

class _CareerPlanPageState extends State<CareerPlanPage> {
  bool _isLoading = false;
  CareerPlan? _currentPlan;

  @override
  void initState() {
    super.initState();
    _loadLatestPlan();
  }

  Future<void> _loadLatestPlan() async {
    setState(() => _isLoading = true);
    try {
      final plan = await CareerPlanService.getLatestCareerPlan(
        await _getCurrentUserId(),
      );
      if (mounted) {
        setState(() {
          _currentPlan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Plan yüklenemedi: $e');
      }
    }
  }

  Future<String> _getCurrentUserId() async {
    final user = await CareerPlanService.collectUserData('');
    return user['userId'] ?? '';
  }

  Future<void> _generateNewPlan() async {
    setState(() => _isLoading = true);

    try {
      final newPlan = await CareerPlanService.createCareerPlan();
      if (mounted) {
        setState(() {
          _currentPlan = newPlan;
          _isLoading = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Kariyer planı oluşturulamadı: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Başarılı'),
        content: const Text('Kariyer planınız başarıyla oluşturuldu!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    // Check if error is about AI settings
    final isSettingsError = message.contains('AI settings') || 
                           message.contains('API key') ||
                           message.contains('not configured');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Hata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (isSettingsError) ...[
              const SizedBox(height: 16),
              const Text(
                'AI ayarlarınızı yapılandırmanız gerekiyor.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          if (isSettingsError)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AISettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Ayarlara Git'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        title: const Text('Kariyer Planım'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'AI Ayarları',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AISettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 136, 31, 96),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Kariyer planınız oluşturuluyor...',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bu işlem birkaç saniye sürebilir.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _currentPlan == null
              ? _buildEmptyState()
              : _buildCareerPlanView(),
      floatingActionButton: _currentPlan != null
          ? FloatingActionButton.extended(
              onPressed: _generateNewPlan,
              backgroundColor: const Color.fromARGB(255, 136, 31, 96),
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology,
              size: 80,
              color: Color.fromARGB(255, 136, 31, 96),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz Kariyer Planınız Yok',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ders programınız, haftalık planlarınız ve geçmiş tercihleriniz analiz edilerek size özel bir kariyer planı oluşturulacak.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _generateNewPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                'Kariyer Planı Oluştur',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerPlanView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card with creation date
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 136, 31, 96),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Oluşturulma: ${_formatDate(_currentPlan!.createdAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Career Advice Section
          _buildSectionTitle('💼 Kariyer Tavsiyesi'),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _currentPlan!.careerAdvice,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Career Paths Section
          _buildSectionTitle('🎯 Olası Kariyer Yolları'),
          ..._currentPlan!.careerPaths.map((path) => _buildListItem(path)),
          const SizedBox(height: 24),

          // Skills to Develop Section
          _buildSectionTitle('🚀 Geliştirilmesi Gereken Beceriler'),
          ..._currentPlan!.skillsToDevelop.map((skill) => _buildListItem(skill)),
          const SizedBox(height: 24),

          // Goals Section
          _buildSectionTitle('📋 Hedefleriniz'),
          
          // Short-term goals
          _buildGoalCard(
            '📅 Kısa Vadeli (3-6 Ay)',
            _currentPlan!.goals['short'] ?? 'Belirtilmemiş',
            Colors.green.shade50,
            Colors.green.shade700,
          ),
          const SizedBox(height: 12),

          // Medium-term goals
          _buildGoalCard(
            '📆 Orta Vadeli (6-12 Ay)',
            _currentPlan!.goals['medium'] ?? 'Belirtilmemiş',
            Colors.orange.shade50,
            Colors.orange.shade700,
          ),
          const SizedBox(height: 12),

          // Long-term goals
          _buildGoalCard(
            '🎓 Uzun Vadeli (1-3 Yıl)',
            _currentPlan!.goals['long'] ?? 'Belirtilmemiş',
            Colors.blue.shade50,
            Colors.blue.shade700,
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 136, 31, 96),
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle,
          color: Color.fromARGB(255, 136, 31, 96),
        ),
        title: Text(
          text,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildGoalCard(String title, String description, Color bgColor, Color textColor) {
    return Card(
      elevation: 2,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
