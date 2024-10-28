// lib/widgets/custom_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomPickerDialog extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelect;
  final RelativeRect position;

  const CustomPickerDialog({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          left: screenSize.width - 280, // 距离右边缘固定距离
          top: position.top, // 与按钮垂直对齐
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias, // 确保圆角有效
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((option) {
                  final isSelected = option == selectedValue;
                  return InkWell(
                    onTap: () {
                      onSelect(option);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8F2FF) : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: option != options.last
                                ? Colors.grey.withOpacity(0.1)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 17,
                              color: isSelected ? Colors.blue : Colors.black,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              CupertinoIcons.checkmark,
                              color: Colors.blue,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelect,
    required GlobalKey buttonKey,
  }) {
    // 获取按钮的位置和大小
    final RenderBox button = buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero);

    // 计算对话框的位置
    final position = RelativeRect.fromLTRB(
      0,
      buttonPosition.dy - 10, // 稍微向上偏移以对齐文本
      0,
      0,
    );

    return showDialog<T>(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      builder: (BuildContext context) => CustomPickerDialog(
        options: options,
        selectedValue: selectedValue,
        onSelect: onSelect,
        position: position,
      ),
    );
  }
}