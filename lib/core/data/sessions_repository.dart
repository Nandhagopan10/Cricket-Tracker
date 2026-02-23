import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class SessionsRepository {
  static const String boxName = 'sessions';

  Box get _box => Hive.box(boxName);

  Future<void> saveSession(Map<String, dynamic> session) async {
    final id = session['id'] as String? ?? const Uuid().v4();
    session['id'] = id;
    await _box.put(id, session);
  }

  List<Map<String, dynamic>> getAllSessions() {
    final List<Map<String, dynamic>> out = [];
    for (final raw in _box.values) {
      try {
        if (raw is Map) {
          out.add(
            Map<String, dynamic>.from(
              raw.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        } else {
          // Skip unknown types
        }
      } catch (_) {
        // ignore malformed entries
      }
    }
    return out;
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }
}
