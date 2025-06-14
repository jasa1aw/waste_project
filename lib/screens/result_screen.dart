import 'dart:io';
import 'package:flutter/material.dart';
import 'package:razdelchik/main.dart';

class ResultScreen extends StatelessWidget {
  final String analysisResult;
  final String imagePath;

  const ResultScreen({
    Key? key, 
    required this.analysisResult,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(title: 'Раздельчик')),
            );
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
                  tag: 'image_$imagePath',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(imagePath),
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
                          analysisResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Твой вклад важен для планеты.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade700,
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
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.home),
                  label: const Text('На главную', style: TextStyle(fontSize: 18)),
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