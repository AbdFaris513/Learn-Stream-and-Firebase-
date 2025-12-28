import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

class ChattingScreenUI extends StatefulWidget {
  const ChattingScreenUI({super.key});

  @override
  State<ChattingScreenUI> createState() => _ChattingScreenUIState();
}

class _ChattingScreenUIState extends State<ChattingScreenUI> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmoji = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faris")),
      body: Column(
        children: [
          /// 🔹 Messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                _Bubble(text: "Hi 👋", isMe: false),
                _Bubble(text: "Hello 😄", isMe: true),
              ],
            ),
          ),

          /// 🔹 Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined),
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

                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onTap: () {
                      if (_showEmoji) {
                        setState(() => _showEmoji = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        // TODO: Send message logic here
                        print("Sending: ${_controller.text}");
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
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                textEditingController: _controller,
                onEmojiSelected: (Category? category, Emoji emoji) {
                  // Emoji is automatically added to the text controller
                  // You can add additional logic here if needed
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
                  height: 250,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax:
                        28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                    columns: 7,
                    backgroundColor: Colors.white,
                  ),
                  skinToneConfig: const SkinToneConfig(),
                  categoryViewConfig: const CategoryViewConfig(
                    indicatorColor: Colors.green,
                    iconColorSelected: Colors.green,
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                  searchViewConfig: const SearchViewConfig(backgroundColor: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _Bubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.green.shade200 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
