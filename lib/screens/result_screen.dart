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
            content: Text('Не удалось сохранить историю сканирования.')),
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

    if (text.contains('пласт') || text.contains('бутыл')) {
      return const ResultInsights(
        itemName: 'Пластиковый отход',
        type: WasteType.plastic,
        category: WasteCategory.recyclable,
        binColor: 'оранжевый',
        reason: 'Пластик подлежит переработке после промывки и сортировки.',
      );
    }
    if (text.contains('бумаг') || text.contains('картон')) {
      return const ResultInsights(
        itemName: 'Бумажный отход',
        type: WasteType.paper,
        category: WasteCategory.recyclable,
        binColor: 'синий',
        reason:
            'Бумагу и картон принимают в макулатуру, если они сухие и чистые.',
      );
    }
    if (text.contains('стек')) {
      return const ResultInsights(
        itemName: 'Стеклянный отход',
        type: WasteType.glass,
        category: WasteCategory.recyclable,
        binColor: 'зеленый',
        reason:
            'Стекло хорошо перерабатывается и может использоваться многократно.',
      );
    }
    if (text.contains('металл') || text.contains('банк')) {
      return const ResultInsights(
        itemName: 'Металлический отход',
        type: WasteType.metal,
        category: WasteCategory.recyclable,
        binColor: 'красный',
        reason: 'Металлы перерабатываются и снижают добычу новых ресурсов.',
      );
    }
    if (text.contains('орган') || text.contains('пищ')) {
      return const ResultInsights(
        itemName: 'Органический отход',
        type: WasteType.organic,
        category: WasteCategory.nonRecyclable,
        binColor: 'черный',
        reason:
            'Органика обычно не идет в сухую переработку и требует отдельного сбора.',
      );
    }

    return const ResultInsights(
      itemName: 'Неопределенный тип отхода',
      type: WasteType.unknown,
      category: WasteCategory.nonRecyclable,
      binColor: 'красный',
      reason: 'Тип не определен точно, проверьте похожие варианты вручную.',
      suggestion:
          'Похоже на пластик или комбинированную упаковку. Уточните состав по маркировке.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights(widget.analysisResult);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        title: const Text('Результат анализа'),
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
                          'Тип отхода:',
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
                            'AI-подсказка: ${insights.suggestion}',
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
                      const Text('На главную', style: TextStyle(fontSize: 18)),
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
