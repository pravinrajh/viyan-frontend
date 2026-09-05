import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/daily_report.dart';
import '../repositories/api_report_repository.dart';
import '../repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ApiReportRepository(ref.watch(apiClientProvider));
});

final dailyReportProvider = FutureProvider<DailyReport>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    return DailyReport(
      id: 'unsigned',
      title: 'Morning report',
      summary: '',
      generatedAt: DateTime.now(),
    );
  }
  return ref.watch(reportRepositoryProvider).fetchDailyReport();
});
