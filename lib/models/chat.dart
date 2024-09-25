import 'package:milan_hackathon/models/message.dart';

class Chat {
  List<String>? participants;
  List<Message>? messages;

  Chat({
    required this.participants,
    required this.messages,
  });

  Chat.fromJson(Map<String, dynamic> json) {
    participants = List<String>.from(json['participants']);
    messages = List.from(json['messages']).map((m) => Message.fromJson(m)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['participants'] = participants;
    data['messages'] = messages?.map((m) => m.toJson()).toList() ?? [];
    return data;
  }

  static fromMap(Map<String, dynamic> data) {
    return Chat.fromJson(data);
  }
}