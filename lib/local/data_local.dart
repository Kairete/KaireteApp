import 'package:get_storage/get_storage.dart';

class LocalManager {
  static LocalManager? _instance;

  LocalManager._();

  static LocalManager get instance => _instance ??= LocalManager._();

  GetStorage box = GetStorage();

  void save({required dynamic key, required dynamic value}) {
    box.write(key, value);
  }

  dynamic read({required String key}) {
    return box.read(key);
  }

  dynamic remove({required String key}) {
    return box.remove(key);
  }
}
