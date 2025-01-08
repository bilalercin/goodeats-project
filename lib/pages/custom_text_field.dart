import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? labelText;
  final bool obscureText;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final bool? expands;
  final String? hintText;
  final int? maxLines;
  const CustomTextField({
    super.key,
    this.labelText,
    required this.controller,
    this.obscureText = false,
    this.onTap,
    this.expands,
    this.hintText,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        maxLines: expands == true ? null : (maxLines ?? 1),
        expands: expands ?? false,
        controller: controller,
        obscureText: obscureText,
        readOnly: onTap != null,
        textAlignVertical: TextAlignVertical.top,
        textAlign: TextAlign.start,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.green),
          ),
        ));
  }
}