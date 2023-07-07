import 'dart:typed_data';

String base32Encode(Uint8List data) {
  const chars = r'0123456789ABCDEFGHJKMNPQRSTVWXYZ*~$=U';
  final actualLen = data.length;
  while (data.length % 5 != 0) {
    data.add(0);
  }

  var buf = StringBuffer();
  var sum = 0;
  for (var i = 0; i < data.length; i += 5) {
    final p0 = (data[i] & 0xf8) >> 3;
    buf.writeCharCode(chars.codeUnitAt(p0));
    sum += p0;

    final p1 = ((data[i] & 0x07) << 2) | ((data[i + 1] & 0xc0) >> 6);
    buf.writeCharCode(chars.codeUnitAt(p1));
    sum += p1;

    if (i + 1 >= actualLen) break;
    final p2 = (data[i + 1] & 0x3e) >> 1;
    buf.writeCharCode(chars.codeUnitAt(p2));
    sum += p2;

    final p3 = ((data[i + 1] & 0x01) << 4) | ((data[i + 2] & 0xf0) >> 4);
    buf.writeCharCode(chars.codeUnitAt(p3));
    sum += p3;

    if (i + 2 >= actualLen) break;
    final p4 = ((data[i + 2] & 0x0f) << 1) | ((data[i + 3] & 0x80) >> 7);
    buf.writeCharCode(chars.codeUnitAt(p4));
    sum += p4;

    if (i + 3 >= actualLen) break;
    final p5 = (data[i + 3] & 0x7c) >> 2;
    buf.writeCharCode(chars.codeUnitAt(p5));
    sum += p5;

    final p6 = ((data[i + 3] & 0x03) << 3) | ((data[i + 4] & 0xe0) >> 5);
    buf.writeCharCode(chars.codeUnitAt(p6));
    sum += p6;

    if (i + 4 >= actualLen) break;
    final p7 = data[i + 4] & 0x1f;
    buf.writeCharCode(chars.codeUnitAt(p7));
    sum += p7;
  }

  final checksum = sum % 37;
  buf.writeCharCode(chars.codeUnitAt(checksum));
  return buf.toString();
}

Uint8List hexDecode(String data) {
  if (data.length % 2 != 0) throw ArgumentError('invalid hex string');

  final res = <int>[];
  for (var i = 0; i < data.length; i += 2) {
    final pair = data.substring(i, i + 2);
    res.add(int.parse(pair, radix: 16));
  }

  return Uint8List.fromList(res);
}
