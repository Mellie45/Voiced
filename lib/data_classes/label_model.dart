
class LabelModel {
  String labelText = '';

  LabelModel();

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    final responseData = json['response'] as Map<String, dynamic>?;
    return LabelModel()
      ..labelText = responseData?['labelText'] ?? '';
  }

  LabelModel copyWith({String? labelText}) {
    return LabelModel()
      ..labelText = labelText ?? this.labelText;
  }
}