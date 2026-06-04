import 'package:kairete/features/dashboard/models/menu_item_model.dart';

class MasterDataManager {
  static MasterDataManager? _instance;

  MasterDataManager._();

  static MasterDataManager get instance => _instance ??= MasterDataManager._();

  List<ReactionsIcon> reactionIcons = [];
}
