import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedApiKey = prefs.getString('openrouter_api_key') ?? '';
    setState(() {
      _apiKeyController.text = savedApiKey;
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openrouter_api_key', _apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API ключ успешно сохранен')),
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
        const SnackBar(content: Text('API ключ удален')),
      );
    }
  }

  Future<void> _launchOpenRouter() async {
    final Uri url = Uri.parse('https://openrouter.ai/');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть ссылку')),
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
        title: const Text('Настройки'),
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
                                'Внимание!',
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
                            'Для работы приложения необходим API ключ OpenRouter. Без него анализ изображений будет недоступен.',
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
                              'Как получить API ключ:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '1. Перейдите на сайт OpenRouter',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _launchOpenRouter,
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Открыть OpenRouter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '2. Зарегистрируйтесь на сайте (можно через Google или GitHub)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3. Выберите модель Google: Gemma 3 4B (бесплатно) или иную подходящую',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '4. Нажмите "Создание ключа API"',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '5. Скопируйте полученный ключ в поле ниже',
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _apiKeyController,
                            decoration: InputDecoration(
                              labelText: 'API ключ OpenRouter',
                              hintText: 'Введите ваш API ключ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              helperText: 'Ключ должен начинаться с "sk-or-v1-"',
                              helperStyle: TextStyle(color: Colors.green.shade700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _clearApiKey,
                          icon: Icon(Icons.clear, color: Colors.red.shade400),
                          tooltip: 'Очистить ключ',
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
                          label: const Text('Сохранить ключ'),
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