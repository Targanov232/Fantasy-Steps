import 'package:flutter/foundation.dart';
import '../content/content_service.dart';

enum WorldType { lotr, warhammer }

extension WorldTypeId on WorldType {
  String get id => name;
}

class WorldService extends ChangeNotifier {
  static final WorldService instance = WorldService._internal();
  WorldService._internal();

  WorldType _activeWorld = WorldType.lotr;
  WorldType get activeWorld => _activeWorld;

  // Строковый ID для ключей в базе данных (вернет "lotr" или "warhammer")
  String get activeWorldId => _activeWorld.name;

  void setActiveWorld(WorldType world) {
    _activeWorld = world;
    notifyListeners();
  }

  String get worldName {
    return ContentService.instance.worldName(activeWorldId);
  }

  String get routeName {
    return ContentService.instance.routeName(activeWorldId);
  }
}