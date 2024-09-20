import 'package:flutter/material.dart';

class TextFormFieldWithLabel extends StatelessWidget {
  final String label;
  final String? initialValue;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;

  const TextFormFieldWithLabel({
    Key? key,
    required this.label,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      initialValue: initialValue,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }
}

class NumberFormFieldWithLabel extends StatelessWidget {
  final String label;
  final double initialValue;
  final Function(double?)? onSaved;
  final String? Function(double?)? validator;

  const NumberFormFieldWithLabel({
    Key? key,
    required this.label,
    required this.initialValue,
    this.onSaved,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      initialValue: initialValue.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        final number = double.tryParse(value);
        if (number == null) {
          return 'Please enter a valid number';
        }
        return validator?.call(number);
      },
      onSaved: (value) {
        if (value != null) {
          final number = double.tryParse(value);
          onSaved?.call(number);
        }
      },
    );
  }
}