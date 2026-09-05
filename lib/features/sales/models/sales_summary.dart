enum SalesLeadStatus {
  newLead,
  contacted,
  qualified,
  siteVisit,
  proposal,
  negotiation,
  converted,
  lost,
}

extension SalesLeadStatusX on SalesLeadStatus {
  String get label => switch (this) {
    SalesLeadStatus.newLead => 'New',
    SalesLeadStatus.contacted => 'Contacted',
    SalesLeadStatus.qualified => 'Qualified',
    SalesLeadStatus.siteVisit => 'Site Visit',
    SalesLeadStatus.proposal => 'Proposal',
    SalesLeadStatus.negotiation => 'Negotiation',
    SalesLeadStatus.converted => 'Converted',
    SalesLeadStatus.lost => 'Lost',
  };

  String get apiValue => switch (this) {
    SalesLeadStatus.newLead => 'new',
    SalesLeadStatus.contacted => 'contacted',
    SalesLeadStatus.qualified => 'qualified',
    SalesLeadStatus.siteVisit => 'site_visit',
    SalesLeadStatus.proposal => 'proposal',
    SalesLeadStatus.negotiation => 'negotiation',
    SalesLeadStatus.converted => 'converted',
    SalesLeadStatus.lost => 'lost',
  };

  static SalesLeadStatus fromApi(String value) {
    switch (value.trim().toUpperCase()) {
      case 'NEW':
        return SalesLeadStatus.newLead;
      case 'CONTACTED':
        return SalesLeadStatus.contacted;
      case 'QUALIFIED':
        return SalesLeadStatus.qualified;
      case 'UNQUALIFIED':
        return SalesLeadStatus.lost;
      case 'CONVERTED':
        return SalesLeadStatus.converted;
      case 'LOST':
        return SalesLeadStatus.lost;
      case 'SITE_VISIT':
        return SalesLeadStatus.siteVisit;
      case 'PROPOSAL':
        return SalesLeadStatus.proposal;
      case 'NEGOTIATION':
        return SalesLeadStatus.negotiation;
    }
    return SalesLeadStatus.values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () => SalesLeadStatus.newLead,
    );
  }
}

class SalesLead {
  const SalesLead({
    required this.id,
    required this.name,
    required this.source,
    required this.estimatedValue,
    required this.status,
    required this.owner,
    required this.followUpDate,
    this.customerName,
    this.projectName,
  });

  final String id;
  final String name;
  final String source;
  final double estimatedValue;
  final SalesLeadStatus status;
  final String owner;
  final DateTime followUpDate;
  final String? customerName;
  final String? projectName;

  factory SalesLead.fromJson(Map<String, dynamic> json) {
    final assigned = json['assignedTo'];
    var owner = json['owner'] as String? ?? '';
    if (owner.isEmpty && assigned is Map) {
      owner = assigned['name']?.toString() ?? '';
    }
    final followUp = json['nextFollowUpAt'] ?? json['followUpDate'];
    return SalesLead(
      id: (json['id'] ?? json['_id'] ?? json['leadId'] ?? '').toString(),
      name: json['name'] as String? ?? json['companyName'] as String? ?? '',
      source: json['source'] as String? ?? '',
      estimatedValue: (json['estimatedValue'] as num?)?.toDouble() ?? 0,
      status: SalesLeadStatusX.fromApi(json['status'] as String? ?? 'NEW'),
      owner: owner,
      followUpDate: followUp is String && followUp.isNotEmpty
          ? DateTime.tryParse(followUp) ?? DateTime.now()
          : DateTime.now(),
      customerName:
          json['customerName'] as String? ?? json['companyName'] as String?,
      projectName: json['projectName'] as String?,
    );
  }
}

class SalesSummary {
  const SalesSummary({
    required this.monthToDate,
    required this.target,
    required this.pipelineValue,
    required this.newLeads,
    required this.conversions,
    required this.outstandingOrders,
    required this.commentary,
    this.leads = const [],
  });

  final double monthToDate;
  final double target;
  final double pipelineValue;
  final int newLeads;
  final int conversions;
  final int outstandingOrders;
  final String commentary;
  final List<SalesLead> leads;

  double get attainment => target == 0 ? 0 : monthToDate / target;

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    final leadsBlock = json['leads'];
    final opportunities = json['opportunities'];
    final pipeline = json['pipeline'];
    final pipelineValue = pipeline is Map
        ? (pipeline['totalValue'] as num?)?.toDouble() ?? 0
        : (json['pipelineValue'] as num?)?.toDouble() ?? 0;
    final newLeads = leadsBlock is Map
        ? (leadsBlock['new'] as num?)?.toInt() ?? 0
        : json['newLeads'] as int? ?? 0;
    final conversions = leadsBlock is Map
        ? (leadsBlock['converted'] as num?)?.toInt() ?? 0
        : json['conversions'] as int? ?? 0;
    final openOpps = opportunities is Map
        ? (opportunities['open'] as num?)?.toInt() ?? 0
        : json['outstandingOrders'] as int? ?? 0;
    final weighted = pipeline is Map
        ? (pipeline['weightedValue'] as num?)?.toDouble() ?? 0
        : (json['monthToDate'] as num?)?.toDouble() ?? 0;
    return SalesSummary(
      monthToDate: (json['monthToDate'] as num?)?.toDouble() ?? weighted,
      target: (json['target'] as num?)?.toDouble() ?? 0,
      pipelineValue: pipelineValue,
      newLeads: newLeads,
      conversions: conversions,
      outstandingOrders: openOpps,
      commentary: json['commentary'] as String? ?? '',
      leads:
          ((json['leadItems'] as List<dynamic>?) ??
                  (json['leads'] is List
                      ? json['leads'] as List<dynamic>
                      : const []))
              .whereType<Map>()
              .map(
                (item) => SalesLead.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
    );
  }
}
