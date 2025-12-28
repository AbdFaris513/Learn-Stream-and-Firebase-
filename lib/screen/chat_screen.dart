// ignore_for_file: must_be_immutable

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_stream_and_firebase/controller/chat_controller.dart';
import 'package:learn_stream_and_firebase/model/menu_model.dart';
import 'package:learn_stream_and_firebase/model/message_model.dart';

class ChattingScreenUI extends StatefulWidget {
  MenuModel reciverData;
  ChattingScreenUI({super.key, required this.reciverData});

  @override
  State<ChattingScreenUI> createState() => _ChattingScreenUIState();
}

class _ChattingScreenUIState extends State<ChattingScreenUI> {
  final ChatController _chatController = Get.put(ChatController());
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmoji = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String capitalizeSmart(String text) {
    if (text.isEmpty) return text;

    // 1️⃣ Replace underscore with space
    String result = text.replaceAll('_', ' ');

    // 2️⃣ Insert space before camelCase letters
    result = result.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // 3️⃣ Remove extra spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 4️⃣ Capitalize each word
    return result
        .split(' ')
        .map(
          (word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF161B22),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  capitalizeSmart(widget.reciverData.name)[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    capitalizeSmart(widget.reciverData.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Online',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.white70, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.white70, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          /// 🔹 Messages area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D1117), Color(0xFF0D1117).withOpacity(0.95)],
                ),
              ),
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _chatController.messagesList.length,
                  itemBuilder: (context, index) {
                    return _MessageBubble(
                      text: _chatController.messagesList[index].messageText,
                      isMe:
                          (_chatController.messagesList[index].senderId ==
                          _chatController.currentUser.id),
                    );
                  },
                ),
              ),
            ),
          ),

          /// 🔹 Input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF1F2937), shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      _showEmoji ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined,
                      color: const Color(0xFF667EEA),
                      size: 24,
                    ),
                    onPressed: () {
                      if (_showEmoji) {
                        // Show keyboard
                        _focusNode.requestFocus();
                      } else {
                        // Show emoji picker
                        FocusScope.of(context).unfocus();
                      }
                      setState(() => _showEmoji = !_showEmoji);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF374151), width: 1),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = false);
                        }
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    onPressed: () async {
                      if (_controller.text.trim().isNotEmpty) {
                        final MessageModel message = MessageModel(
                          messageText: _controller.text.trim(),
                          senderId: _chatController.currentUser.id,
                          receiverId: widget.reciverData.name,
                        );
                        await _chatController.sendMessage(message);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 Emoji Picker
          Offstage(
            offstage: !_showEmoji,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                border: Border(top: BorderSide(color: const Color(0xFF374151), width: 1)),
              ),
              child: EmojiPicker(
                textEditingController: _controller,
                onEmojiSelected: (Category? category, Emoji emoji) {
                  // Emoji is automatically added to the text controller
                },
                onBackspacePressed: () {
                  // Handle backspace
                  _controller
                    ..text = _controller.text.characters.skipLast(1).toString()
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                },
                config: Config(
                  height: 280,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax:
                        32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                    columns: 8,
                    backgroundColor: const Color(0xFF161B22),
                  ),
                  skinToneConfig: const SkinToneConfig(dialogBackgroundColor: Color(0xFF1F2937)),
                  categoryViewConfig: const CategoryViewConfig(
                    indicatorColor: Color(0xFF667EEA),
                    iconColorSelected: Color(0xFF667EEA),
                    iconColor: Color(0xFF6B7280),
                    backgroundColor: Color(0xFF161B22),
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                  searchViewConfig: const SearchViewConfig(
                    backgroundColor: Color(0xFF1F2937),
                    buttonIconColor: Color(0xFF667EEA),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isMe
                  ? LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMe ? null : const Color(0xFF1F2937),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: isMe ? Color(0xFF667EEA).withOpacity(0.3) : Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
