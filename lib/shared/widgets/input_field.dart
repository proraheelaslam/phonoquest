import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black.withOpacity(.32), fontSize: 14),
      border: InputBorder.none,
      prefixIcon: Icon(icon, size: 20, color: Colors.black.withOpacity(.42)),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (validator == null) {
      return Container(
        constraints: const BoxConstraints(minHeight: 54),
        decoration: BoxDecoration(color: AppTheme.softGrey, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onFieldSubmitted,
          decoration: _decoration(),
        ),
      );
    }

    return FormField<String>(
      initialValue: controller?.text ?? '',
      validator: validator,
      builder: (FormFieldState<String> field) {
        void syncFromController(String v) {
          if (field.value != v) {
            field.didChange(v);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.softGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    onSubmitted: onFieldSubmitted,
                    onChanged: syncFromController,
                    decoration: _decoration(),
                  ),
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4, right: 4),
                child: Text(
                  field.errorText ?? '',
                  style: TextStyle(fontSize: 10.5, color: Colors.red.shade700, height: 1.25),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }
}
