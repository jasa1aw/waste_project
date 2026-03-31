import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/models/scan_record.dart';
import 'package:razdelchik/models/waste_type.dart';
import 'package:razdelchik/services/stats/scan_history_service.dart';

class ResultScreen extends StatefulWidget {
  final String analysisResult;
  final String imagePath;

  const ResultScreen({
    Key? key,
    required this.analysisResult,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScanHistoryService _scanHistoryService = ScanHistoryService();
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveScanIfAuthorized();
  }

  Future<void> _saveScanIfAuthorized() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _saved) {
      return;
    }

    final insights = _buildInsights(widget.analysisResult);

    setState(() {
      _saving = true;
    });

    try {
      final record = ScanRecord(
        id: '',
        userId: user.uid,
        wasteName: insights.itemName,
        wasteType: insights.type,
        category: insights.category,
        pointsAwarded: insights.category == WasteCategory.recyclable ? 10 : 4,
        scannedAt: DateTime.now(),
        imagePath: widget.imagePath,
        isFavorite: false,
      );
      await _scanHistoryService.addScanRecord(record);
      _saved = true;
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Сканерлеу тарихын сақтау мүмкін болмады.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  ResultInsights _buildInsights(String rawText) {
    final text = rawText.toLowerCase();

    if (text.contains('пласт') || text.contains('бутыл') || text.contains('бөтелке')) {
      return const ResultInsights(
        itemName: 'Пластик қалдық',
        type: WasteType.plastic,
        category: WasteCategory.recyclable,
        binColor: 'қызғылт сары',
        reason: 'Пластикті жуып, сұрыптағаннан кейін қайта өңдеуге болады.',
      );
    }
    if (text.contains('бумаг') || text.contains('картон') || text.contains('қағаз')) {
      return const ResultInsights(
        itemName: 'Қағаз қалдық',
        type: WasteType.paper,
        category: WasteCategory.recyclable,
        binColor: 'көк',
        reason:
            'Қағаз бен картон құрғақ және таза болса, макулатураға қабылданады.',
      );
    }
    if (text.contains('стек') || text.contains('шыны') || text.contains('әйнек')) {
      return const ResultInsights(
        itemName: 'Шыны қалдық',
        type: WasteType.glass,
        category: WasteCategory.recyclable,
        binColor: 'жасыл',
        reason:
            'Шыны жақсы қайта өңделеді және бірнеше рет қолданыла алады.',
      );
    }
    if (text.contains('металл') || text.contains('банк') || text.contains('темір') || text.contains('қалбыр')) {
      return const ResultInsights(
        itemName: 'Металл қалдық',
        type: WasteType.metal,
        category: WasteCategory.recyclable,
        binColor: 'қызыл',
        reason: 'Металдар қайта өңделеді және жаңа ресурстарды өндіруді азайтады.',
      );
    }
    if (text.contains('орган') || text.contains('пищ') || text.contains('тамақ') || text.contains('азық')) {
      return const ResultInsights(
        itemName: 'Органикалық қалдық',
        type: WasteType.organic,
        category: WasteCategory.nonRecyclable,
        binColor: 'қара',
        reason:
            'Органика әдетте құрғақ қайта өңдеуге жіберілмейді және бөлек жинауды қажет етеді.',
      );
    }

    return const ResultInsights(
      itemName: 'Белгісіз қалдық түрі',
      type: WasteType.unknown,
      category: WasteCategory.nonRecyclable,
      binColor: 'қызыл',
      reason: 'Түрі нақты анықталмады, ұқсас нұсқаларды қолмен тексеріңіз.',
      suggestion:
          'Пластикке немесе аралас қаптамаға ұқсайды. Құрамын таңбалау арқылы нақтылаңыз.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights(widget.analysisResult);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        title: const Text('Талдау нәтижесі'),
        iconTheme: IconThemeData(color: Colors.green.shade900),
        titleTextStyle: TextStyle(
          color: Colors.green.shade900,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'image_${widget.imagePath}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.eco, size: 48, color: Colors.green.shade700),
                        const SizedBox(height: 12),
                        Text(
                          'Қалдық түрі:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          insights.itemName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Контейнер: ${insights.binColor}.\n${insights.reason}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade700,
                          ),
                        ),
                        if (insights.suggestion != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            'AI-кеңесі: ${insights.suggestion}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          widget.analysisResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade800,
                          ),
                        ),
                        if (_saving)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.home),
                  label:
                      const Text('Басты бетке', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultInsights {
  const ResultInsights({
    required this.itemName,
    required this.type,
    required this.category,
    required this.binColor,
    required this.reason,
    this.suggestion,
  });

  final String itemName;
  final WasteType type;
  final WasteCategory category;
  final String binColor;
  final String reason;
  final String? suggestion;
}
