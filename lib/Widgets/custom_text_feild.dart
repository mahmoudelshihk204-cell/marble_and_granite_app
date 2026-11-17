import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    this.onSaved,
    this.onChange,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  final String hint;
  final ValueChanged<String?>? onSaved;
  final ValueChanged<String>? onChange;
  final IconData icon;
  final bool isPassword;

  // Controller اختياري للتحكم في قيمة الحقل من الصفحة الأم.
  final TextEditingController? controller;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // التحكم في إظهار وإخفاء كلمة المرور.
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextFormField(
        controller: widget.controller,
        maxLength: 100,
        onChanged: widget.onChange,
        onSaved: widget.onSaved,

        obscureText: widget.isPassword && !_isPasswordVisible,

        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Field is required';
          }
          return null;
        },

        cursorColor: kIconColor,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon),

          // زر العين يظهر فقط مع حقل كلمة المرور.
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                )
              : null,

          hintText: widget.hint,
          border: buildBorder(),
          enabledBorder: buildBorder(kTextColor),
          focusedBorder: buildBorder(kIconColor),
        ),
      ),
    );
  }

  OutlineInputBorder buildBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? Colors.white),
    );
  }
}
