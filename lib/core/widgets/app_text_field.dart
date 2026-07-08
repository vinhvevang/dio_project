import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ô nhập dùng chung cho toàn app: có nút "x" xóa nhanh nội dung (chỉ hiện khi
/// có chữ), và hỗ trợ [nextFocus]/[onSubmit] để nhấn Enter/Next tự chuyển
/// sang field kế tiếp hoặc submit luôn ở field cuối - không cần tự viết
/// FocusScope.of(context).requestFocus(...) lặp lại ở từng nơi gọi.
class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  // final bool isSubmit;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final bool autofocus;

  /// Nếu có: nhấn Enter/Next tự chuyển focus sang field này.
  final FocusNode? nextFocus;

  /// Nếu có (và [nextFocus] null - tức field cuối cùng): nhấn Enter/Done sẽ
  /// ẩn bàn phím rồi gọi callback này (submit).
  final VoidCallback? onSubmit;

  const AppTextFormField({
    super.key,
    required this.controller,
    required this.label,
    // this.isSubmit = false,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.nextFocus,
    this.onSubmit,
    this.autovalidateMode,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextInputAction =
        textInputAction ??
        (nextFocus != null
            ? TextInputAction.next
            : (onSubmit != null ? TextInputAction.done : null));

    void handleEditingComplete() {
      if (nextFocus != null) {
        FocusScope.of(context).requestFocus(nextFocus);
      } else if (onSubmit != null) {
        FocusScope.of(context).unfocus();
        onSubmit!();
      }
      onEditingComplete?.call();
    }

    Widget? buildSuffixIcon() {
      if (suffixIcon != null) return suffixIcon;
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              controller.clear();
              onChanged?.call('');
            },
          );
        },
      );
    }

    return TextFormField(
      // autovalidateMode: isSubmit ? AutovalidateMode.onUserInteraction :  AutovalidateMode.disabled,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: effectiveTextInputAction,
      onChanged: onChanged,
      onEditingComplete:
          (nextFocus != null || onSubmit != null || onEditingComplete != null)
          ? handleEditingComplete
          : null,
      autovalidateMode: autovalidateMode,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: buildSuffixIcon(),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
