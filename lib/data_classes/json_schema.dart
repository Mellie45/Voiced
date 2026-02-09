
import 'package:firebase_ai/firebase_ai.dart';

final jsonSchema = Schema.object(
  properties: {
    'labelText': Schema.string(description: 'The translated text from the image'),
  },
  optionalProperties: [],
);