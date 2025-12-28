import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  SnackBarType type = SnackBarType.success,
  Duration duration = const Duration(seconds: 2),
}) {
  Color backgroundColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green.shade400;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange.shade400;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red.shade400;
      break;
  }

  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: duration,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

enum SnackBarType { success, warning, error }
