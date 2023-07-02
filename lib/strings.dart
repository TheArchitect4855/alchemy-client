String capitalizeWords(String s) {
  if (s.isEmpty) return '';
  
  final words = s.split(RegExp(' ')).map((e) {
    final first = e[0].toUpperCase();
    return '$first${e.substring(1)}';
  });

  return words.join(' ');
}
