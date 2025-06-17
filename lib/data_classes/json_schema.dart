import 'package:firebase_ai/firebase_ai.dart';

final jsonSchema = Schema.object(

    properties: {
      'response' : Schema.object(properties: {'labelText' : Schema.string()})
    }

);