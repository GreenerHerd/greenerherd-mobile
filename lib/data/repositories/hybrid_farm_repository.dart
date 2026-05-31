import '../../core/config/app_config.dart';
import '../mock/mock_data_store.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../services/farm_mapper.dart';
import '../services/farms_api_client.dart';
import '../services/farms_remote_gateway.dart';
import '../services/people_api_client.dart';
import '../services/people_mapper.dart';
import '../services/people_remote_gateway.dart';
import 'repositories.dart';

/// Loads farm profile from `gh-api-farms` and team from `gh-api-people`.
class HybridFarmRepository implements FarmRepository {
  HybridFarmRepository({
    required MockDataStore offlineStore,
    FarmsRemoteGateway? farmsGateway,
    PeopleRemoteGateway? peopleGateway,
    String? farmId,
    String? bearerToken,
  })  : _offline = offlineStore,
        _farmId = farmId ?? 'farm-1',
        _farms = farmsGateway ??
            FarmsApiClient(
              baseUrl: AppConfig.farmsApiBaseUrl,
              bearerToken: bearerToken ?? AppConfig.inventoryDevBearerToken,
            ),
        _people = peopleGateway ??
            PeopleApiClient(
              baseUrl: AppConfig.peopleApiBaseUrl,
              bearerToken: bearerToken ?? AppConfig.inventoryDevBearerToken,
            );

  final MockDataStore _offline;
  final String _farmId;
  final FarmsRemoteGateway _farms;
  final PeopleRemoteGateway _people;

  @override
  Future<Farm> getCurrentFarm() async {
    if (AppConfig.useFarmsApi) {
      try {
        final row = await _farms.getFarm(_farmId);
        if (row != null) {
          var ownerName = '';
          if (AppConfig.usePeopleApi) {
            try {
              final members = await _people.listMembers(_farmId);
              for (final row in members) {
                final user = PeopleMapper.fromMemberWire(row);
                if (user.role == UserRole.owner) {
                  ownerName = user.name;
                  break;
                }
              }
            } catch (_) {}
          }
          return FarmMapper.fromWire(row, ownerName: ownerName);
        }
      } catch (_) {}
    }
    return _offline.farm;
  }

  @override
  Future<List<FarmUser>> getUsers() async {
    if (AppConfig.usePeopleApi) {
      try {
        final rows = await _people.listMembers(_farmId);
        if (rows.isNotEmpty) {
          return PeopleMapper.fromMemberList(rows);
        }
      } catch (_) {}
    }
    return _offline.users;
  }
}
