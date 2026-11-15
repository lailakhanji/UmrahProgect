import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'data/guide_model.dart';

class GuideDetailScreen extends StatefulWidget {
  final GuideModel guide;
  final int stepNumber;
  final int totalSteps;

  const GuideDetailScreen({
    super.key,
    required this.guide,
    required this.stepNumber,
    required this.totalSteps,
  });

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  static const Color primaryGreen = Color(0xff186442);

  bool isPlaying = false;
  bool isTtsReady = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {

      await _flutterTts.awaitSpeakCompletion(true);


      final languages = await _flutterTts.getLanguages;

      print('AVAILABLE LANGUAGES: $languages');

      String selectedLanguage = 'ar-SA';

      if (languages is List) {
        final hasArabicSaudi = languages.any(
          (language) => language.toString().toLowerCase() == 'ar-sa',
        );

        final hasArabic = languages.any(
          (language) => language.toString().toLowerCase().startsWith('ar'),
        );

        if (hasArabicSaudi) {
          selectedLanguage = 'ar-SA';
        } else if (hasArabic) {
          final arabicLanguage = languages.firstWhere(
            (language) => language.toString().toLowerCase().startsWith('ar'),
          );

          selectedLanguage = arabicLanguage.toString();
        }
      }

      print('SELECTED TTS LANGUAGE: $selectedLanguage');

      await _flutterTts.setLanguage(selectedLanguage);


      await _flutterTts.setSpeechRate(0.45);

      await _flutterTts.setPitch(1.0);


      await _flutterTts.setVolume(1.0);

      if (Theme.of(context).platform == TargetPlatform.android) {
        final engines = await _flutterTts.getEngines;

        print('AVAILABLE TTS ENGINES: $engines');

        if (engines is List && engines.isNotEmpty) {
          print('CURRENT TTS ENGINE WILL USE DEVICE DEFAULT');
        }
      }

      _flutterTts.setStartHandler(() {
        print('TTS STARTED');

        if (!mounted) return;

        setState(() {
          isPlaying = true;
        });
      });

      _flutterTts.setCompletionHandler(() {
        print('TTS COMPLETED');

        if (!mounted) return;

        setState(() {
          isPlaying = false;
        });
      });

      _flutterTts.setCancelHandler(() {
        print('TTS CANCELLED');

        if (!mounted) return;

        setState(() {
          isPlaying = false;
        });
      });

      _flutterTts.setErrorHandler((message) {
        print('TTS ERROR: $message');

        if (!mounted) return;

        setState(() {
          isPlaying = false;
        });
      });

      if (!mounted) return;

      setState(() {
        isTtsReady = true;
      });

      print('TTS READY');
    } catch (e) {
      print('TTS INIT ERROR: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    try {
      if (!isTtsReady) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('جاري تجهيز خدمة الصوت')));

        return;
      }

      if (isPlaying) {
        await _flutterTts.stop();

        if (!mounted) return;

        setState(() {
          isPlaying = false;
        });

        return;
      }


      final title = widget.guide.title.trim();


      final description = widget.guide.description.trim();

      final textToSpeak = [
        if (title.isNotEmpty) title,
        if (description.isNotEmpty) description,
      ].join('. ');

      if (textToSpeak.isEmpty) {
        return;
      }

      print('TEXT TO SPEAK: $textToSpeak');

      final result = await _flutterTts.speak(textToSpeak);

      print('TTS SPEAK RESULT: $result');
    } catch (e) {
      print('TTS ERROR: $e');

      if (!mounted) return;

      setState(() {
        isPlaying = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تشغيل الصوت: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text(
                      'الخطوة ${widget.stepNumber} من ${widget.totalSteps}',
                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.guide.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (widget.guide.imageUrl != null &&
                        widget.guide.imageUrl!.isNotEmpty)
                      _buildImage(),

                    const SizedBox(height: 20),

                    const Text(
                      'شرح الخطوة',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.guide.description,
                      style: const TextStyle(fontSize: 16, height: 1.7),
                    ),

                    const SizedBox(height: 20),

                    if (widget.guide.title.trim().isNotEmpty ||
                        widget.guide.description.trim().isNotEmpty)
                      _buildAudioButton(),

                    const SizedBox(height: 30),

                    _buildCompleteButton(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_ios),
          ),

          const Spacer(),

          const Text(
            'دليل العمرة',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        widget.guide.imageUrl!,
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: 210,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported_outlined),
          );
        },
      ),
    );
  }

  Widget _buildAudioButton() {
    return GestureDetector(
      onTap: _toggleAudio,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xffF3F8F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: primaryGreen,
              ),
              child: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                isPlaying ? 'إيقاف الصوت' : 'استمع إلى الشرح',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Icon(Icons.volume_up_outlined, color: primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, true);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text(
        'إكمال الخطوة',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}
