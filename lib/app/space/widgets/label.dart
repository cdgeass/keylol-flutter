import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String label;
  final String value;

  const Label({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(decoration: TextDecoration.underline),
        ),
      ],
    );
  }
}
