
import '../models/vendor.dart';

abstract class VendorRepository {
  Future<List<Vendor>> fetchVendors();
  Future<Vendor> fetchVendor(String id);
  Future<Vendor> createVendor(CreateVendorInput input);
  Future<Vendor> updateVendor(String id, UpdateVendorInput input);
  Future<void> deleteVendor(String id);
}
