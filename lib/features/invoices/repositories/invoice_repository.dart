import '../models/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> fetchInvoices();
  Future<Invoice> fetchInvoice(String id);
  Future<Invoice> createInvoice(CreateInvoiceInput input);
  Future<Invoice> updateInvoice(String id, UpdateInvoiceInput input);
  Future<void> deleteInvoice(String id);
  Future<Invoice> recordPayment(String id, RecordInvoicePaymentInput input);
  Future<List<InvoiceCustomerOption>> fetchCustomers();
}
