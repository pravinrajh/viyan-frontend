import '../../../core/utils/mock_delay.dart';
import '../models/sales_summary.dart';
import 'sales_repository.dart';

class MockSalesRepository implements SalesRepository {
  MockSalesRepository({this.delay});

  final Duration? delay;

  @override
  Future<SalesSummary> fetchSummary() {
    final now = DateTime.now();
    final leads = [
      SalesLead(
        id: 'lead-1',
        name: 'ABC Builders',
        source: 'Referral',
        estimatedValue: 25000000,
        status: SalesLeadStatus.converted,
        owner: 'Sales Head',
        followUpDate: now.subtract(const Duration(days: 20)),
        customerName: 'ABC Builders',
        projectName: 'Chennai Villa',
      ),
      SalesLead(
        id: 'lead-2',
        name: 'XYZ Developers',
        source: 'Inbound',
        estimatedValue: 50000000,
        status: SalesLeadStatus.converted,
        owner: 'Sales Head',
        followUpDate: now.subtract(const Duration(days: 40)),
        customerName: 'XYZ Developers',
        projectName: 'OMR Commercial',
      ),
      SalesLead(
        id: 'lead-3',
        name: 'Kumar Residence',
        source: 'Site walk-in',
        estimatedValue: 12000000,
        status: SalesLeadStatus.negotiation,
        owner: 'Sales Head',
        followUpDate: now.add(const Duration(days: 2)),
        customerName: 'Kumar Residence',
        projectName: 'Coimbatore Interior',
      ),
      SalesLead(
        id: 'lead-4',
        name: 'Green Homes',
        source: 'Partner',
        estimatedValue: 18000000,
        status: SalesLeadStatus.qualified,
        owner: 'BD',
        followUpDate: now.add(const Duration(days: 4)),
        customerName: 'Green Homes',
      ),
      SalesLead(
        id: 'lead-5',
        name: 'Coastal Estates',
        source: 'Exhibition',
        estimatedValue: 9000000,
        status: SalesLeadStatus.siteVisit,
        owner: 'BD',
        followUpDate: now.add(const Duration(days: 6)),
      ),
      SalesLead(
        id: 'lead-6',
        name: 'Nova Spaces',
        source: 'Cold call',
        estimatedValue: 6500000,
        status: SalesLeadStatus.contacted,
        owner: 'Sales Exec',
        followUpDate: now.add(const Duration(days: 3)),
      ),
      SalesLead(
        id: 'lead-7',
        name: 'Horizon Living',
        source: 'Website',
        estimatedValue: 11000000,
        status: SalesLeadStatus.newLead,
        owner: 'Sales Exec',
        followUpDate: now.add(const Duration(days: 1)),
      ),
    ];

    return withMockDelay(
      SalesSummary(
        monthToDate: 82000000,
        target: 110000000,
        pipelineValue: 92000000,
        newLeads: 4,
        conversions: 2,
        outstandingOrders: 14,
        commentary: 'Pipeline healthy. Kumar Residence and Green Homes need MD-visible follow-up this week.',
        leads: leads,
      ),
      delay: delay,
    );
  }

  @override
  Future<SalesLead> createLead({
    required String name,
    required String source,
    String? companyName,
    String? phone,
    String? email,
    double? estimatedValue,
  }) async {
    await mockDelay(delay: delay);
    return SalesLead(
      id: 'lead-new',
      name: name,
      source: source,
      estimatedValue: estimatedValue ?? 0,
      status: SalesLeadStatus.newLead,
      owner: 'You',
      followUpDate: DateTime.now().add(const Duration(days: 3)),
      customerName: companyName,
    );
  }
}
