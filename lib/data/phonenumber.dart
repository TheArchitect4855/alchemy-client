import 'callingcode.dart';

final phonePattern = RegExp(r'^\+(\d| )+$');
final suffixPattern = RegExp(r'^(\d| )+$');

class PhoneNumber {
  final CallingCode callingCode;
  final String suffix;

  PhoneNumber(this.callingCode, String suffix) : suffix = suffix.replaceAll(' ', '') {
    if (!isValidSuffix(suffix)) throw ArgumentError.value(suffix, 'number', 'invalid format');
  }

  @override
  String toString() => '${callingCode.dialCode}$suffix';

  static bool isValidSuffix(String suffix) => suffixPattern.hasMatch(suffix);

  static PhoneNumber? parse(String number) {
    if (!phonePattern.hasMatch(number)) return null;
    number = number.replaceAll(' ', '');

    final cc = parseCallingCode(number);
    if (cc == null) return null;

    String suffix = number.substring(cc.dialCode.length);
    if (!isValidSuffix(suffix)) return null;

    return PhoneNumber(cc, suffix);
  }

  static CallingCode? parseCallingCode(String number) {
    for (final cc in CallingCode.callingCodes) {
      if (number.startsWith(cc.dialCode)) return cc;
    }

    return null;
  }
}
