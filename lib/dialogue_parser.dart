final _tagPattern = RegExp(r'^\[(.+)\]$');
final _whitespaceReplacePattern = RegExp(r'\s+');

class DialogueParser {
  final String _source;

  DialogueParser(String source) : _source = source;

  Map<String, String> parse() {
    final res = <String, String>{};
    final lines = _source.split('\n').map((e) => e.trim());

    final currentDialogue = <String>[];
    String? currentTag;
    for (final line in lines) {
      final tagMatch = _tagPattern.firstMatch(line);
      if (tagMatch == null && currentTag == null) {
        throw const FormatException('failed to parse dialogue: Encountered dialogue without tag');
      } else if (tagMatch == null && line.isEmpty) {
        currentDialogue.add('\n');
      } else if (tagMatch == null) {
        currentDialogue.add(line.replaceAll(_whitespaceReplacePattern, ' '));
      } else if (currentTag != null) {
        res[currentTag] = _format(currentDialogue);
        currentDialogue.clear();
        currentTag = tagMatch.group(1)!;
      } else {
        currentTag = tagMatch.group(1)!;
      }
    }

    if (currentTag != null) res[currentTag] = _format(currentDialogue);
    return res;
  }

  String _format(List<String> lines) => lines.join(' ').trim();
}
