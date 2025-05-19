// services/voodoo_service.dart

import '../models/name_board.dart';
import '../models/message.dart';

class VoodooService {
  final Map<String, NameBoard> _boards = {};

  List<String> get allNames => _boards.keys.toList()..sort();

  NameBoard? getBoard(String name) {
    return _boards[name];
  }

  void addName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _boards.containsKey(trimmed)) return;
    _boards[trimmed] = NameBoard(name: trimmed);
  }

  void addMessage(String name, String content) {
    if (!_boards.containsKey(name)) return;
    _boards[name]?.addMessage(Message(content: content));
  }

  void deleteMessage(String name, int index) {
    _boards[name]?.deleteMessage(index);
  }

  List<Message> getMessagesFor(String name) {
    return _boards[name]?.messages ?? [];
  }

  bool nameExists(String name) => _boards.containsKey(name);
}
