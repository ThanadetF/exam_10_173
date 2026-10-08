import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';

MultiValidator numberValidator(String emptyMsg) => MultiValidator([
      RequiredValidator(errorText: emptyMsg),
      PatternValidator(r'^\d+(\.\d+)?$',
          errorText: 'กรอกได้เฉพาะตัวเลข (เช่น 4.5)'),
    ]);

const decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

final List<TextInputFormatter> decimalFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
];
