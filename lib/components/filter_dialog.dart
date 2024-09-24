import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String filterBranch;
  final String filterYear;
  final Function(String, String) onApply;

  const FilterDialog({
    super.key,
    required this.filterBranch,
    required this.filterYear,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _filterBranch;
  late String _filterYear;

  @override
  void initState() {
    super.initState();
    _filterBranch = widget.filterBranch;
    _filterYear = widget.filterYear;
  }

  void _resetFilters() {
    setState(() {
      _filterBranch = '';
      _filterYear = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Chats'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: _filterBranch,
                decoration: InputDecoration(
                  labelText: 'Filter by Branch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _filterBranch = newValue!;
                  });
                },
                items: <String>['', 'CSE', 'ME', 'EE', 'CE']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.isEmpty ? 'All Branches' : value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: _filterYear,
                decoration: InputDecoration(
                  labelText: 'Filter by Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _filterYear = newValue!;
                  });
                },
                items: <String>['', '1', '2', '3', '4']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.isEmpty ? 'All Years' : 'Year $value'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetFilters,
          child: const Text('Reset'),
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Apply'),
          onPressed: () {
            widget.onApply(_filterBranch, _filterYear);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}