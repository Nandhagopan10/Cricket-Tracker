import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 1)
class Profile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isDefault;

  Profile({
    String? id,
    required this.name,
    required this.role,
    this.avatarUrl,
    DateTime? createdAt,
    this.isDefault = false,
  }) : id = id ?? Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
}

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 1;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    final profile = Profile(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as String,
      avatarUrl: fields[3] as String?,
      createdAt: fields[4] as DateTime,
    );
    profile.isDefault = (fields[5] as bool? ?? false);
    return profile;
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isDefault);
  }
}
