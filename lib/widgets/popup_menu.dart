import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  List menuList;

  PopupMenu({super.key, required this.menuList});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: Container(
        height: 30,
        width: 25,
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.settings,
        ),
      ),
      itemBuilder: (BuildContext context) {
        return menuList
            .map((e) => PopupMenuItem(
          value: e["value"].toString(),
          child: Text(e["name"]),
        ))
            .toList();
      },
      onSelected: (String value) {
        var item = menuList.where((e) => e["value"] == value).first;
        item["method"]();
      },
    );
  }
}
