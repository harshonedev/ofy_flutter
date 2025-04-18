import 'package:flutter/material.dart';

class MessageInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final bool isLoading;
  final bool isActive;
  final bool isChatFinished;
  final VoidCallback onSendMessage;
  final ColorScheme colorScheme;

  const MessageInputArea({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.isLoading,
    required this.isActive,
    required this.onSendMessage,
    required this.colorScheme,
    required this.isChatFinished,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 120, // Limit max height to prevent extreme expansion
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  enabled: isChatFinished,
                  controller: messageController,
                  focusNode: focusNode,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty &&
                        !isLoading &&
                        isChatFinished) {
                      onSendMessage();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 46,
            height: 46,
            child: Material(
              color:
                  !isChatFinished
                      ? colorScheme.surfaceVariant
                      : colorScheme.primary,
              borderRadius: BorderRadius.circular(23),
              elevation: 0,
              child: InkWell(
                onTap: !isChatFinished ? null : onSendMessage,
                borderRadius: BorderRadius.circular(23),
                child: Icon(
                  !isChatFinished ? Icons.hourglass_empty : Icons.send_rounded,
                  color:
                      !isChatFinished
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
