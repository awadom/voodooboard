import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

@immutable
class Message {
  final String id;
  final String text;
  final Map<String, int> reactions;
  final DateTime? timestamp;

  const Message({
    required this.id,
    required this.text,
    this.reactions = const {},
    this.timestamp,
  });

  factory Message.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawReactions = data['reactions'];
    final reactions = (rawReactions is Map<String, dynamic>)
        ? rawReactions
            .map((key, value) => MapEntry(key, value is int ? value : 0))
        : <String, int>{};
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    return Message(
      id: doc.id,
      text: data['text'] as String? ?? '',
      reactions: reactions,
      timestamp: timestamp,
    );
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

  final List<String> emojiOptions = [
    '👍',
    '😂',
    '🔥',
    '❤️',
    '👀',
    '😢',
    '👏',
    '🤔',
    '💯',
    '🙌',
    '😎',
    '🎉',
    '🤯',
    '🤷',
    '💡',
    '🥹',
    '😤',
    '😭',
    '🙏',
    '🍀',
    '🤝',
    '🌟',
    '😅',
    '💥',
    '🫡',
    '🧠',
    '😈',
    '🙈',
    '📈',
    '🫶',
    '😮',
    '👊',
    '👑'
  ];

  CollectionReference<Map<String, dynamic>>? get _messagesCollection {
    if (widget.memberId == null) return null;
    return FirebaseFirestore.instance
        .collection('members')
        .doc(widget.memberId)
        .collection('messages');
  }

  String formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final formatter = DateFormat('EEE, MMM d \'at\' h:mm a');
    return formatter.format(timestamp);
  }

  Future<void> _sendMessage(String text) async {
    final collection = _messagesCollection;
    if (collection == null) return;

    await collection.add({
      'text': text,
      'reactions': {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    final collection = _messagesCollection;
    if (collection == null) return;

    final docRef = collection.doc(messageId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final reactions = Map<String, int>.from(data['reactions'] ?? {});
      reactions[emoji] = (reactions[emoji] ?? 0) + 1;

      transaction.update(docRef, {
        'reactions': reactions,
        'lastInteraction': FieldValue.serverTimestamp(),
      });
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

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

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
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Card(
                        key: ValueKey(msg.id),
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg.reactions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Wrap(
                                    spacing: 8,
                                    children:
                                        msg.reactions.entries.map((entry) {
                                      return GestureDetector(
                                        onTap: () =>
                                            _addReaction(msg.id, entry.key),
                                        child: Chip(
                                          label: Text(
                                              '${entry.key} ${entry.value}'),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              if (msg.timestamp != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(formatTimestamp(msg.timestamp)),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.emoji_emotions,
                                color: Colors.orange),
                            tooltip: 'React',
                            onPressed: () {
                              Future.delayed(Duration.zero, () {
                                _showEmojiPicker(context, msg.id);
                              });
                            },
                          ),
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
                _isIOS
                    ? CupertinoTextField(
                        controller: controller,
                        placeholder: 'Leave a message...',
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    : TextField(
                        controller: controller,
                        style: Theme.of(context).textTheme.bodyLarge,
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
