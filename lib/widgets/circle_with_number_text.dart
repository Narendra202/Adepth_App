import 'package:flutter/material.dart';

class NumbeWithTitle extends StatelessWidget {
  final int number;
  final String text;
  final Color color;

  const NumbeWithTitle({super.key, required this.number, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number.toString(),
            style: TextStyle(
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            text.toString(),
            style: TextStyle(
              fontSize: 8,
              color: color,
            ),
          ),
        ],
      );
  }
}
