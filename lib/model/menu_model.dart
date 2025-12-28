import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuModel {
  final String name;
  final String? message;
  final int? count;
  final DateTime? time; // original DateTime
  final String? timeText; // formatted string for UI

  MenuModel({required this.name, this.message, this.count, this.time, this.timeText});

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final DateTime parsedTime = DateTime.parse(json['time']);

    return MenuModel(
      name: json['name'] ?? '',
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      time: parsedTime,
      timeText: _formatChatTime(parsedTime),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'message': message, 'count': count, 'time': time!.toIso8601String()};
  }

  /// Chat-style time formatter
  static String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();

    if (DateUtils.isSameDay(dateTime, now)) {
      return DateFormat('hh:mm a').format(dateTime); // 10:00 AM
    }

    if (DateUtils.isSameDay(dateTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }

    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
