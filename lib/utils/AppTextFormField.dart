
import 'package:flutter/material.dart';

class AppFormTextField extends StatefulWidget {
  const AppFormTextField({super.key,this.controller, this.labelText, this.hintText, this.keyboardInputType, this.readOnly, this.initValue, this.suffixIcon, this.onTep, this.validator, this.onChanged, this.enabled, this.prefix});

  final labelText;
  final hintText;
  final controller;
  final keyboardInputType;
  final bool? readOnly;
  final initValue;
  final suffixIcon;
  final VoidCallback? onTep;
  final  validator;
  final onChanged;
  final enabled;
  final prefix;

  @override
  State<AppFormTextField> createState() => _AppFormTextFieldState();
}

class _AppFormTextFieldState extends State<AppFormTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      child: TextFormField(
        enabled: widget.enabled,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: widget.controller,
        keyboardType: widget.keyboardInputType,
        readOnly: widget.readOnly ?? false,
        initialValue: widget.initValue,
        onTap: widget.onTep,
        onChanged: (val){widget.onChanged;},
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
          prefix: widget.prefix,
          suffixIcon: Icon(widget.suffixIcon)),
        ),
      );

  }
}



class AppDropDownButtonField extends StatefulWidget {
  const AppDropDownButtonField({super.key, this.labelText, this.hintText, this.value, this.onChanged, this.items,});

  final labelText;
  final hintText;
  final value;
  final onChanged;
  final items;

  @override
  State<AppDropDownButtonField> createState() => _AppDropDownButtonFieldState();
}

class _AppDropDownButtonFieldState extends State<AppDropDownButtonField> {
  @override
  Widget build(BuildContext context) {
    return
      DropdownButtonFormField<String>(
        decoration:  InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),

        ),
        value: widget.value,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        onChanged: widget.onChanged,
        items: widget.items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
  }
}


class AppDropDownKeyNameField extends StatefulWidget {
  const AppDropDownKeyNameField({super.key, this.labelText, this.hintText, this.value, this.onChanged, this.items, this.validator});

  final labelText;
  final hintText;
  final value;
  final onChanged;
  final items;
  final validator;


  @override
  State<AppDropDownKeyNameField> createState() => _AppDropDownKeyNameFieldState();
}

class _AppDropDownKeyNameFieldState extends State<AppDropDownKeyNameField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      validator: widget.validator,
        decoration:  InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 14,horizontal: 10),
        ),
        value: widget.value,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        onChanged: widget.onChanged,
        items: widget.items.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value["_key"],
            child: Text(value["name"]),
          );
        }).toList(),
      );
  }
}


