import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/models/reaction_icon.dart';

/// Cache delle reazioni XenForo (GET api/reactions/).
class ReactionCatalog {
  ReactionCatalog._();
  static final ReactionCatalog instance = ReactionCatalog._();

  List<ReactionIcon> _icons = const [];
  bool _loaded = false;
  Future<void>? _loading;

  List<ReactionIcon> get icons => _icons;

  Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    return _loading ??= _fetch();
  }

  Future<void> _fetch() async {
    try {
      await AppApi.instance.applySession();
      final json =
          await AppApi.instance.xenforo.get(ApiPaths.reactions);
      final err = XenforoApi.firstErrorMessage(json);
      if (err != null) return;

      final raw = json['reactions'];
      if (raw is! List) return;

      _icons = raw
          .whereType<Map<String, dynamic>>()
          .map(ReactionIcon.fromJson)
          .where((icon) => icon.active && icon.reactionId > 0)
          .toList(growable: false);
      _loaded = true;
    } catch (_) {
      // Fallback: almeno il like standard XenForo.
      _icons = const [];
    } finally {
      _loading = null;
    }
  }

  ReactionIcon? iconFor(int reactionId) {
    for (final icon in _icons) {
      if (icon.reactionId == reactionId) return icon;
    }
    return null;
  }
}
