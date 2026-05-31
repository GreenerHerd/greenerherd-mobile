import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// Live integration tests against running APIs + Postgres (docker).
///
/// Flutter's widget test binding blocks real HTTP; run with dart test:
/// ```bash
/// LIVE_STACK_TESTS=1 dart test test/integration/live_stack_test.dart
/// ```
/// Or: `./scripts/run-comprehensive-tests.sh`
final _runLive = Platform.environment['LIVE_STACK_TESTS'] == '1';

const _bearer =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidTEiLCJmYXJtX2lkcyI6WyJmYXJtLTEiXSwicm9sZSI6Ik9XTkVSIiwiaWF0IjoxNzc5MTI1NzQzLCJleHAiOjE4MTA2NjE3NDN9.hayjIR_PDypFhMbZd5MXugEJhaemeh5fBBGNX1yoPBo';

const _animalsBase = 'http://127.0.0.1:3006';

void main() {
  group('Live stack integration', () {
    test('skipped unless LIVE_STACK_TESTS=1', () {
      if (_runLive) return;
      expect(_runLive, isFalse,
          reason: 'Set LIVE_STACK_TESTS=1 with APIs + DB running');
    }, skip: _runLive);

    test('all core APIs respond on /health', () async {
      final ports = [3001, 3002, 3003, 3004, 3005, 3006, 3007, 3008];
      final client = HttpClient();
      addTearDown(client.close);
      for (final port in ports) {
        final uri = Uri.parse('http://127.0.0.1:$port/health');
        final response = await client.getUrl(uri).then((r) => r.close());
        final body = await response.transform(utf8.decoder).join();
        expect(response.statusCode, 200, reason: 'port $port body=$body');
      }
    }, skip: !_runLive);

    test('animals API list matches Postgres when DATABASE_URL set', () async {
      final dbUrl = Platform.environment['DATABASE_URL'];
      if (dbUrl == null || dbUrl.isEmpty) {
        return;
      }

      final client = HttpClient();
      addTearDown(client.close);

      final animalsUri = Uri.parse('$_animalsBase/api/v1/farms/farm-1/animals');
      final animalsReq = await client.getUrl(animalsUri);
      animalsReq.headers.set('Authorization', 'Bearer $_bearer');
      final animalsRes = await animalsReq.close();
      expect(animalsRes.statusCode, 200);
      final animalsJson =
          jsonDecode(await animalsRes.transform(utf8.decoder).join())
              as Map<String, dynamic>;
      final apiCount = (animalsJson['data'] as List).length;

      final dbAnimals = await _psqlCount(
        "SELECT COUNT(*)::int FROM animals WHERE farm_id='farm-1'",
      );
      expect(apiCount, dbAnimals,
          reason: 'API animal count should match Postgres');
    }, skip: !_runLive);

    test('groups API returns purpose field', () async {
      final client = HttpClient();
      addTearDown(client.close);
      final uri = Uri.parse('$_animalsBase/api/v1/farms/farm-1/groups');
      final req = await client.getUrl(uri);
      req.headers.set('Authorization', 'Bearer $_bearer');
      final res = await req.close();
      expect(res.statusCode, 200);
      final json =
          jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, dynamic>;
      final data = json['data'] as List;
      if (data.isEmpty) return;
      expect(data.first['purpose'], isNotNull);
    }, skip: !_runLive);
  });
}

Future<int> _psqlCount(String sql) async {
  final result = await Process.run(
    'docker',
    [
      'exec',
      'greenerherd-postgres',
      'psql',
      '-U',
      'greenerherd',
      '-d',
      'greenerherd',
      '-tAc',
      sql,
    ],
  );
  if (result.exitCode != 0) {
    throw StateError('psql failed: ${result.stderr}');
  }
  return int.parse(result.stdout.toString().trim());
}
