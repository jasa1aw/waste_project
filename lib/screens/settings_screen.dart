import 'package:flutter/material.dart';
import 'package:razdelchik/services/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = true;
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedApiKey = prefs.getString('openrouter_api_key') ?? '';
    final remindersEnabled = prefs.getBool('sorting_reminders_enabled') ?? true;
    setState(() {
      _apiKeyController.text = savedApiKey;
      _remindersEnabled = remindersEnabled;
      _isLoading = false;
    });
  }

  Future<void> _setRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sorting_reminders_enabled', enabled);
    await NotificationsService.instance.setRemindersEnabled(enabled);
    if (!mounted) {
      return;
    }
    setState(() {
      _remindersEnabled = enabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Сұрыптау туралы еске салғыш қосылды'
              : 'Сұрыптау туралы еске салғыш өшірілді',
        ),
      ),
    );
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openrouter_api_key', _apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API кілті сәтті сақталды')),
      );
    }
  }

  Future<void> _clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('openrouter_api_key');
    setState(() {
      _apiKeyController.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API кілті өшірілді')),
      );
    }
  }

  Future<void> _launchOpenRouter() async {
    final Uri url = Uri.parse('https://openrouter.ai/');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сілтемені ашу мүмкін болмады')),
        );
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        title: const Text('Баптаулар'),
        iconTheme: IconThemeData(color: Colors.green.shade900),
        titleTextStyle: TextStyle(
          color: Colors.green.shade900,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                              const SizedBox(width: 8),
                              Text(
                                'Назар аударыңыз!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Қосымшаның жұмыс істеуі үшін OpenRouter API кілті қажет. Онсыз суреттерді талдау мүмкін болмайды.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'API кілтін қалай алуға болады:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '1. OpenRouter сайтына өтіңіз',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _launchOpenRouter,
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('OpenRouter ашу'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '2. Сайтта тіркеліңіз (Google немесе GitHub арқылы болады)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3. Google: Gemma 3 4B (тегін) немесе басқа сәйкес келетін модельді таңдаңыз',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '4. "API кілтін жасау" түймесін басыңыз',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '5. Алынған кілтті төмендегі өріске көшіріңіз',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile.adaptive(
                        value: _remindersEnabled,
                        onChanged: _setRemindersEnabled,
                        title: const Text('Сұрыптау туралы еске салғыштар'),
                        subtitle: const Text('Күнделікті сұрыптау туралы FCM-хабарландырулар.'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _apiKeyController,
                            decoration: InputDecoration(
                              labelText: 'OpenRouter API кілті',
                              hintText: 'API кілтіңізді енгізіңіз',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              helperText: 'Кілт "sk-or-v1-" деп басталуы керек',
                              helperStyle: TextStyle(color: Colors.green.shade700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _clearApiKey,
                          icon: Icon(Icons.clear, color: Colors.red.shade400),
                          tooltip: 'Кілтті тазарту',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveApiKey,
                          icon: const Icon(Icons.save),
                          label: const Text('Кілтті сақтау'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 