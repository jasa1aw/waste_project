import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashAnalysisService {
  static const List<String> _modelFallbacks = <String>[
    'google/gemini-2.0-flash-001',
    'google/gemini-2.0-flash-lite-001',
    'google/gemini-1.5-flash',
  ];

  static const String _universalPrompt = '''
" Ты — опытный эколог и эксперт по сортировке отходов. Твоя задача — помочь мне определить и правильно утилизировать отходы, изображённые на приложенном фото.
При анализе изображения, пожалуйста:
Определи все виды мусора или отходов, которые ты видишь на фотографии. Если на фото нет мусора, а есть живые объекты, сообщи об этом.
Если на изображении есть мусор, перечисли каждый его вид.
Укажи:
В какой контейнер его следует выбросить. Если для данного вида отходов обычно используются разноцветные баки, обязательно укажи рекомендуемый цвет бака:
зеленый для стекла;синий для бумаги;оранжевый для пластика;желтый для картона;красный для перерабатываемых отходов, если не подходит конкретный цвет выше;черный для органических отходов;
а также, что коричневый используется для опасного мусора.
Если это опасные отходы, например батарейки, ртутные лампы, градусники, химикаты, электроника, чётко укажи, что их нельзя выбрасывать в обычные контейнеры. Вместо этого, дай инструкцию отнести их в специальный пункт приёма опасных отходов или ближайший экопункт.
Необходимы ли предварительные действия, например промыть, снять крышку, сжать, упаковать.
Также, для каждого вида отхода, укажи примерный срок его разложения. Вот данные о сроках разложения различных материалов:
Туалетная бумага от 2 до 4 дней.Помет животных до 10 дней.Банановая кожура 3 - 4 недели.Огрызок яблока до 2 месяцев.Другие пищевые отходы от 10 дней до 1 месяца.
Бумажные полотенца от 1 месяца до 1,5 месяца.Газетная бумага и книги от 1 месяца до 3 месяцев.Мясопродукты от 1 месяца.Упаковка тетрапак 2 - 3 месяца.
Кожура апельсина 6 месяцев.Биоразлагаемый пластик до 6 месяцев.Листья, семена, ветки от 1 месяца до 1 года.Веревка из хлопка от 3 месяцев до 1 года.
Фотографии от 3 месяцев до 1 года.Картонные коробки до 1 года.Бумага офисная 2 года.Фанера, доски от 1 до 3 лет.Натуральная одежда и ткани от 2 до 3 лет.
Обожжённые консервные банки от 2 до 3 лет.Фильтры окурков от 2 до 5 лет.Бумага восковая из воска до 5 лет.Остатки костей до 7 лет.Железная арматура до 10 лет.
Железные консервные банки до 10 лет.Обувь из натурального сырья до 10 лет.Крашеное дерево до 15 лет.
Жевательная резинка до 30 лет.Синтетическая одежда и ткани до 40 лет.Обувь из искусственных материалов до 80 лет.Обломки кирпича, бетона до 100 лет.
Автоаккумуляторы до 100 лет.Фольга до 100 лет.Резиновые автомобильные покрышки от 100 до 140 лет.Пластиковые бутылки от 100 до 200 лет.
Полиэтиленовые пакеты, пленка 200 лет.Губки для мытья посуды 200 лет.Электрические батарейки 200 лет.Детские подгузники, прокладки от 200 до 600 лет.
Пластик непищевой 400 лет.Алюминиевые банки 500 лет.Рыболовная леска 600 лет.Прочный пластик, оптоволокно 600 лет.Стекло более 1000 лет.
Ответь на русском языке. Убедись, что ответ грамотный, без орфографических и пунктуационных ошибок, и не используй никакого выделения текста.
Начни ответ с фразы: "Здравствуйте, я Раздельчик".
Дай краткий ответ по шаблону без лишних фраз и рассуждений и суждений. Пример ответа: "Здравствуйте, я Раздельчик. Это пластиковая бутылка. Её нужно выбросить в контейнер для пластика. Так как в природе пластик разлагается до 600 лет. Выбрось её в контейнер для пластика, он оранжевый."
"
''';

  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('openrouter_api_key');
  }

  Future<String> analyzeImage(String imagePath) async {
    try {
      final apiKey = await _getApiKey();
      // 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
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            'API ключ не найден. Пожалуйста, укажите ваш API ключ в настройках.');
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Файл изображения не найден');
      }
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';

      final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
      Exception? lastModelError;

      for (final model in _modelFallbacks) {
        final body = {
          "model": model,
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": _universalPrompt},
                {
                  "type": "image_url",
                  "image_url": {"url": dataUrl}
                }
              ]
            }
          ]
        };

        final response = await http.post(
          url,
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final dynamic data = jsonDecode(response.body);
          final String rawResponse =
              data['choices'][0]['message']['content'] as String;
          return _formatResponse(rawResponse);
        }

        if (_isMissingModelEndpoint(response)) {
          lastModelError =
              Exception('Модель $model недоступна: ${response.statusCode}');
          continue;
        }

        throw Exception(
            'Ошибка OpenRouter: ${response.statusCode}\n${response.body}');
      }

      throw lastModelError ??
          Exception(
              'Не удалось подобрать доступную модель OpenRouter для анализа изображения.');
    } catch (e) {
      throw Exception('Ошибка при анализе изображения: $e');
    }
  }

  bool _isMissingModelEndpoint(http.Response response) {
    if (response.statusCode != 404 && response.statusCode != 400) {
      return false;
    }

    final bodyLower = response.body.toLowerCase();
    return bodyLower.contains('no endpoints found') ||
        bodyLower.contains('model not found') ||
        bodyLower.contains('unknown model');
  }

  String _formatResponse(String rawResponse) {
    final cleanedResponse = rawResponse.trim().replaceAll(RegExp(r'\s+'), ' ');

    final withoutNumbers =
        cleanedResponse.replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '');

    final sentences = withoutNumbers
        .split(RegExp(r'[.!?]'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return '${sentences.map((s) => s.trim()).join('. ')}.';
  }

  Future<String> saveImageToLocal(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'trash_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';
      final file = File(imagePath);
      await file.copy(savedPath);
      return savedPath;
    } catch (e) {
      throw Exception('Ошибка при сохранении изображения: $e');
    }
  }
}
