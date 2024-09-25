import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderEmail;
  String? receiverEmail;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({
    required this.senderEmail,
    required this.receiverEmail,
    required this.content,
    required this.messageType,
    required this.sentAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    senderEmail = json['senderEmail'];
    receiverEmail = json['receiverEmail'];
    content = json['content'];
    sentAt = json['sentAt'];
    messageType = MessageType.values.byName(json['messageType']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderEmail'] = senderEmail;
    data['receiverEmail'] = receiverEmail;
    data['content'] = content;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType!.name;
    return data;
  }

  toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'content': content,
      'sentAt': sentAt,
      'messageType': messageType!.name,
    };
  }
}