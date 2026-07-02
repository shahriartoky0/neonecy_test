import 'package:flutter/material.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/utils/date_picker_utils.dart';

/// Read-only field styled like [CustomTextField] that opens a dark themed
/// bottom sheet list to pick a value (country / gender / language, etc).
class AuthPickerField extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final String? Function(String?)? validator;
  final bool searchable;

  const AuthPickerField({
    super.key,
    required this.hintText,
    required this.items,
    required this.onSelected,
    this.value,
    this.validator,
    this.searchable = true,
  });

  Future<String?> _open(BuildContext context) async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.iconBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusXl)),
      ),
      builder: (BuildContext sheetContext) {
        return _PickerSheet(title: hintText, items: items, searchable: searchable);
      },
    );
    if (selected != null) {
      onSelected(selected);
    }
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                final String? selected = await _open(context);
                if (selected != null) {
                  state.didChange(selected);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        value?.isNotEmpty == true ? value! : hintText,
                        style: TextStyle(
                          color: value?.isNotEmpty == true
                              ? AppColors.white
                              : AppColors.textGreyLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.textGreyLight),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final bool searchable;

  const _PickerSheet({required this.title, required this.items, required this.searchable});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late List<String> _filtered = widget.items;

  void _filter(String query) {
    setState(() {
      _filtered = widget.items
          .where((String item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGreyLight,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              if (widget.searchable)
                TextField(
                  onChanged: _filter,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.iconBackgroundLight,
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: AppColors.textGreyLight),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textGreyLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              const SizedBox(height: AppSizes.sm),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtered.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String item = _filtered[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item, style: const TextStyle(color: AppColors.white)),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Read-only field styled like [CustomTextField] that opens the native
/// date picker and formats the result as yyyy-MM-dd.
class AuthDateField extends StatelessWidget {
  final String hintText;
  final String? value;
  final ValueChanged<String> onSelected;
  final String? Function(String?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AuthDateField({
    super.key,
    required this.hintText,
    required this.onSelected,
    this.value,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                final DateTime? initialDate =
                    lastDate != null && lastDate!.isBefore(DateTime.now())
                        ? lastDate
                        : firstDate;
                final String? picked = await DatePickerUtils.pickFormatedDate(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (picked != null) {
                  onSelected(picked);
                  state.didChange(picked);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        value?.isNotEmpty == true ? value! : hintText,
                        style: TextStyle(
                          color: value?.isNotEmpty == true
                              ? AppColors.white
                              : AppColors.textGreyLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textGreyLight, size: 18),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}