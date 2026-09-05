
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/land_parcel.dart';
import '../providers/land_providers.dart';

class LandScreen extends ConsumerWidget {
  const LandScreen({super.key});

  Color _color(LandParcelStatus status) => switch (status) {
        LandParcelStatus.available => AppTheme.success,
        LandParcelStatus.negotiation => AppTheme.warning,
        LandParcelStatus.legalVerification => AppTheme.info,
        LandParcelStatus.acquired => AppTheme.info,
        LandParcelStatus.dropped => AppTheme.mutedText,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibleLandParcelsProvider);
    final canManage = ref.watch(canManageLandProvider);

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New parcel'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Land parcels',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search land parcels',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(landSearchProvider.notifier).setQuery(v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncBody<List<LandParcel>>(
                value: async,
                emptyMessage: 'No land parcels found.',
                emptyIcon: Icons.map_outlined,
                loadingMessage: 'Loading land parcels...',
                isEmpty: (items) => items.isEmpty,
                onRetry: () =>
                    ref.read(landParcelsProvider.notifier).refresh(),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(landParcelsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final parcel = items[index];
                      return AppSurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            parcel.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              if (parcel.location.isNotEmpty) parcel.location,
                              if (parcel.ownerName.isNotEmpty)
                                parcel.ownerName,
                              if (parcel.askingPrice != null)
                                CurrencyFormatters.inr(parcel.askingPrice!),
                            ].join(' · '),
                          ),
                          trailing: StatusChip(
                            label: parcel.status.label,
                            color: _color(parcel.status),
                          ),
                          onTap: canManage
                              ? () => _detail(context, ref, parcel)
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
    final name = TextEditingController();
    final location = TextEditingController();
    final owner = TextEditingController();
    final price = TextEditingController();
    final notes = TextEditingController();
    var status = LandParcelStatus.available;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create land parcel'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: owner,
                    decoration: const InputDecoration(labelText: 'Owner'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: price,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Asking price'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<LandParcelStatus>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final s in LandParcelStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => status = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notes,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes'),
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
    if (name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required.')),
      );
      return;
    }
    try {
      await ref.read(landParcelsProvider.notifier).createParcel(
            CreateLandParcelInput(
              name: name.text,
              location: location.text,
              ownerName: owner.text,
              askingPrice: int.tryParse(price.text.trim()),
              status: status,
              notes: notes.text,
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
    LandParcel parcel,
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
            Text(
              parcel.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(parcel.status.label),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in LandParcelStatus.values)
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(landParcelsProvider.notifier)
                            .updateParcel(
                              parcel.id,
                              UpdateLandParcelInput(status: status),
                            );
                        if (context.mounted) Navigator.pop(context);
                      } on AppException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    },
                    child: Text(status.label),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(landParcelsProvider.notifier)
                      .deleteParcel(parcel.id);
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Delete parcel'),
            ),
          ],
        ),
      ),
    );
  }
}
