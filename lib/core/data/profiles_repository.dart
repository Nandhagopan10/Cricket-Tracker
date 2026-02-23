import 'package:hive/hive.dart';
import '../models/profile.dart';

class ProfilesRepository {
  static const String boxName = 'profiles';

  Box<Profile> get _box => Hive.box<Profile>(boxName);

  Future<List<Profile>> getAllProfiles() async {
    return _box.values.toList();
  }

  Future<void> saveProfile(Profile profile) async {
    await _box.put(profile.id, profile);
  }

  Future<void> deleteProfile(String id) async {
    await _box.delete(id);
  }

  Future<void> setDefaultProfile(String id) async {
    final profiles = _box.values.toList();
    for (final p in profiles) {
      if (p.isDefault && p.id != id) {
        p.isDefault = false;
        await _box.put(p.id, p);
      }
    }
    final newDefault = _box.get(id);
    if (newDefault != null) {
      newDefault.isDefault = true;
      await _box.put(newDefault.id, newDefault);
    }
  }

  Profile? getDefaultProfile() {
    for (final p in _box.values) {
      if (p.isDefault) return p;
    }
    return null;
  }
}
