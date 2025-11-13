import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../controllers/chat_controller.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController inputCtrl = TextEditingController();

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Tư vấn điện thoại",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: theme.primaryColor,
          elevation: 4, // Thêm đổ bóng cho App Bar
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    reverse: false,
                    itemCount: controller.messages.length,
                    itemBuilder: (context, i) {
                      final msg = controller.messages[i];
                      final isUser = msg.role == "user";

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isUser ? 12 : 0),
                              topRight: Radius.circular(isUser ? 0 : 12),
                              bottomLeft: const Radius.circular(12),
                              bottomRight: const Radius.circular(12),
                            ),
                          ),
                          margin: EdgeInsets.only(
                            left: isUser ? Get.width * 0.2 : 10,
                            right: isUser ? 10 : Get.width * 0.2,
                            top: 5,
                            bottom: 5,
                          ),
                          color: isUser
                              ? theme.primaryColor.withOpacity(0.8)
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    color:
                                        isUser ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                if (msg.imageUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: msg.imageUrl!,
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                if (msg.link != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: InkWell(
                                      onTap: () {
                                        print("Mở link: ${msg.link}");
                                      },
                                      child: Text(
                                        "Xem thêm: ${msg.link!}",
                                        style: TextStyle(
                                          color: isUser
                                              ? Colors.white70
                                              : theme.primaryColor,
                                          decoration: TextDecoration.underline,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary,
                        child: const Icon(Icons.android, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballPulseSync,
                          colors: [theme.primaryColor],
                          strokeWidth: 2,
                          backgroundColor: Colors.transparent,
                          pathBackgroundColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Advisor đang suy nghĩ...",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inputCtrl,
                        decoration: InputDecoration(
                          hintText: "Nhập câu hỏi...",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          final text = inputCtrl.text.trim();
                          if (text.isNotEmpty) {
                            controller.sendMessage(text);
                            inputCtrl.clear();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
