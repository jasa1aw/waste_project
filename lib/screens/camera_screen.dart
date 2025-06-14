import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:razdelchik/services/trash_analysis_service.dart';
import 'package:razdelchik/screens/result_screen.dart';
import 'package:razdelchik/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  final TrashAnalysisService _analysisService = TrashAnalysisService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Камера не найдена';
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Ошибка инициализации камеры: $e';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Камера не инициализирована')),
      );
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      if (!mounted) return;

      final savedPath = await _analysisService.saveImageToLocal(photo.path);
      if (!mounted) return;

      final result = await _analysisService.analyzeImage(savedPath);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imagePath: savedPath,
            analysisResult: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при съемке: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;
      if (!mounted) return;

      final savedPath = await _analysisService.saveImageToLocal(image.path);
      if (!mounted) return;

      final result = await _analysisService.analyzeImage(savedPath);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imagePath: savedPath,
            analysisResult: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе изображения: $e')),
      );
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final savedPath = await _analysisService.saveImageToLocal(pickedFile.path);
        final result = await _analysisService.analyzeImage(savedPath);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                analysisResult: result,
                imagePath: savedPath,
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Камера')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage ?? 'Произошла ошибка'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Выбрать из галереи'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.green.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Сделай фото или выбери из галереи, чтобы узнать, как правильно утилизировать отходы!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _getImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        label: Text('Сделать фото', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _getImage(ImageSource.gallery),
                        icon: Icon(Icons.photo_library, color: Colors.white),
                        label: Text('Выбрать из галереи', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 