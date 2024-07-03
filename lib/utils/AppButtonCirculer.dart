
import 'package:expedition_poc/utils/colors.dart';
import 'package:flutter/material.dart';


class AppCircleButton extends StatefulWidget {
  const AppCircleButton({super.key, required this.icon , required this.onPressed});

  final icon;
  final VoidCallback onPressed;

  @override
  State<AppCircleButton> createState() => _AppCircleButtonState();
}

class _AppCircleButtonState extends State<AppCircleButton> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: primaryColor,
      child: TextButton(
        child: Icon(widget.icon, size: 30,color: Colors.white,),
        onPressed: widget.onPressed
      ),
    );
  }
}
