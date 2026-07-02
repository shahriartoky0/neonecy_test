import 'package:flutter/material.dart';
import 'package:neonecy_test/core/design/app_colors.dart';

class AuthCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AuthCheckbox({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: value ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: value ? AppColors.white : AppColors.textGreyLight,
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 14, color: AppColors.primaryColor)
            : null,
      ),
    );
  }
}