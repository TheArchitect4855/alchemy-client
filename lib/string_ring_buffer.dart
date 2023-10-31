import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

class StringRingBuffer {
  final int capacity;
  final Queue<String> _buffer;
  int _length;

  StringRingBuffer(this.capacity) : _buffer = Queue(), _length = 0 {
    if (capacity <= 0) throw ArgumentError.value(capacity, 'capacity', 'Capacity must be greater than zero');
  }

  void add(String s) {
    if (s.length > capacity) throw ArgumentError('s is too long');
    while (_length + s.length >= capacity) {
      String t = _buffer.removeFirst();
      _length -= t.length;
    }

    _buffer.add(s);
    _length += s.length;
  }

  Uint8List asBytes() {
    final bytes = <int>[];
    for (var s in _buffer) {
      bytes.addAll(utf8.encode(s));
    }

    return Uint8List.fromList(bytes);
  }

  void clear() {
    _buffer.clear();
    _length = 0;
  }
}
