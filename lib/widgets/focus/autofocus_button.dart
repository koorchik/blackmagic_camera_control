import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class AutofocusButton extends StatefulWidget {
  const AutofocusButton({super.key});

  @override
  State<AutofocusButton> createState() => _AutofocusButtonState();
}

class _AutofocusButtonState extends State<AutofocusButton> {
  bool _isLoading = false;

  Future<void> _triggerAutofocus() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await context.read<CameraStateProvider>().triggerAutofocus();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _triggerAutofocus,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.center_focus_strong),
        label: const Text('Autofocus'),
      ),
    );
  }
}
