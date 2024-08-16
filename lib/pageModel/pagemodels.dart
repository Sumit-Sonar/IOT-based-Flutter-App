import 'dart:convert';
import 'dart:typed_data';


class PageModel {
  final String name;
  final List<ButtonModel> buttons;
  String panelHeading1;
  String panelHeading2; 

  PageModel(
    this.name,
    this.buttons,
    this.panelHeading1,
    this.panelHeading2, // Include panelHeading2 in the constructor
  );

  // Factory constructor to create a PageModel with only one panel heading
  factory PageModel.withSinglePanelHeading(
    String name,
    List<ButtonModel> buttons,
    String panelHeading1, String s,
  ) {
    return PageModel(
      name,
      buttons,
      panelHeading1,
      '', // Set panelHeading2 to an empty string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'buttons': buttons.map((button) => button.toJson()).toList(),
      'panelHeading1': panelHeading1, // Include panelHeading1
      'panelHeading2': panelHeading2, // Include panelHeading2
    };
  }

  factory PageModel.fromJson(Map<String, dynamic> json) {
    final buttonsList = json['buttons'] as List<dynamic>;
    final List<ButtonModel> buttons =
        buttonsList.map((button) => ButtonModel.fromJson(button)).toList();

    return PageModel(
      json['name'] as String,
      buttons,
      json['panelHeading1'] as String, // Retrieve panelHeading1
      json['panelHeading2'] as String, // Retrieve panelHeading2
    );
  }
}

class ButtonModel {
  final String label;
  final Uint8List dataToSend;

  ButtonModel(this.label, this.dataToSend);

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      // ignore: unnecessary_null_comparison
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