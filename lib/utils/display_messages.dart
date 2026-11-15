import 'package:flutter/material.dart';

void ShowMessage(BuildContext context, {String? message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? "حصل خطأ ما  "),
      backgroundColor: Colors.black,
    ),
  );
}
