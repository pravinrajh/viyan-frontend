import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/greeting.dart';
import '../models/assistant_message.dart';
import '../providers/assistant_providers.dart';
import 'widgets/assistant_bubbles.dart';
import 'widgets/assistant_input_bar.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  final _scroll = ScrollController();

  static const _suggestions = [
    "Today's business status",
    'What needs my attention?',
    "What is Sathish's status today?",
    'How is the OMR project?',
    'Show overdue tasks',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = preset ?? _controller.text;
    if (preset == null) _controller.clear();
    await ref.read(assistantProvider.notifier).send(text);
    await _scrollToBottom();
  }

  Future<void> _openImportMinutesDialog() async {
    final momController = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import Meeting Minutes'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paste the meeting minutes or notes below. Viyan will find '
                  'the action items and create a task for each one.',
                  style: TextStyle(color: AppTheme.mutedText, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: momController,
                  minLines: 8,
                  maxLines: 16,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. "Sathish to collect the pending payment by '
                        'Friday. Priya to prepare the revised BOQ, high '
                        'priority."',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, momController.text),
              child: const Text('Create Tasks'),
            ),
          ],
        );
      },
    );
    // Deferred: the dialog's closing transition can still be reading from
    // the controller on this frame, so disposing synchronously here throws
    // "used after being disposed".
    WidgetsBinding.instance.addPostFrameCallback((_) => momController.dispose());
    if (text == null || text.trim().isEmpty) return;
    await ref.read(assistantProvider.notifier).importMeetingMinutes(text);
    await _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_scroll.hasClients) return;
    await _scroll.animateTo(
      _scroll.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProvider);
    final wide = MediaQuery.sizeOf(context).width >= 960;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child: _ConversationSidebar(
                    state: state,
                    searchController: _searchController,
                    onNewChat: () =>
                        ref.read(assistantProvider.notifier).newChat(),
                    onSearch: (q) =>
                        ref.read(assistantProvider.notifier).setSearchQuery(q),
                    onSelect: (id) => ref
                        .read(assistantProvider.notifier)
                        .loadConversation(id),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: _mainPane(state)),
              ],
            )
          : Column(
              children: [
                _MobileChatBar(
                  onNewChat: () =>
                      ref.read(assistantProvider.notifier).newChat(),
                  onShowHistory: () => _showHistorySheet(state),
                ),
                Expanded(child: _mainPane(state)),
              ],
            ),
    );
  }

  Widget _mainPane(AssistantChatState state) {
    return Column(
      children: [
        Expanded(
          child: state.isLoadingHistory && state.messages.isEmpty
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : state.isEmpty
                  ? _EmptyGreeting(
                      suggestions: _suggestions,
                      onSend: _send,
                      onImportMinutes: _openImportMinutesDialog,
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      itemCount:
                          state.messages.length + (state.isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < state.messages.length) {
                          return _MessageBlock(
                            message: state.messages[index],
                            onConfirm: (actionId, confirmed) async {
                              await ref
                                  .read(assistantProvider.notifier)
                                  .confirmAction(
                                    actionId: actionId,
                                    confirmed: confirmed,
                                  );
                              await _scrollToBottom();
                            },
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Viyan is thinking…'),
                            ],
                          ),
                        );
                      },
                    ),
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                ),
                if (state.lastFailedPrompt != null)
                  TextButton(
                    onPressed: () =>
                        ref.read(assistantProvider.notifier).retryLast(),
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        AssistantInputBar(
          controller: _controller,
          enabled: !state.isSending,
          onSend: () => _send(),
          onImportMinutes: _openImportMinutesDialog,
        ),
      ],
    );
  }

  Future<void> _showHistorySheet(AssistantChatState state) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: _ConversationSidebar(
              state: state,
              searchController: _searchController,
              onNewChat: () {
                Navigator.pop(context);
                ref.read(assistantProvider.notifier).newChat();
              },
              onSearch: (q) =>
                  ref.read(assistantProvider.notifier).setSearchQuery(q),
              onSelect: (id) {
                Navigator.pop(context);
                ref.read(assistantProvider.notifier).loadConversation(id);
              },
            ),
          ),
        );
      },
    );
  }
}

class _MobileChatBar extends StatelessWidget {
  const _MobileChatBar({
    required this.onNewChat,
    required this.onShowHistory,
  });

  final VoidCallback onNewChat;
  final VoidCallback onShowHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Chats',
            onPressed: onShowHistory,
            icon: const Icon(Icons.history),
          ),
          const Expanded(
            child: Text(
              'Viyan',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          IconButton(
            tooltip: 'New chat',
            onPressed: onNewChat,
            icon: const Icon(Icons.edit_square),
          ),
        ],
      ),
    );
  }
}

class _ConversationSidebar extends StatelessWidget {
  const _ConversationSidebar({
    required this.state,
    required this.searchController,
    required this.onNewChat,
    required this.onSearch,
    required this.onSelect,
  });

  final AssistantChatState state;
  final TextEditingController searchController;
  final VoidCallback onNewChat;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final conversations = state.filteredConversations;
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: FilledButton.icon(
              onPressed: onNewChat,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Chat'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Search chats',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Expanded(
            child: state.isLoadingHistory && conversations.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : conversations.isEmpty
                    ? const Center(
                        child: Text(
                          'No conversations yet',
                          style: TextStyle(color: AppTheme.mutedText),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final item = conversations[index];
                          final selected =
                              item.conversationId == state.conversationId;
                          return ListTile(
                            dense: true,
                            selected: selected,
                            selectedTileColor:
                                AppTheme.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () => onSelect(item.conversationId),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGreeting extends StatelessWidget {
  const _EmptyGreeting({
    required this.suggestions,
    required this.onSend,
    required this.onImportMinutes,
  });

  final List<String> suggestions;
  final Future<void> Function(String) onSend;
  final VoidCallback onImportMinutes;

  @override
  Widget build(BuildContext context) {
    final greeting = executiveGreeting();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        Text(
          '$greeting. I\'m Viyan, your AI Chief of Staff.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ask about tasks, projects, people, or what needs attention today.',
          style: TextStyle(color: AppTheme.mutedText, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in suggestions)
              ActionChip(
                label: Text(suggestion),
                onPressed: () => onSend(suggestion),
              ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onImportMinutes,
          icon: const Icon(Icons.upload_file_outlined, size: 18),
          label: const Text('Import meeting minutes → create tasks'),
        ),
      ],
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.message,
    required this.onConfirm,
  });

  final AssistantMessage message;
  final Future<void> Function(String actionId, bool confirmed) onConfirm;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return UserMessageBubble(message: message);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AiTextBubble(message: message),
        if (message.requiresConfirmation &&
            message.actionId != null &&
            message.actionId!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => onConfirm(message.actionId!, true),
                  child: const Text('Confirm'),
                ),
                OutlinedButton(
                  onPressed: () => onConfirm(message.actionId!, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        if (message.hasActionResult) _ActionResultCard(message: message),
      ],
    );
  }
}

class _ActionResultCard extends StatelessWidget {
  const _ActionResultCard({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12, left: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Action completed',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (message.taskId != null)
                      FilledButton.tonal(
                        onPressed: () =>
                            context.go(AppRoutes.taskDetail(message.taskId!)),
                        child: const Text('View Task'),
                      ),
                    if (message.meetingId != null)
                      FilledButton.tonal(
                        onPressed: () => context.go(AppRoutes.meetings),
                        child: const Text('View Meeting'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
