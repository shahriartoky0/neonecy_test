import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import '../../config/app_sizes.dart';
import '../../config/app_strings.dart';
import '../../design/app_colors.dart';

class ReusableDatePickerField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Color? color;
  final Widget? prefixIcon;
  final Function(DateTime)? onDateSelected; // Callback for selected date

  const ReusableDatePickerField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.color = Colors.white,
    this.prefixIcon,
    required this.labelText,
    this.onDateSelected,
  });

  @override
  State createState() => _ReusableDatePickerFieldState();
}

class _ReusableDatePickerFieldState extends State<ReusableDatePickerField> {
  late TextEditingController _controller;
  DateTime? _selectedDate;


  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectYearMonth() async {
    final DateTime now = DateTime.now();
    final DateTime initial = widget.initialDate ?? now;
    final int firstYear = widget.firstDate?.year ?? 1900;
    final int lastYear = widget.lastDate?.year ?? 2100;

    // Show year picker first
    final int? selectedYear = await _showYearPicker(
      context: context,
      initialYear: initial.year,
      firstYear: firstYear,
      lastYear: lastYear,
    );

    if (selectedYear != null) {
      // Show month picker
      final int? selectedMonth = await _showMonthPicker(
        context: context,
        initialMonth: initial.month,
      );

      if (selectedMonth != null) {
        final DateTime selectedDate = DateTime(selectedYear, selectedMonth);
        final String formattedDate = "$selectedYear-${DateFormat('MMMM').format(selectedDate)}";

        setState(() {
          _controller.text = formattedDate;
          _selectedDate = selectedDate;
        });

        // Call callback if provided
        widget.onDateSelected?.call(selectedDate);
      }
    }
  }

  Future<int?> _showYearPicker({
    required BuildContext context,
    required int initialYear,
    required int firstYear,
    required int lastYear,
  }) async {
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.selectYear.tr),
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(firstYear),
              lastDate: DateTime(lastYear),
              selectedDate: DateTime(initialYear),
              onChanged: (DateTime date) {
                Navigator.of(context).pop(date.year);
              },
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.cancel.tr,
                style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _showMonthPicker({required BuildContext context, required int initialMonth}) async {
    final List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.selectYear.tr),
          content: SizedBox(
            width: double.minPositive,
            height: 400,
            child: Column(
              children: <Widget>[
                const Divider(thickness: 2),
                Expanded(
                  child: ListView.builder(
                    itemCount: months.length,
                    itemBuilder: (BuildContext context, int index) {
                      final bool isSelected = (index + 1) == initialMonth;
                      return ListTile(
                        title: Text(
                          months[index],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        onTap: () {
                          Navigator.of(context).pop(index + 1);
                        },
                      );
                    },
                  ),
                ),
                const Divider(thickness: 2),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.cancel.tr,
                style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Get the selected date (useful for getting the DateTime object)
  DateTime? get selectedDate => _selectedDate;

  // Get formatted date string
  String get formattedDate => _controller.text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(AppSizes.md),
      ),
      child: GestureDetector(
        onTap: _selectYearMonth,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _controller,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: context.txtTheme.headlineMedium?.copyWith(fontSize: 18),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: widget.prefixIcon,
              hintText: widget.hintText,
              hintStyle: context.txtTheme.labelSmall,
              suffixIcon: const Padding(
                padding: EdgeInsets.all(AppSizes.iconXs),
                child: Icon(Icons.calendar_month),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
