import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    this.maxLines = 1,
    this.onSaved, this.onChange, required this.icon,
  });

  final String hint;
  final int maxLines;
  final void Function(String?)? onSaved;
  final Function(String)? onChange;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
     height: 60,
      child: TextFormField(
        maxLength: 100,
        onChanged: onChange,
        onSaved: onSaved,
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return ('Feild is requird');
          } else {
            return null;
          }
        },
        cursorColor: kIconColor,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: buildBorder(),
          enabledBorder: buildBorder(kTextColor),
          focusedBorder: buildBorder(kIconColor),
        ),
      ),
    );
  }

  OutlineInputBorder buildBorder([dynamic color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? Colors.white),
    );
  }
}
