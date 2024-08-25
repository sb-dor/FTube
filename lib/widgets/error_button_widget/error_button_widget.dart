import 'package:flutter/material.dart';

class ErrorButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const ErrorButtonWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.red),
        elevation: const WidgetStatePropertyAll(3),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
            style: BorderStyle.none,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      onPressed: onTap,
      child: const Text(
        "Refresh page",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
