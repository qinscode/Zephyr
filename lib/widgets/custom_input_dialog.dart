// lib/widgets/custom_input_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomInputDialog extends StatelessWidget {
  final String title;
  final String placeholder;
  final String cancelText;
  final String confirmText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const CustomInputDialog({
    super.key,
    required this.title,
    required this.placeholder,
    this.cancelText = 'Cancel',
    this.confirmText = 'OK',
    required this.controller,
    this.validator,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 17,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: validator,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 0.5,
              color: Colors.grey[300],
            ),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: onCancel,
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 50,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: onConfirm,
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String placeholder,
    String? cancelText,
    String? confirmText,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomInputDialog(
        title: title,
        placeholder: placeholder,
        cancelText: cancelText ?? 'Cancel',
        confirmText: confirmText ?? 'OK',
        controller: controller,
        validator: validator,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }
}