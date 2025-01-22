class DialogueMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  DialogueMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}
