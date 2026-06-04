import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalManager {
  static LocalManager? _instance;

  LocalManager._();

  static LocalManager get instance => _instance ??= LocalManager._();

  final storage = const FlutterSecureStorage();

  Future save({required dynamic key, required dynamic value}) async {
    await storage.write(
      key: key,
      value: value.toString(),
    );
  }

  Future read({required String key}) async {
    final data = await storage.read(key: key);
    return data == null ? null : int.parse(data);
  }

  Future remove({required String key}) async {
    return await storage.delete(key: key);
  }
}
