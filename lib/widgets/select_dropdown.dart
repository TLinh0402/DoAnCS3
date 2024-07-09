import 'package:flutter/material.dart';

class SelectDropdown extends StatefulWidget {
  @override
  _SelectDropdownState createState() => _SelectDropdownState();
}

class _SelectDropdownState extends State<SelectDropdown> {
  String _selectedType = 'Type';
  final List<String> _types = ['Type 1', 'Type 2', 'Type 3'];

  void _showTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Type'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _types.map((type) {
                return ListTile(
                  title: Text(type),
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Button Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: _showTypeSelectionDialog,
          child: AbsorbPointer(
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor:
                    Colors.grey[200], // Change this to your categoryColor
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintText: _selectedType,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
