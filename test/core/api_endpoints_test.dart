import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/network/api_endpoints.dart';
import 'package:md_eao/core/utils/currency_formatters.dart';
import 'package:md_eao/features/assistant/models/assistant_message.dart';

void main() {
  test('API constants match the frozen contract', () {
    expect(ApiEndpoints.health, '/api/v1/health');
    expect(ApiEndpoints.login, '/api/v1/auth/login');
    expect(ApiEndpoints.register, '/api/v1/auth/register');
    expect(ApiEndpoints.refresh, '/api/v1/auth/refresh');
    expect(ApiEndpoints.logout, '/api/v1/auth/logout');
    expect(ApiEndpoints.me, '/api/v1/auth/me');
    expect(ApiEndpoints.dashboard, '/api/v1/dashboard');
    expect(ApiEndpoints.assistantQuery, '/api/v1/assistant/query');
    expect(ApiEndpoints.assistantAction, '/api/v1/assistant/action');
    expect(ApiEndpoints.assistantChat, '/api/v1/assistant/chat');
    expect(ApiEndpoints.assistantHistory, '/api/v1/assistant/history');
    expect(
      ApiEndpoints.assistantActionConfirm('abc'),
      '/api/v1/assistant/action/abc/confirm',
    );
    expect(ApiEndpoints.tasks, '/api/v1/tasks');
    expect(ApiEndpoints.task('abc'), '/api/v1/tasks/abc');
    expect(ApiEndpoints.taskStatus('abc'), '/api/v1/tasks/abc/status');
    expect(ApiEndpoints.employees, '/api/v1/employees');
    expect(ApiEndpoints.meetings, '/api/v1/meetings');
    expect(ApiEndpoints.projects, '/api/v1/projects');
    expect(ApiEndpoints.project('abc'), '/api/v1/projects/abc');
    expect(ApiEndpoints.projectSummary('abc'), '/api/v1/projects/abc/summary');
    expect(ApiEndpoints.salesSummary, '/api/v1/sales/summary');
    expect(ApiEndpoints.salesFollowUps, '/api/v1/sales/follow-ups');
    expect(ApiEndpoints.leads, '/api/v1/leads');
    expect(ApiEndpoints.customers, '/api/v1/customers');
    expect(ApiEndpoints.financeSummary, '/api/v1/finance/summary');
    expect(
      ApiEndpoints.dashboardWeeklyFinancial,
      '/api/v1/dashboard/weekly-financial-requirement',
    );
    expect(
      ApiEndpoints.dashboardMorningReport,
      '/api/v1/dashboard/morning-report',
    );
    expect(ApiEndpoints.notifications, '/api/v1/notifications');
    expect(ApiEndpoints.meetings, '/api/v1/meetings');
  });

  test('INR formatter uses Lakh and Crore compact units', () {
    expect(CurrencyFormatters.inr(1850000), '₹18.50 L');
    expect(CurrencyFormatters.inr(42000000), '₹4.20 Cr');
  });

  test('AssistantQueryResponse formats structured display text', () {
    const response = AssistantQueryResponse(
      intent: 'PENDING_TASKS',
      summary: 'You have pending tasks.',
      items: ['Task A', 'Task B'],
      actions: ['Open Tasks'],
    );
    final text = response.toDisplayText();
    expect(text, contains('You have pending tasks.'));
    expect(text, contains('• Task A'));
    expect(text, contains('→ Open Tasks'));
  });
}
