import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:voiced/data_classes/json_schema.dart';
import '../data_classes/label_model.dart';

class MainAiQuery {
  MainAiQuery({required this.imageFile, required this.onResponseComplete, required this.languageCode});

  final String languageCode;
  final File imageFile;
  late GenerativeModel model;
  late List<SafetySetting> safetySettings;
  LabelModel? labelModel;
  String returnedText = '';
  final String modelID =  'gemini-2.0-flash';
  final void Function(String?) onResponseComplete;

  Future initializeVertex(File? image) async {
    debugPrint('Language code passed to main ai query: $languageCode');

    const languageCodeToName = {
      'en_GB': 'English',
      'fr-FR': 'French',
      'de-DE': 'German',
      'es-ES': 'Spanish',
      'el-GR': 'Greek',
      'it-IT': 'Italian',
      'hi-IN': 'Hindi',
      'le-PK': 'Punjabi',
    };

    safetySettings = [
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high, null),
    ];
    model = FirebaseAI.vertexAI().generativeModel(model: modelID,
      safetySettings: safetySettings,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json', responseSchema: jsonSchema,
      temperature: 0.0,
      maxOutputTokens: 400,)
    );
    final languageName = languageCodeToName[languageCode] ?? 'English';
    final prompt = TextPart(
      'Extract the text from this image. Translate to text to "$languageName".'
      ,
    );
    final img = await image?.readAsBytes();
    if (img!.isEmpty) {
      debugPrint('Error: img from provider is empty. imgType is: $img');
    }
    final imagePart = InlineDataPart('image/jpeg', img);
    try {
      final response = await model.generateContent(
        [Content.multi([prompt, imagePart])
        ],
      ).timeout(const Duration(seconds: 8));
      if (response.text != null) {
        final jsonData = jsonDecode(response.text!);
        debugPrint('Response as JSON: $jsonData');
        labelModel = LabelModel.fromJson(jsonData);
        returnedText = labelModel!.labelText;
        debugPrint('Response: ${response.text}');
        if (labelModel?.labelText != response.text) {
        }
        onResponseComplete(returnedText);
      } else {
        debugPrint('Response after labelText set: ${response.text}');
      }
    } catch (error) {
      debugPrint('Error: Somethings wrong with the response: $error');
      Fluttertoast.showToast(
        msg: 'We have a problem: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
