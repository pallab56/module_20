import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Shows an AlertDialog asking the user to confirm deletion.
/// Returns true if the user confirmed.
Future<bool> showDeleteConfirmDialog(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.red.shade50,
        child: const Icon(Icons.delete_outline, size: 30, color: kExpenseColor),
      ),
      title: const Text('Delete Transaction?'),
      content: Text(
        'Are you sure you want to delete "$title"? This action cannot be undone.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kExpenseColor),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}