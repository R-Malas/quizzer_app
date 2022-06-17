import 'package:flutter/material.dart';

class CriteriaDropdownField<T> extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final String labelText;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final FormFieldSetter<T>? onSave;
  final ValueChanged<T?>? onChange;

  const CriteriaDropdownField({
    Key? key,
    required this.items,
    required this.padding,
    required this.onChange,
    required this.onSave,
    required this.labelText,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              labelText,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          DropdownButtonFormField<T>(
              decoration: InputDecoration(
                // labelText: labelText,
                // labelStyle: const TextStyle(color: Colors.blue),
                hintText: hintText,
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2)),
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2)),
                focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2)),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2)),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2)),
              ),
              items: items,
              onSaved: onSave,
              validator: (value) {
                if (value == null) return 'This field is required';
                return null;
              },
              onChanged: onChange),
        ],
      ),
    );
  }
}
