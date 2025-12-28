// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_stream_and_firebase/controller/chat_controller.dart';
import 'package:learn_stream_and_firebase/screen/chat_screen.dart';

class ChatMenu extends StatefulWidget {
  const ChatMenu({super.key});

  @override
  State<ChatMenu> createState() => _ChatMenuState();
}

class _ChatMenuState extends State<ChatMenu> {
  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());

    @override
    void dispose() {
      chatController.idController.dispose();
      super.dispose();
    }

    void openIdDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Chat ID",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0288D1), // sky blue
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: chatController.idController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "@abd_faris",
                      filled: true,
                      fillColor: const Color(0xFFE1F5FE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          chatController.idController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03A9F4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await chatController.addNewContact(context);
                          Navigator.pop(context);
                        },
                        child: const Text("Add", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Chat menu')),
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: chatController.menuList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChattingScreenUI()),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 196, 219, 231),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chatController.menuList[index].name,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  chatController.menuList[index].message ?? '',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            if (chatController.menuList[index].count != null &&
                                chatController.menuList[index].count != 0) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      chatController.menuList[index].count.toString(),
                                      style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    chatController.menuList[index].timeText ?? '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF03A9F4),
          onPressed: openIdDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
