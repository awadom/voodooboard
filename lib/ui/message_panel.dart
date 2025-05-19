import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/theme.dart';

class Message {
  final String id;
  final String text;
  final Map<String, int> reactions;

  Message(this.id, this.text, [Map<String, int>? reactions])
      : reactions = reactions ?? {};

  factory Message.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final reactions = (data['reactions'] as Map<String, dynamic>?)?.map(
      (key, value) => MapEntry(key, value as int),
    );
    return Message(doc.id, data['text'] as String, reactions);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'reactions': reactions,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class MessagePanel extends StatefulWidget {
  final String? memberId;

  const MessagePanel({super.key, required this.memberId});

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  final TextEditingController controller = TextEditingController();
  final List<String> emojiOptions = ['👍', '😂', '🔥', '❤️', '👀', '😢'];

  CollectionReference<Map<String, dynamic>>? get _messagesCollection {
    if (widget.memberId == null) return null;
    return FirebaseFirestore.instance
        .collection('members')
        .doc(widget.memberId)
        .collection('messages');
  }

  void _sendMessage(String text) async {
    final collection = _messagesCollection;
    if (collection == null) return;

    await collection.add({
      'text': text,
      'reactions': {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _deleteMessage(String messageId) async {
    final collection = _messagesCollection;
    if (collection == null) return;

    await collection.doc(messageId).delete();
  }

  void _addReaction(String messageId, String emoji) async {
    final collection = _messagesCollection;
    if (collection == null) return;

    final docRef = collection.doc(messageId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final reactions = Map<String, int>.from(data['reactions'] ?? {});
      reactions[emoji] = (reactions[emoji] ?? 0) + 1;

      transaction.update(docRef, {'reactions': reactions});
    });
  }

  void _showEmojiPicker(BuildContext context, String messageId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: emojiOptions.map((emoji) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _addReaction(messageId, emoji);
              },
              child: CircleAvatar(
                radius: 24,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.memberId == null) {
      return const Center(
        child: Text(
          'Select a member to view or leave a message.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection!
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs
                    .map((doc) => Message.fromDoc(doc))
                    .toList();

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSmall),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingSmall,
                        ),
                        title: Text(msg.text),
                        subtitle: msg.reactions.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 8,
                                  children: msg.reactions.entries.map(
                                    (entry) {
                                      return Chip(
                                        label: Text(
                                          '${entry.key} ${entry.value}',
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              )
                            : null,
                        trailing: Wrap(
                          direction: Axis.vertical,
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              tooltip: 'Delete',
                              onPressed: () => _deleteMessage(msg.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.emoji_emotions,
                                  color: Colors.orange),
                              tooltip: 'React',
                              onPressed: () {
                                Future.delayed(Duration.zero, () {
                                  _showEmojiPicker(context, msg.id);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: AppTheme.screenPadding,
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge, // Adapts text color to theme
                  decoration: const InputDecoration(
                    labelText: 'Leave a message...',
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final msg = controller.text.trim();
                      if (msg.isNotEmpty) {
                        _sendMessage(msg);
                        controller.clear();
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Post Message'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
