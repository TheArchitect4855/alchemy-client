enum GenderKind {
  man,
  nonbinary,
  woman,
}

String parseGenderName(String value) {
  switch (value) {
    case 'Men': return 'men';
    case 'Non-Binary': return 'nonbinary';
    case 'Women': return 'women';
    default: throw UnimplementedError();
  }
}

String parseGenderKind(String value) {
  switch (value) {
    case 'men': return 'Men';
    case 'nonbinary': return 'Non-Binary';
    case 'women': return 'Women';
    default: throw UnimplementedError();
  }
}