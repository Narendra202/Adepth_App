
import 'package:expedition_poc/utils/colors.dart';
import 'package:flutter/material.dart';

import 'colors.dart';


class AppTextFormField extends StatefulWidget {
  const AppTextFormField({super.key, required this.hintText, required this.controller, required this.prefixIcon, this.suffixIcon});

  final String hintText;
  final  controller;
  final  prefixIcon;
  final  suffixIcon;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: TextFormField(
        controller: widget.controller,
        // style: primaryTextStyle(size: 18),
        // obscureText: true,
        // obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          prefixIconColor: primaryColor,
          suffixIcon: widget.suffixIcon,
          contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
          hintText: widget.hintText,
          filled: true,
          fillColor: text_field_bg_color,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: t3_edit_background, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: t3_edit_background, width: 0.0),
          ),
        ),
      ),
    );
  }
}




