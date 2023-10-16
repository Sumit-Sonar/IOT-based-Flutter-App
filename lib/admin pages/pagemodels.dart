import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/src/timestamp.dart';

class PageModel {
  final String name;
  final List<ButtonModel> buttons;

  PageModel(this.name, this.buttons, Timestamp timestamp);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'buttons': buttons.map((button) => button.toJson()).toList(),
    };
  }

  factory PageModel.fromJson(Map<String, dynamic> json) {
    final buttonsList = json['buttons'] as List<dynamic>;
    final List<ButtonModel> buttons =
        buttonsList.map((button) => ButtonModel.fromJson(button)).toList();

    return PageModel(json['name'] as String, buttons, Timestamp.now());
  }
}

class PageEntry {
  final String name;

  PageEntry(this.name);
}

class ButtonModel {
  final String label;
  final Uint8List dataToSend;

  ButtonModel(this.label, this.dataToSend);

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'dataToSend': dataToSend != null ? base64Encode(dataToSend) : null,
    };
  }

  factory ButtonModel.fromJson(Map<String, dynamic> json) {
    final dataToSendBase64 = json['dataToSend'] as String?;
    final dataToSend = dataToSendBase64 != null
        ? Uint8List.fromList(base64Decode(dataToSendBase64))
        : null;

    return ButtonModel(
      json['label'] as String,
      dataToSend!,
    );
  }
}
