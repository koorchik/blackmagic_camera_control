import 'package:flutter/material.dart';

/// Dialog for saving a new preset with a custom name
class SavePresetDialog extends StatefulWidget {
  const SavePresetDialog({
    super.key,
    this.existingPresets = const [],
  });

  final List<String> existingPresets;

  @override
  State<SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<SavePresetDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _errorText = 'Name cannot be empty';
      } else if (widget.existingPresets.contains(value.trim())) {
        _errorText = 'Preset already exists';
      } else {
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Preset'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Preset Name',
          hintText: 'Enter a name for this preset',
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
        onChanged: _validate,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _errorText == null && _controller.text.trim().isNotEmpty
              ? _save
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && _errorText == null) {
      Navigator.pop(context, name);
    }
  }
}
