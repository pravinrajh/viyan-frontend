
import '../models/land_parcel.dart';

abstract class LandRepository {
  Future<List<LandParcel>> fetchParcels();
  Future<LandParcel> fetchParcel(String id);
  Future<LandParcel> createParcel(CreateLandParcelInput input);
  Future<LandParcel> updateParcel(String id, UpdateLandParcelInput input);
  Future<void> deleteParcel(String id);
}
