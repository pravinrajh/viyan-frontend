import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/features/assistant/models/assistant_message.dart';
import 'package:md_eao/features/assistant/providers/assistant_providers.dart';
import 'package:md_eao/features/assistant/repositories/mock_assistant_repository.dart';

void main() {
  test(
    'assistantProvider appends user and structured assistant messages',
    () async {
      final container = ProviderContainer.test(
        overrides: [
          assistantRepositoryProvider.overrideWithValue(
            MockAssistantRepository(delay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(assistantProvider.notifier)
          .send('Show my pending tasks.');

      final state = container.read(assistantProvider);
      expect(state.messages, hasLength(2));
      expect(state.messages.first.role, MessageRole.user);
      expect(state.messages.last.role, MessageRole.assistant);
      expect(state.messages.last.intent, 'PENDING_TASKS');
      expect(state.messages.last.content, contains('pending'));
      expect(state.isSending, isFalse);
      expect(state.conversationId, isNotNull);
    },
  );

  test('newChat clears conversation and messages', () async {
    final container = ProviderContainer.test(
      overrides: [
        assistantRepositoryProvider.overrideWithValue(
          MockAssistantRepository(delay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(assistantProvider.notifier).send('Hello');
    await container.read(assistantProvider.notifier).newChat();

    final state = container.read(assistantProvider);
    expect(state.messages, isEmpty);
    expect(state.conversationId, isNull);
  });
}
