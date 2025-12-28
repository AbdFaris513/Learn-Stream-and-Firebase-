import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuModel {
  final String name;
  final String? message;
  final int count;
  final DateTime? time; // original DateTime
  final String? timeText; // formatted string for UI

  MenuModel({required this.name, this.message, this.count = 0, this.time, this.timeText});

  /// For normal JSON (API / local)
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedTime;

    if (json['time'] != null) {
      parsedTime = DateTime.tryParse(json['time']);
    }

    return MenuModel(
      name: json['name'] ?? '',
      message: json['message'],
      count: json['count'] ?? 0,
      time: parsedTime,
      timeText: parsedTime != null ? _formatChatTime(parsedTime) : null,
    );
  }

  /// For Firestore chat menu list
  factory MenuModel.fromJsonMenuList(Map<String, dynamic> json, String userId, String receiverId) {
    DateTime? parsedTime;

    if (json['last_msg_time'] is Timestamp) {
      parsedTime = (json['last_msg_time'] as Timestamp).toDate();
    }

    return MenuModel(
      name: receiverId,
      message: json['last_message'],
      count: int.tryParse(json['unreadCounts']?[userId]?.toString() ?? '0') ?? 0,
      time: parsedTime,
      timeText: parsedTime != null ? _formatChatTime(parsedTime) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'message': message, 'count': count, 'time': time?.toIso8601String()};
  }

  /// Chat-style time formatter (WhatsApp like)
  static String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();

    if (DateUtils.isSameDay(dateTime, now)) {
      return DateFormat('hh:mm a').format(dateTime); // 10:30 AM
    }

    if (DateUtils.isSameDay(dateTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }

    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
