import 'package:flutter/material.dart';

typedef OnTagDelete(String key);

class Tags extends StatelessWidget {
  final Map<String, dynamic> data;
  final OnTagDelete onDelete;

  const Tags({Key key, this.data, this.onDelete}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: data
          .map((key, value) => MapEntry(
                key,
                Chip(
                    label: Text(value),
                    labelPadding: EdgeInsets.all(2.0),
                    deleteIcon: Icon(Icons.clear),
                    onDeleted: () => onDelete(key)),
              ))
          .values
          .toList(),
    );
  }
}
