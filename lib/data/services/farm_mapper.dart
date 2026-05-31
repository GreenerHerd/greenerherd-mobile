import '../models/enums.dart';
import '../models/models.dart';

/// Maps `gh-api-farms` wire records to UI [Farm].
abstract final class FarmMapper {
  static Farm fromWire(
    Map<String, dynamic> wire, {
    String ownerName = '',
  }) {
    final country = wire['country'] as String? ?? '';
    final lat = wire['location_lat'];
    final lng = wire['location_lng'];
    final location = lat != null && lng != null
        ? '$country (${lat.toString()}, ${lng.toString()})'
        : country;

    return Farm(
      id: wire['id'] as String,
      name: wire['name'] as String? ?? '',
      location: location,
      currency: wire['preferred_currency'] as String? ?? 'SAR',
      housing: _housingFromWire(wire['housing_type'] as String?),
      ownerName: ownerName,
    );
  }

  static HousingType _housingFromWire(String? wire) {
    return switch ((wire ?? 'INDOOR_FANS').toUpperCase()) {
      'INDOOR_SHADE' => HousingType.indoorShade,
      'PASTURE' => HousingType.pasture,
      _ => HousingType.indoorFans,
    };
  }
}
