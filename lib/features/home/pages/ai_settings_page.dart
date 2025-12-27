import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  String _selectedProvider = 'gemini';
  String _selectedModel = 'gemini-2.5-flash';
  String _selectedLanguage = 'turkish';
  bool _isLoading = false;
  bool _obscureApiKey = true;

  final Map<String, String> _availableLanguages = {
    'turkish': 'Türkçe',
    'english': 'English',
    'german': 'Deutsch',
    'french': 'Français',
    'spanish': 'Español',
    'italian': 'Italiano',
    'arabic': 'العربية',
    'russian': 'Русский',
    'chinese': '中文',
    'japanese': '日本語',
  };

  final Map<String, List<Map<String, String>>> _availableModels = {
    'gemini': [
      {'value': 'gemini-2.5-flash', 'label': 'Gemini 2.5 Flash (Recommended)'},
      {'value': 'gemini-1.5-flash', 'label': 'Gemini 1.5 Flash'},
      {'value': 'gemini-1.5-pro', 'label': 'Gemini 1.5 Pro'},
      {'value': 'gemini-2.0-flash-exp', 'label': 'Gemini 2.0 Flash (Experimental)'},
    ],
    'openai': [
      {'value': 'gpt-4o', 'label': 'GPT-4o'},
      {'value': 'gpt-4o-mini', 'label': 'GPT-4o Mini'},
      {'value': 'gpt-4-turbo', 'label': 'GPT-4 Turbo'},
      {'value': 'gpt-3.5-turbo', 'label': 'GPT-3.5 Turbo'},
    ],
    'anthropic': [
      {'value': 'claude-3-5-sonnet-20241022', 'label': 'Claude 3.5 Sonnet'},
      {'value': 'claude-3-opus-20240229', 'label': 'Claude 3 Opus'},
      {'value': 'claude-3-haiku-20240307', 'label': 'Claude 3 Haiku'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('ai_settings')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _apiKeyController.text = data['apiKey'] ?? '';
            _selectedProvider = data['provider'] ?? 'gemini';
            _selectedModel = data['model'] ?? 'gemini-2.5-flash';
            _selectedLanguage = data['language'] ?? 'turkish';
          });
        }
      }
    } catch (e) {
      _showError('Ayarlar yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      await FirebaseFirestore.instance
          .collection('ai_settings')
          .doc(user.uid)
          .set({
        'apiKey': _apiKeyController.text.trim(),
        'provider': _selectedProvider,
        'model': _selectedModel,
        'language': _selectedLanguage,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ayarlar başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Ayarlar kaydedilemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  void _showApiKeyHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔑 API Anahtarı Nasıl Alınır?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '1. Google AI Studio\'ya Gidin:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://makersuite.google.com/app/apikey');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, 
                        size: 20, 
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'https://makersuite.google.com/app/apikey',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '2. Google Hesabınızla Giriş Yapın',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '3. "Create API Key" Butonuna Tıklayın',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '4. API Anahtarınızı Kopyalayın ve Buraya Yapıştırın',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'API anahtarınızı kimseyle paylaşmayın!',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
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
        title: const Text('AI Ayarları'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      elevation: 2,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Kariyer planı özelliğini kullanmak için Google Gemini API anahtarı gereklidir.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // API Key Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'API Anahtarı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showApiKeyHelp,
                          icon: const Icon(Icons.help_outline, size: 18),
                          label: const Text('Nasıl alınır?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _apiKeyController,
                      obscureText: _obscureApiKey,
                      decoration: InputDecoration(
                        hintText: 'AIza...',
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureApiKey
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscureApiKey = !_obscureApiKey);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'API anahtarı gereklidir';
                        }
                        if (!value.startsWith('AIza')) {
                          return 'Geçersiz API anahtarı formatı';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // AI Provider Selection
                    const Text(
                      'AI Sağlayıcı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _selectedProvider,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'gemini', child: Text('Google Gemini')),
                          DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                          DropdownMenuItem(value: 'anthropic', child: Text('Anthropic Claude')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedProvider = value;
                              // Set default model for the provider
                              _selectedModel = _availableModels[value]!.first['value']!;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Model Selection
                    const Text(
                      'AI Modeli',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _availableModels[_selectedProvider]!.map((model) {
                          return RadioListTile<String>(
                            title: Text(model['label']!),
                            value: model['value']!,
                            groupValue: _selectedModel,
                            onChanged: (value) {
                              setState(() => _selectedModel = value!);
                            },
                            activeColor: const Color.fromARGB(255, 136, 31, 96),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Language Selection
                    const Text(
                      'Yanıt Dili',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _availableLanguages.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedLanguage = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Model Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Model Hakkında:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getModelDescription(_selectedModel),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Ayarları Kaydet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getModelDescription(String model) {
    switch (model) {
      // Gemini models
      case 'gemini-2.5-flash':
        return 'En yeni ve hızlı Gemini modeli. Dengeli performans ve kalite için önerilir.';
      case 'gemini-1.5-flash':
        return 'Hızlı yanıt süreleri. Temel kariyer önerileri için idealdir.';
      case 'gemini-1.5-pro':
        return 'Gelişmiş Gemini modeli. Daha detaylı ve kapsamlı analizler sağlar.';
      case 'gemini-2.0-flash-exp':
        return 'Deneysel model. En yeni özellikleri test etmek için kullanılır.';
      
      // OpenAI models
      case 'gpt-4o':
        return 'En gelişmiş GPT-4 modeli. Üstün analiz ve yanıt kalitesi.';
      case 'gpt-4o-mini':
        return 'Hızlı ve uygun maliyetli GPT-4. İyi performans sunar.';
      case 'gpt-4-turbo':
        return 'Geliştirilmiş GPT-4. Hızlı ve güçlü yanıtlar.';
      case 'gpt-3.5-turbo':
        return 'Ekonomik seçenek. Temel görevler için yeterli.';
      
      // Anthropic models
      case 'claude-3-5-sonnet-20241022':
        return 'En yeni Claude modeli. Mükemmel analiz ve yazma yetenekleri.';
      case 'claude-3-opus-20240229':
        return 'En güçlü Claude modeli. Karmaşık görevler için idealdir.';
      case 'claude-3-haiku-20240307':
        return 'Hızlı ve verimli Claude modeli. Temel görevler için uygundur.';
      
      default:
        return '';
    }
  }
}
