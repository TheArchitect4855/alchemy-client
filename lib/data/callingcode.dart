import 'dart:convert';
import 'package:flutter/services.dart';

final countryCodePattern = RegExp(r'^[A-Z]{2}$');
final dialCodePattern = RegExp(r'^\+\d+$');

class CallingCode {
  final String name;
  final String dialCode;
  final String code;

  CallingCode(this.name, this.dialCode, this.code) {
    if (!countryCodePattern.hasMatch(code)) throw ArgumentError.value(code, 'code', 'invalid format');
    if (!dialCodePattern.hasMatch(dialCode)) throw ArgumentError.value(dialCode, 'dialCode', 'invalid format');
  }

  CallingCode.fromJson(Map<String, dynamic> values) : this(values['name'], values['dialCode'], values['code']);

  static Iterable<CallingCode> get callingCodes => _callingCodes;
  static bool get isLoaded => _isLoaded;
  static bool _isLoaded = false;
  static late final List<CallingCode> _callingCodes;

  static Future<void> loadCallingCodes() async {
    if (_isLoaded) throw StateError('already loaded');
    _isLoaded = true;
    String json = await rootBundle.loadString('assets/calling-codes.json');
    _callingCodes = List.unmodifiable((jsonDecode(json) as List<dynamic>).map((e) => CallingCode.fromJson(e)));
  }
}
