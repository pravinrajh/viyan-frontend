import '../models/crm_overview.dart';

abstract class CrmRepository {
  Future<CrmOverview> fetchOverview();
}
