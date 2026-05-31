import '../models/breed_reference.dart';
import '../models/enums.dart';
import '../repositories/repositories.dart';
import '../services/breed_reference_catalog.dart';

class MockBreedReferenceRepository implements BreedReferenceRepository {
  MockBreedReferenceRepository(this._catalog);

  final BreedReferenceCatalog _catalog;

  static Future<MockBreedReferenceRepository> create() async {
    final catalog = await BreedReferenceCatalog.load();
    return MockBreedReferenceRepository(catalog);
  }

  @override
  Future<List<BreedReference>> listBreeds(Species species) async {
    return _catalog.forSpecies(species);
  }

  @override
  Future<BreedReference?> findByName(Species species, String name) async {
    return _catalog.resolve(species, name);
  }
}
