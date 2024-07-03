import 'package:expedition_poc/utils/AppTextFormField.dart';
import 'package:expedition_poc/widgets/multiselect.dart';
import 'package:flutter/material.dart';

// Multi Select widget
// This widget is reusable
class MultiSelectWidget extends StatefulWidget {
  final List itemsList, items;
  final String name;
  final VoidCallback? onItemsChanged;

  const MultiSelectWidget({
    Key? key,
    required this.name,
    required this.itemsList,
    required this.items,
    this.onItemsChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  // this variable holds the selected items
  List items = [], itemsList = [];
  String name = "";

  @override
  void initState() {
    super.initState();
    itemsList = widget.itemsList;
    items = widget.items;
    name = widget.name;
  }

  void _showMultiSelect(List itemsList, List items) async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: itemsList, selectedItems: items);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        items = results;
      });
      if (widget.onItemsChanged != null) {
        widget.onItemsChanged!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        // GestureDetector(
        //   onTap: () => {_showMultiSelect(itemsList, items)},
        //   child: Container(
        //     padding: const EdgeInsets.only(bottom: 15),
        //     decoration: const BoxDecoration(
        //         border:
        //             Border(bottom: BorderSide(color: Colors.grey, width: 1))),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(
        //           name,
        //           style: const TextStyle(fontSize: 16),
        //         ),
        //         const Icon(Icons.arrow_drop_down)
        //       ],
        //     ),
        //   ),
        // ),

       AppFormTextField(
         labelText: name,
         hintText: name,
         onTep: () => {_showMultiSelect(itemsList, items)},
         suffixIcon: Icons.arrow_drop_down,
       ),
        const SizedBox(
          height: 5,
        ),
        // display selected items
        Wrap(
          spacing: 5.0, // spacing between adjacent chips
          runSpacing: 0.0, // spacing between lines
          children: items
              .map((e) => Chip(
                    label: Text(itemsList.firstWhere(
                        (element) => element["_key"] == e.toString())["name"]),
                    deleteIcon: const Icon(Icons.cancel),
                    onDeleted: () {
                      setState(() {
                        items.removeWhere((item) => item == e);
                      });
                      if (widget.onItemsChanged != null) {
                        widget.onItemsChanged!();
                      }
                    },
                  ))
              .toList(),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
