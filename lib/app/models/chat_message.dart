class ChatMessage {
  final String role; // "user" hoặc "assistant"
  final String text;
  final String? imageUrl;
  final String? link;

  ChatMessage({
    required this.role,
    required this.text,
    this.imageUrl,
    this.link,
  });
}
