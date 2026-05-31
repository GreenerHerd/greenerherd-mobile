import 'dart:convert';

import '../models/enums.dart';
import '../models/models.dart';

/// Maps `gh-api-auth` login payload to [AuthSession].
abstract final class AuthMapper {
  static AuthSession sessionFromLogin(Map<String, dynamic> data) {
    final user = Map<String, dynamic>.from(
      data['user'] as Map? ?? const {},
    );
    final token = data['accessToken'] as String? ?? '';
    final roleWire = (user['role'] as String? ?? 'OWNER').toUpperCase();
    return AuthSession(
      userId: user['id'] as String? ?? 'u1',
      farmId: primaryFarmIdFromToken(token) ?? 'farm-1',
      role: _roleFromWire(roleWire),
      displayName: user['name'] as String? ?? 'Farm user',
      accessToken: token,
    );
  }

  static AuthSession sessionWithFarm({
    required AuthSession base,
    required String farmId,
    required String accessToken,
  }) {
    return AuthSession(
      userId: base.userId,
      farmId: farmId,
      role: base.role,
      displayName: base.displayName,
      accessToken: accessToken,
    );
  }

  static String? primaryFarmIdFromToken(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    try {
      var payload = parts[1];
      final mod = payload.length % 4;
      if (mod > 0) payload += '=' * (4 - mod);
      final json =
          jsonDecode(utf8.decode(base64Url.decode(payload))) as Map<String, dynamic>;
      final farms = json['farm_ids'];
      if (farms is List && farms.isNotEmpty) {
        return farms.first as String;
      }
    } catch (_) {}
    return null;
  }

  static UserRole _roleFromWire(String wire) => switch (wire) {
        'MANAGER' => UserRole.manager,
        'FARM_HAND' => UserRole.farmHand,
        'VET' => UserRole.vet,
        _ => UserRole.owner,
      };
}
