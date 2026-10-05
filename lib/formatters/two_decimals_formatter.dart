import 'package:flutter/services.dart';

class TwoDecimalsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    final separatorIndex = text.indexOf(RegExp(r'[.,]'));
    if (separatorIndex == -1) {
      if (RegExp(r'^\d+$').hasMatch(text)) {
        return newValue;
      }
      return oldValue;
    }

    final parts = text.split(RegExp(r'[.,]'));
    if (parts.length > 2) {
      return oldValue;
    }

    final decimals = parts.length == 2 ? parts[1] : '';
    if (decimals.length > 2) {
      return oldValue;
    }

    if (!RegExp(r'^\d+[.,]?\d{0,2}$').hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }
}
