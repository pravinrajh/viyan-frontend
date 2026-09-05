
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/md_note.dart';
import '../providers/md_note_providers.dart';

class MdNotesScreen extends ConsumerWidget {
  const MdNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibleMdNotesProvider);
    final canManage = ref.watch(canManageMdNotesProvider);

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New note'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'MD notes',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(mdNoteSearchProvider.notifier).setQuery(v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncBody<List<MdNote>>(
                value: async,
                emptyMessage: 'No MD notes found.',
                emptyIcon: Icons.sticky_note_2_outlined,
                loadingMessage: 'Loading notes...',
                isEmpty: (items) => items.isEmpty,
                onRetry: () => ref.read(mdNotesProvider.notifier).refresh(),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(mdNotesProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final note = items[index];
                      return AppSurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            note.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [
                              note.relatedType.label,
                              if (note.createdAt != null)
                                DateFormatters.date(note.createdAt!),
                            ].join(' · '),
                          ),
                          trailing: StatusChip(
                            label: note.relatedType.label,
                            color: AppTheme.info,
                          ),
                          onTap: canManage
                              ? () => _detail(context, ref, note)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final body = TextEditingController();
    var relatedType = MdNoteRelatedType.none;
    final relatedId = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create MD note'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: body,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Note body'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<MdNoteRelatedType>(
                    initialValue: relatedType,
                    decoration:
                        const InputDecoration(labelText: 'Related type'),
                    items: [
                      for (final t in MdNoteRelatedType.values)
                        DropdownMenuItem(value: t, child: Text(t.label)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => relatedType = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: relatedId,
                    decoration: const InputDecoration(
                      labelText: 'Related id (optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    if (body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note body is required.')),
      );
      return;
    }
    try {
      await ref.read(mdNotesProvider.notifier).createNote(
            CreateMdNoteInput(
              body: body.text,
              relatedType: relatedType,
              relatedId: relatedId.text.trim().isEmpty
                  ? null
                  : relatedId.text.trim(),
            ),
          );
    } on AppException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _detail(
    BuildContext context,
    WidgetRef ref,
    MdNote note,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(note.body),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(mdNotesProvider.notifier)
                      .deleteNote(note.id);
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Delete note'),
            ),
          ],
        ),
      ),
    );
  }
}
