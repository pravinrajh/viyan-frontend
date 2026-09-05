enum InvoiceStatus {
  draft,
  issued,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
}

extension InvoiceStatusX on InvoiceStatus {
  String get label => switch (this) {
    InvoiceStatus.draft => 'Draft',
    InvoiceStatus.issued => 'Issued',
    InvoiceStatus.partiallyPaid => 'Partially paid',
    InvoiceStatus.paid => 'Paid',
    InvoiceStatus.overdue => 'Overdue',
    InvoiceStatus.cancelled => 'Cancelled',
  };

  String get apiValue => switch (this) {
    InvoiceStatus.draft => 'DRAFT',
    InvoiceStatus.issued => 'ISSUED',
    InvoiceStatus.partiallyPaid => 'PARTIALLY_PAID',
    InvoiceStatus.paid => 'PAID',
    InvoiceStatus.overdue => 'OVERDUE',
    InvoiceStatus.cancelled => 'CANCELLED',
  };

  static InvoiceStatus fromApi(String value) {
    return switch (value.toUpperCase().replaceAll('-', '_')) {
      'DRAFT' => InvoiceStatus.draft,
      'ISSUED' => InvoiceStatus.issued,
      'PARTIALLY_PAID' || 'PARTIALLYPAID' => InvoiceStatus.partiallyPaid,
      'PAID' => InvoiceStatus.paid,
      'OVERDUE' => InvoiceStatus.overdue,
      'CANCELLED' || 'CANCELED' => InvoiceStatus.cancelled,
      _ => InvoiceStatus.draft,
    };
  }
}

class Invoice {
  const Invoice({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.customerId,
    required this.amount,
    required this.paidAmount,
    required this.balance,
    required this.status,
    this.projectId,
    this.dueDate,
    this.issueDate,
    this.description = '',
  });

  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String customerId;
  final String? projectId;
  final int amount;
  final int paidAmount;
  final int balance;
  final DateTime? dueDate;
  final DateTime? issueDate;
  final InvoiceStatus status;
  final String description;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: _string(json['id'], json['_id']),
      invoiceId: _string(json['invoiceId']),
      invoiceNumber: _string(json['invoiceNumber'], json['invoiceId']),
      customerId: _string(json['customerId']),
      projectId: _stringOrNull(json['projectId']),
      amount: _int(json['amount']),
      paidAmount: _int(json['paidAmount']),
      balance: _int(json['balance']),
      dueDate: _date(json['dueDate']),
      issueDate: _date(json['issueDate']),
      status: InvoiceStatusX.fromApi(_string(json['status'])),
      description: _string(json['description']),
    );
  }
}

class CreateInvoiceInput {
  const CreateInvoiceInput({
    required this.customerId,
    required this.amount,
    this.projectId,
    this.dueDate,
    this.issueDate,
    this.description = '',
  });

  final String customerId;
  final int amount;
  final String? projectId;
  final DateTime? dueDate;
  final DateTime? issueDate;
  final String description;
}

class UpdateInvoiceInput {
  const UpdateInvoiceInput({
    this.description,
    this.dueDate,
    this.cancel = false,
  });

  final String? description;
  final DateTime? dueDate;
  final bool cancel;
}

class RecordInvoicePaymentInput {
  const RecordInvoicePaymentInput({
    required this.amount,
    this.paymentMethod,
    this.notes = '',
    this.postToFinance = false,
    this.accountId,
    this.categoryId,
  });

  final int amount;
  final String? paymentMethod;
  final String notes;
  final bool postToFinance;
  final String? accountId;
  final String? categoryId;
}

class InvoiceCustomerOption {
  const InvoiceCustomerOption({required this.id, required this.name});

  final String id;
  final String name;

  factory InvoiceCustomerOption.fromJson(Map<String, dynamic> json) {
    return InvoiceCustomerOption(
      id: _string(json['id'], json['_id']),
      name: _string(json['name'], json['companyName']),
    );
  }
}

String _string(Object? value, [Object? fallback]) {
  if (value is String && value.isNotEmpty) return value;
  if (fallback is String && fallback.isNotEmpty) return fallback;
  return '';
}

String? _stringOrNull(Object? value) {
  final text = _string(value);
  return text.isEmpty ? null : text;
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
