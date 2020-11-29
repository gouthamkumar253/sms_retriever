import 'dart:convert';

class CustomMessagesList {
  CustomMessagesList({
    this.customMessages,
  });

  final List<CustomMessage> customMessages;

  factory CustomMessagesList.fromRawJson(String str) =>
      CustomMessagesList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomMessagesList.fromJson(Map<String, dynamic> json) =>
      CustomMessagesList(
        customMessages: json["custom_messages"] == null
            ? null
            : List<CustomMessage>.from(
                json["custom_messages"].map((x) => CustomMessage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "custom_messages": customMessages == null
            ? null
            : List<dynamic>.from(customMessages.map((x) => x.toJson())),
      };
}

class CustomMessage {
  CustomMessage({
    this.smsMessage,
    this.contactName,
    this.tag,
  });

  final CustomSmsMessage smsMessage;
  final String contactName;
  final String tag;

  factory CustomMessage.fromRawJson(String str) =>
      CustomMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomMessage.fromJson(Map<String, dynamic> json) => CustomMessage(
        smsMessage: json['sms_message'] == null
            ? null
            : CustomSmsMessage.fromJson(json['sms_message']),
        contactName: json['contact_name'] == null ? null : json['contact_name'],
        tag: json['tag'] == null ? null : json['tag'],
      );

  Map<String, dynamic> toJson() => {
        'sms_message': smsMessage == null ? null : smsMessage.toJson(),
        'contact_name': contactName == null ? null : contactName,
        'tag': tag == null ? null : tag,
      };

  CustomMessage copyWith(
      {CustomSmsMessage message, String contactName, String tag}) {
    return CustomMessage(
      smsMessage: message ?? this.smsMessage,
      contactName: contactName ?? this.contactName,
      tag: tag ?? this.tag,
    );
  }
}

class CustomSmsMessage {
  CustomSmsMessage({
    this.id,
    this.address,
    this.body,
    this.date,
    this.dateSent,
  });

  final int id;
  final String address;
  final String body;
  final DateTime date;
  final DateTime dateSent;

  factory CustomSmsMessage.fromRawJson(String str) =>
      CustomSmsMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomSmsMessage.fromJson(Map<String, dynamic> json) =>
      CustomSmsMessage(
        id: json['id'] == null ? null : json['id'],
        address: json['address'] == null ? null : json['address'],
        body: json['body'] == null ? null : json['body'],
        date: json['date'] == null ? null : DateTime.parse(json['date']),
        dateSent: json['date_sent'] == null
            ? null
            : DateTime.parse(json['date_sent']),
      );

  Map<String, dynamic> toJson() => {
        'id': id == null ? null : id,
        'address': address == null ? null : address,
        'body': body == null ? null : body,
        'date': date == null ? null : date.toIso8601String(),
        'date_sent': dateSent == null ? null : dateSent.toIso8601String(),
      };
}
