import 'package:flutter/material.dart';

void textSnackbar(BuildContext context, String text) {
  final snackbar = SnackBar(content: Text(text));
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
