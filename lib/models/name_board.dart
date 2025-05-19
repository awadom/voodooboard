// models/name_board.dart

import 'message.dart';

class NameBoard {
  final String name;
  final List<Message> messages;

  NameBoard({required this.name, List<Message>? messages})
    : messages = messages ?? [];

  void addMessage(Message message) {
    messages.add(message);
  }

  void deleteMessage(int index) {
    if (index >= 0 && index < messages.length) {
      messages.removeAt(index);
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory NameBoard.fromJson(Map<String, dynamic> json) {
    return NameBoard(
      name: json['name'],
      messages:
          (json['messages'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList(),
    );
  }
}
