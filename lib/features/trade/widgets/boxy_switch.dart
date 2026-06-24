import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';

class BoxySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const BoxySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.yellow : AppColors.textGreyLight,
          borderRadius: BorderRadius.circular(7), // boxy feel
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(5), // boxy thumb
            ),
          ),
        ),
      ),
    );
  }
}