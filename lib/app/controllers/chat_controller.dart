// D:\phone_advisor_chat\lib\app\controllers\chat_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final phones = [].obs;
  final gemini = GeminiService(); // Khởi tạo GeminiService
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPhonesAndSetContext(); // Gọi hàm mới này
  }

  Future<void> loadPhonesAndSetContext() async {
    final jsonData = await rootBundle.loadString('assets/phones.json');
    phones.value = jsonDecode(jsonData);

    // Thiết lập context ban đầu cho GeminiService
    final initialContext = """
Bạn là nhân viên tư vấn điện thoại của Thế Giới Di Động. Bạn chỉ tư vấn các thông tin dựa trên dữ liệu điện thoại mà tôi cung cấp.
Nếu người dùng hỏi về điện thoại không có trong danh sách, hãy nói rằng bạn không có thông tin về điện thoại đó và đề xuất các mẫu có sẵn.
Dưới đây là dữ liệu điện thoại mà bạn hiện có:
${jsonEncode(phones)}

Hãy trả lời bằng tiếng Việt ngắn gọn, súc tích, tự nhiên và lịch sự trong giao tiếp, tập trung vào việc tư vấn sản phẩm.
Không giới thiệu bản thân ở mỗi câu trả lời.
""";
    gemini.setInitialContext(initialContext);

    // Thêm tin nhắn chào mừng ban đầu từ bot (tùy chọn)
    messages.add(ChatMessage(
        role: "assistant",
        text:
            "Chào bạn, tôi là tư vấn viên của Thế Giới Di Động. Tôi có thể giúp gì cho bạn về điện thoại?"));
  }

  Future<void> sendMessage(String text) async {
    isLoading.value = true;
    messages.add(ChatMessage(
        role: "user", text: text)); // Thêm tin nhắn người dùng vào UI

    // Gọi Gemini API, không cần gửi lại context nữa
    final reply = await gemini.getResponse(text);
    messages.add(ChatMessage(
        role: "assistant", text: reply)); // Thêm phản hồi của bot vào UI
    isLoading.value = false;
  }
}
