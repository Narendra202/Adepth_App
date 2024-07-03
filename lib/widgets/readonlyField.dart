import 'package:flutter/material.dart';

class ReadOnlyField extends StatelessWidget {
  final String title, value;
  Color? color = Colors.black;
  ReadOnlyField({Key? key, required this.title, required this.value, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: TextStyle(
                fontSize: 14.0, fontWeight: FontWeight.w500, color: color
            ),
          ),
        ),
        Expanded(
            flex: 8,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w300, color: color),
            )),
      ],
    );
  }
}
