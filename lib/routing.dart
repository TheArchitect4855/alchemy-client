import 'package:flutter/material.dart';

void replaceRoute(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => page), (route) => false);
}
