import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final Widget? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool showPasswordToggle;
  final Color? fillColor;
  final Color? hintTextColor;
  final EdgeInsets? contentPadding;
  final double? prefixIconHeight;

  const CustomTextField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.showPasswordToggle = true, // Default true for password fields
    this.fillColor = AppColors.primaryColor,
    this.hintTextColor = AppColors.textGreyLight,
    this.contentPadding = const EdgeInsets.symmetric(vertical: AppSizes.sm, horizontal: AppSizes.sm),
    this.prefixIconHeight = 8,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      obscureText: widget.isPassword ? _isObscured : false,
      style: TextStyle(color: AppColors.white),
      decoration: InputDecoration(

        contentPadding: widget.contentPadding,
        fillColor: widget.fillColor,
        filled: true,
        hint: Text(widget.hintText ?? '', style: TextStyle(color: AppColors.textGreyLight)),
        // Prefix Icon
        prefixIcon: widget.prefixIcon != null
            ? Padding(padding: const EdgeInsets.all(12), child: widget.prefixIcon)
            : null,

        // Suffix Icon (Password Toggle)
        suffixIcon: widget.isPassword && widget.showPasswordToggle
            ? IconButton(
                onPressed: _togglePasswordVisibility,
                icon: Icon(
                  _isObscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  color: AppColors.white,
                ),
              )
            : null,
      ),
    );
  }
}
