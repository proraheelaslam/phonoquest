import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Same validation pattern as [InputField]: fixed-height pill, error text **below** the pill (no growth inside the field).
class LoginValidatedField extends StatelessWidget {
  const LoginValidatedField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color.fromRGBO(155, 163, 175, 1),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.35),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: prefixIcon,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 60,
        minHeight: 54,
      ),
      suffixIcon: suffix,
      suffixIconColor: const Color(0xFF59C7C2),
      filled: true,
      fillColor: const Color.fromRGBO(243, 243, 243, 1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF67D4CF),
          width: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 54,
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                textInputAction: textInputAction,
                onSubmitted: onFieldSubmitted,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(26, 28, 28, 1),
                ),
                onChanged: (v) {
                  if (field.value != v) field.didChange(v);
                },
                decoration: _decoration(),
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
