import 'package:crypto/crypto.dart';

List<int> sign(List<int> data, List<int> key) {
  final hmac = Hmac(sha512, key);
  final signature = hmac.convert(data);
  return signature.bytes;
}
