import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class MessagePart {
  final String text;
  MessagePart(this.text);

  Map<String, dynamic> toJson() => {'text': text};
}

class ChatContent {
  final String role;
  final List<MessagePart> parts;

  ChatContent({required this.role, required this.parts});

  Map<String, dynamic> toJson() => {
        'role': role,
        'parts': parts.map((p) => p.toJson()).toList(),
      };

  factory ChatContent.fromJson(Map<String, dynamic> json) {
    return ChatContent(
      role: json['role'],
      parts: (json['parts'] as List)
          .map((part) => MessagePart(part['text']))
          .toList(),
    );
  }
}

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final List<ChatContent> chatHistory = [];

  void setInitialContext(String initialContext) {
    chatHistory.clear();
    chatHistory
        .add(ChatContent(role: "user", parts: [MessagePart(initialContext)]));
    chatHistory.add(ChatContent(role: "model", parts: [
      MessagePart("Dạ, tôi đã rõ ạ. Bạn cần tư vấn về điện thoại nào?")
    ]));
  }

  Future<String> getResponse(String prompt) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
    );

    chatHistory.add(ChatContent(role: "user", parts: [MessagePart(prompt)]));

    final body = jsonEncode({
      "contents": chatHistory.map((c) => c.toJson()).toList(),
      "generationConfig": {
        "temperature": 0.7,
        "topP": 0.9,
        "topK": 40,
        "maxOutputTokens": 2048,
      },
      "safetySettings": [
        {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_NONE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_NONE"
        }
      ]
    });

    try {
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": apiKey,
        },
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final botReply =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

        if (botReply != null && botReply.isNotEmpty) {
          chatHistory
              .add(ChatContent(role: "model", parts: [MessagePart(botReply)]));
          return botReply;
        } else if (data["promptFeedback"]?["blockReason"] != null) {
          final blockReason = data["promptFeedback"]["blockReason"];
          if (chatHistory.isNotEmpty) chatHistory.removeLast();
          developer.log("Gemini API blocked response: $blockReason");
          return "❌ Lỗi: Yêu cầu bị chặn bởi bộ lọc an toàn: $blockReason";
        } else {
          if (chatHistory.isNotEmpty) chatHistory.removeLast();
          developer
              .log("Gemini API returned an unexpected structure: ${res.body}");
          return "❌ Lỗi API: Phản hồi không hợp lệ từ Gemini. (${res.body})";
        }
      } else {
        final err = jsonDecode(res.body);
        if (chatHistory.isNotEmpty) chatHistory.removeLast();
        developer.log(
            "Gemini API Error (${res.statusCode}): ${err['error']?['message'] ?? res.body}");
        return "❌ Lỗi API: ${err['error']?['message'] ?? res.body}";
      }
    } catch (e) {
      if (chatHistory.isNotEmpty) chatHistory.removeLast();
      developer.log("Connection/Runtime Error: $e");
      return "⚠️ Lỗi kết nối: $e";
    }
  }
}
