import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class SendDmButton extends StatelessWidget {
  final String toUserId;

  const SendDmButton({super.key, required this.toUserId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.message),
      label: const Text("Chat"),
      onPressed: () async {
        try {
          await FirestoreService.sendDmRequest(toUserId);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("📩 DM request sent")),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to send DM: $e")),
          );
        }
      },
    );
  }
}
