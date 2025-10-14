import 'package:flutter/material.dart';

Widget _buildLoginRequiredOverlay(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 60, color: colorScheme.primary),
        const SizedBox(height: 20),
        const Text(
          '需登入才能使用此功能',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          '請登入以解鎖許願池與邀請功能。',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 25),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('前往登入'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    ),
  );
}
