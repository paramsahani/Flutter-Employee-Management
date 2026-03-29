import 'package:hive/hive.dart';

class UserModel {
  final String username;
  final String password;

  UserModel({required this.username, required this.password});
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      username: reader.readString(),
      password: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeString(obj.username);
    writer.writeString(obj.password);
  }
}
