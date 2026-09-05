import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class AssistantInputBar extends StatelessWidget {
  const AssistantInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.onImportMinutes,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final VoidCallback? onImportMinutes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (onImportMinutes != null)
                    IconButton(
                      tooltip: 'Import meeting minutes → create tasks',
                      onPressed: enabled ? onImportMinutes : null,
                      icon: const Icon(Icons.upload_file_outlined, size: 20),
                    ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Ask Viyan…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: enabled ? onSend : null,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.navy,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_upward, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use the send button to submit your message',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
