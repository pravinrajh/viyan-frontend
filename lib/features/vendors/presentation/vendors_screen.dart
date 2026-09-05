
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/vendor.dart';
import '../providers/vendor_providers.dart';

class VendorsScreen extends ConsumerWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibleVendorsProvider);
    final canManage = ref.watch(canManageVendorsProvider);

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New vendor'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Vendors',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search vendors',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(vendorSearchProvider.notifier).setQuery(v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncBody<List<Vendor>>(
                value: async,
                emptyMessage: 'No vendors found.',
                emptyIcon: Icons.storefront_outlined,
                loadingMessage: 'Loading vendors...',
                isEmpty: (items) => items.isEmpty,
                onRetry: () => ref.read(vendorsProvider.notifier).refresh(),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(vendorsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final vendor = items[index];
                      return AppSurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            vendor.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              if (vendor.vendorId.isNotEmpty) vendor.vendorId,
                              if (vendor.phone.isNotEmpty) vendor.phone,
                              if (vendor.email.isNotEmpty) vendor.email,
                              if (vendor.location.isNotEmpty) vendor.location,
                            ].join(' · '),
                          ),
                          trailing: StatusChip(
                            label: vendor.status.label,
                            color: vendor.status == VendorStatus.active
                                ? AppTheme.success
                                : AppTheme.mutedText,
                          ),
                          onTap: canManage
                              ? () => _edit(context, ref, vendor)
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
    final phone = TextEditingController();
    final email = TextEditingController();
    final location = TextEditingController();
    final taxId = TextEditingController();
    final notes = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create vendor'),
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
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: location,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: taxId,
                  decoration: const InputDecoration(labelText: 'Tax id'),
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
    );
    if (ok != true || !context.mounted) return;
    if (name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required.')),
      );
      return;
    }
    try {
      await ref.read(vendorsProvider.notifier).createVendor(
            CreateVendorInput(
              name: name.text,
              phone: phone.text,
              email: email.text,
              location: location.text,
              taxId: taxId.text,
              notes: notes.text,
            ),
          );
    } on AppException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Vendor vendor) async {
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
              vendor.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(vendor.status.label),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final next = vendor.status == VendorStatus.active
                    ? VendorStatus.inactive
                    : VendorStatus.active;
                try {
                  await ref.read(vendorsProvider.notifier).updateVendor(
                        vendor.id,
                        UpdateVendorInput(status: next),
                      );
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: Text(
                vendor.status == VendorStatus.active
                    ? 'Mark inactive'
                    : 'Mark active',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(vendorsProvider.notifier)
                      .deleteVendor(vendor.id);
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Delete vendor'),
            ),
          ],
        ),
      ),
    );
  }
}
