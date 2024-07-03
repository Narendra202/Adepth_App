import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:flutter/material.dart';

class AddFloatingButton extends StatelessWidget {
  Function() event;
  AddFloatingButton({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: event,
      backgroundColor: ColorUtils.secondaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(16),
      //   side: const BorderSide(color: Colors.red),
      // ),
      child: const Icon(Icons.add),
    );
  }
}
