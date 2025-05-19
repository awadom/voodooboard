class Message {
  final String content;
  final DateTime timestamp;
  final Map<String, int> reactions;

  Message({
    required this.content,
    DateTime? timestamp,
    Map<String, int>? reactions,
  })  : timestamp = timestamp ?? DateTime.now(),
        reactions = reactions ?? {};

  Map<String, dynamic> toJson() => {
        'content': content,
        'timestamp': timestamp,
        'reactions': reactions,
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      reactions: Map<String, int>.from(json['reactions'] ?? {}),
    );
  }
}
