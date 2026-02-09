
class LabelModel {
  String labelText = '';

  LabelModel();

  factory LabelModel.fromJson(Map<String, dynamic> json) {

    return LabelModel()
      ..labelText = json['labelText'] as String ?? '';
  }

  LabelModel copyWith({String? labelText}) {
    return LabelModel()
      ..labelText = labelText ?? this.labelText;
  }
}