// ignore_for_file: unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageModel {
  final String messageText; // Message content
  final String senderId; // ID of the sender
  final String receiverId; // ID of the receiver
  final DateTime? timestamp; // Exact time message was sent
  final String? formattedTime; // Time in readable text
  bool isSeen; // Seen status

  MessageModel({
    required this.messageText,
    required this.senderId,
    required this.receiverId,
    this.timestamp,
    this.formattedTime,
    this.isSeen = false,
  });

  // ✅ Format time based on current date
  static String _formatTime(DateTime time) {
    final now = DateTime.now();

    if (time.year == now.year && time.month == now.month && time.day == now.day) {
      return DateFormat.jm().format(time); // Today → 10:30 AM
    } else if (time.year == now.year && time.month == now.month && time.day == now.day - 1) {
      return "Yesterday";
    } else if (time.year == now.year) {
      return DateFormat.MMMd().format(time); // Dec 28
    } else {
      return DateFormat.yMMMd().format(time); // Dec 28, 2024
    }
  }

  // ✅ Firestore → Model
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final Timestamp? ts = json['timestamp'];
    final DateTime? dateTime = ts?.toDate();

    return MessageModel(
      messageText: json['messageText'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      timestamp: dateTime,
      formattedTime: dateTime != null ? _formatTime(dateTime) : null,
      isSeen: json['isSeen'] ?? false,
    );
  }

  // ✅ Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'messageText': messageText,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'isSeen': isSeen,
    };
  }
}
