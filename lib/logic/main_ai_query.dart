import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wolpz/data_classes/json_schema.dart';
import '../data_classes/label_model.dart';

class MainAiQuery {
  MainAiQuery({
    required this.imageFile,
    required this.onResponseComplete,
    required this.onPaywallTrigger,
    required this.languageCode,
  });

  final String languageCode;
  final File imageFile;
  late GenerativeModel model;
  late List<SafetySetting> safetySettings;
  LabelModel? labelModel;
  String returnedText = '';

  // careful with 2.0/2.5 version names, ensure this matches your allowlist
  final String modelID = 'gemini-2.5-flash';

  final void Function(String?) onResponseComplete;
  final VoidCallback onPaywallTrigger; // Callback for when credits fail

  Future<void> initializeVertex(File? image) async {
    debugPrint('Language code passed to main ai query: $languageCode');

    // --- SECTION 1: THE GATEKEEPER ---
    try {
      // Call the lightweight function just to check/decrement credits
      await FirebaseFunctions.instance
          .httpsCallable('decrementCredit')
          .call();

      debugPrint('Credits verified and decremented. Proceeding to AI...');

    } on FirebaseFunctionsException catch (e) {
      // Capture the specific "resource-exhausted" error from the Cloud Function
      if (e.code == 'resource-exhausted') {
        debugPrint('Resource exhausted. Triggering paywall.');
        onPaywallTrigger();
        return; // STOP EXECUTION HERE
      } else {
        debugPrint('Cloud Function Error: ${e.message}');
        _showErrorToast('Account verification failed: ${e.message}');
        onResponseComplete(null);
        return; // STOP EXECUTION HERE
      }
    } catch (e) {
      debugPrint('General Network Error during credit check: $e');
      _showErrorToast('Connection error checking credits.');
      onResponseComplete(null);
      return;
    }

    // Only runs if Section 1 passed without throwing an error

    final String cleanCode = languageCode.split('_')[0].split('-')[0];
    const languageMap = {
      'en': 'English',
      'fr': 'French',
      'de': 'German',
      'es': 'Spanish',
      'el': 'Greek',
      'it': 'Italian',
      'hi': 'Hindi',
      'pa': 'Punjabi',
    };

    safetySettings = [
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high, null),
    ];

    model = FirebaseAI.vertexAI().generativeModel(
      model: modelID,
      safetySettings: safetySettings,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: jsonSchema,
        temperature: 0.4,
        maxOutputTokens: 4096,
      ),
    );

    final languageName = languageMap[cleanCode] ?? 'English';
    debugPrint('=== DEBUG: languageCode value is: "$languageCode" ===');
    final prompt = TextPart(
      'Act as an expert translator. Extract and translate all text from this image into $languageName. '
      'Ensure the "labelText" field contains only the $languageName translation.',
    );

    final imgBytes = await image?.readAsBytes();
    if (imgBytes == null || imgBytes.isEmpty) {
      debugPrint('Error: Image bytes empty');
      onResponseComplete(null);
      return;
    }

    final imagePart = InlineDataPart('image/jpeg', imgBytes);

    try {
      final response = await model.generateContent(
        [Content.multi([prompt, imagePart])],
      ).timeout(const Duration(seconds: 15));

      if (response.text != null) {
        debugPrint('Response raw: ${response.text}');
        final jsonData = jsonDecode(response.text!);
        labelModel = LabelModel.fromJson(jsonData);
        returnedText = labelModel!.labelText;

        onResponseComplete(returnedText);
      } else {
        debugPrint('Response text was null');
        onResponseComplete(null);
      }
    } catch (error) {
      debugPrint('Gemini Error: $error');
      _showErrorToast('Analysis failed: $error');
      onResponseComplete(null);
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}