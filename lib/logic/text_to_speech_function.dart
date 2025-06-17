import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class TextToSpeechFunc {
  TextToSpeechFunc(this.context);
  final BuildContext context;

  String textFile = '';
  FlutterTts flutterTts = FlutterTts();
  final ValueNotifier<bool> _isSpeakingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isSpeakingNotifier => _isSpeakingNotifier;
  String ttsErrorText = '';
  String languageCode = 'en_GB';
  bool isLoadingAudio = false;
  bool isTtsInitialized = false;
  bool isPaused = false;

  void updateText(String newText) {
    textFile = newText;
  }

  Future<void> pauseTts() async {
    await flutterTts.pause();
    _isSpeakingNotifier.value = false;
    isPaused = true;
  }
  Future<void> resumePlayback() async {
    flutterTts.setContinueHandler(() {
      isPaused = false;
    });
  }

  void setLanguageCode() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false).locale;
    languageCode = localeProvider.toString();
    debugPrint('Language code within text to speech func: $languageCode');
  }


  Future<void> initializeTts({String gender = 'female'}) async {
    flutterTts.setStartHandler(() {
      isLoadingAudio = false;
    });

    if (!isTtsInitialized) {
      setLanguageCode();
      try {
        debugPrint('Language code where it matters for tts: $languageCode');
        await flutterTts.setLanguage(languageCode);
        debugPrint('Language code as TTS initialized: $languageCode');
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.setPitch(1.0);

        List<dynamic> voices = await flutterTts.getVoices;
        debugPrint('Available voices: $voices');
        dynamic selectedVoice;
        if (Platform.isAndroid) {}
        dynamic defaultVoice = Platform.isAndroid ? {'name': 'en-gb-x-gba-local', 'locale': 'en-GB'} : {'name': 'Daniel', 'locale': 'en-GB'};

        for (var voice in voices) {
          Map<String, String> voiceMap = voice.cast<String, String>();
          String voiceName = voiceMap['name']?.toLowerCase() ?? '';

          if (languageCode == 'en') {
            selectedVoice = defaultVoice;
          } else if (voiceMap['locale'] == languageCode && voiceName.contains(gender)) {
            selectedVoice = voiceMap;
            break;
          } else if (voiceMap['locale']?.startsWith(languageCode) ?? false) {
            selectedVoice = voiceMap;
          }
        }
        await Future.delayed(const Duration(milliseconds: 100));
        if (selectedVoice != null) {
          selectedVoice = selectedVoice;
          await flutterTts.setVoice(selectedVoice);
        } else {
          selectedVoice = defaultVoice;
          await flutterTts.setVoice(defaultVoice);
        }
        isTtsInitialized = true;
        debugPrint('Value of isTtsInitialized: $isTtsInitialized');

        if (isTtsInitialized != false && _isSpeakingNotifier.value != true) {
          speakText(textFile);
        }
      } catch (e) {
        debugPrint('TTS Error: $e');
      }
    }
  }
  Future<void> speakText(String text) async {
    debugPrint('SpeakText called');
    _isSpeakingNotifier.value = true;
    int estimatedPrepTimeMs = max(text.length * 7, 600);
    await Future.delayed(Duration(milliseconds: estimatedPrepTimeMs));
    flutterTts.setCompletionHandler(() {
      _isSpeakingNotifier.value = false;
      isTtsInitialized = false;
      isPaused = false;
    });
    if (isPaused) {
      await flutterTts.speak(text);
      isPaused = false;
    } else {
      await flutterTts.speak(text);
    }
  }
}