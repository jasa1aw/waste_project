import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashAnalysisService {
  static const List<String> _modelFallbacks = <String>[
    'google/gemini-2.5-flash',
    'google/gemini-2.5-flash-lite',
    'google/gemini-3.5-flash',
  ];

  static const String _universalPrompt = '''
" Сен — тәжірибелі эколог және қоқысты сұрыптау бойынша сарапшысың. Сенің міндетің — маған суреттегі қалдықтарды анықтауға және дұрыс тастауға көмектесу.
Суретті талдау барысында мыналарды ескер:
Суретте көріп тұрған барлық қоқыс немесе қалдық түрлерін анықта. Егер суретте қоқыс болмаса, бірақ тірі нысандар болса, сол туралы хабарла.
Егер суретте қоқыс болса, оның әрбір түрін атап шық.
Мыналарды көрсет:
Оны қай контейнерге тастау керек екенін. Егер бұл қалдық түрі үшін әдетте түрлі-түсті жәшіктер қолданылса, ұсынылатын жәшік түсін міндетті түрде көрсет:
шыны үшін жасыл; қағаз үшін көк; пластик үшін қызғылт сары; картон үшін сары; қайта өңделетін қалдықтар үшін (егер жоғарыдағы нақты түс сәйкес келмесе) қызыл; органикалық қалдықтар үшін қара;
сондай-ақ, қауіпті қоқыстар үшін қоңыр түс қолданылатынын.
Егер бұл қауіпті қалдықтар болса (мысалы, батарейкалар, сынапты шамдар, термометрлер, химикаттар, электроника), оларды кәдімгі контейнерлерге тастауға болмайтынын нақты көрсет. Оның орнына, оларды қауіпті қалдықтарды қабылдаудың арнайы пунктіне немесе жақын маңдағы экопунктке апару туралы нұсқаулық бер.
Алдын ала қандай да бір әрекеттер қажет пе (мысалы, жуу, қақпағын шешу, қысу, орау).
Сондай-ақ, қоқыстың әрбір түрі үшін оның шамамен ыдырау мерзімін көрсет. Түрлі материалдардың ыдырау мерзімдері туралы деректер:
Дәретхана қағазы 2-ден 4 күнге дейін. Жануарлардың нәжісі 10 күнге дейін. Банан қабығы 3 - 4 апта. Алма қалдығы 2 айға дейін. Басқа тамақ қалдықтары 10 күннен 1 айға дейін.
Қағаз сүлгілер 1 айдан 1,5 айға дейін. Газет қағазы мен кітаптар 1 айдан 3 айға дейін. Ет өнімдері 1 айдан бастап. Тетрапак қаптамасы 2 - 3 ай.
Апельсин қабығы 6 ай. Биологиялық ыдырайтын пластик 6 айға дейін. Жапырақтар, тұқымдар, бұтақтар 1 айдан 1 жылға дейін. Мақта жібі 3 айдан 1 жылға дейін.
Фотосуреттер 3 айдан 1 жылға дейін. Картон қораптар 1 жылға дейін. Кеңсе қағазы 2 жыл. Фанера, тақталар 1-ден 3 жылға дейін. Табиғи киімдер мен маталар 2-ден 3 жылға дейін.
Күйдірілген консерві қалбырлары 2-ден 3 жылға дейін. Темекі сүзгілері 2-ден 5 жылға дейін. Балауыз қағаз 5 жылға дейін. Сүйек қалдықтары 7 жылға дейін. Темір арматура 10 жылға дейін.
Темір консерві қалбырлары 10 жылға дейін. Табиғи шикізаттан жасалған аяқ киім 10 жылға дейін. Боялған ағаш 15 жылға дейін.
Сағыз 30 жылға дейін. Синтетикалық киімдер мен маталар 40 жылға дейін. Жасанды материалдардан жасалған аяқ киім 80 жылға дейін. Кірпіш, бетон сынықтары 100 жылға дейін.
Автокөлік аккумуляторлары 100 жылға дейін. Фольга 100 жылға дейін. Резеңке автокөлік шиналары 100-ден 140 жылға дейін. Пластик бөтелкелер 100-ден 200 жылға дейін.
Полиэтилен пакеттер, пленка 200 жыл. Ыдыс жууға арналған губкалар 200 жыл. Электр батареялары 200 жыл. Балалар жөргегі, төсемдер 200-ден 600 жылға дейін.
Азық-түлікке арналмаған пластик 400 жыл. Алюминий қалбырлар 500 жыл. Қармақ жібі 600 жыл. Берік пластик, оптикалық талшық 600 жыл. Шыны 1000 жылдан астам.
Қазақ тілінде жауап бер. Жауаптың сауатты, орфографиялық және пунктуациялық қателерсіз болуын қадағала және мәтінді ешқандай ерекшелеусіз (без форматирования) жаз.
Жауапты мына сөз тіркесінен баста: "Сәлеметсіз бе, мен Раздельчикпін".
Артық сөздерсіз және пайымдауларсыз, үлгі бойынша қысқаша жауап бер. Жауап үлгісі: "Сәлеметсіз бе, мен Раздельчикпін. Бұл пластик бөтелке. Оны пластикке арналған контейнерге тастау керек. Табиғатта пластик 600 жылға дейін ыдырайды. Оны пластикке арналған жәшікке тастаңыз, ол қызғылт сары түсті."
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
            'API кілті табылмады. Өтініш, баптауларда API кілтіңізді көрсетіңіз.');
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Сурет файлы табылмады');
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
          ],
          "max_tokens": 4000,
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
              Exception('$model моделі қолжетімді емес: ${response.statusCode}');
          continue;
        }

        throw Exception(
            'OpenRouter қатесі: ${response.statusCode}\n${response.body}');
      }

      throw lastModelError ??
          Exception(
              'Суретті талдау үшін қолжетімді OpenRouter моделі табылмады.');
    } catch (e) {
      throw Exception('Суретті талдау кезінде қате орын алды: $e');
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
      throw Exception('Суретті сақтау кезінде қате орын алды: $e');
    }
  }
}
