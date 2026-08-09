import 'package:flutter/material.dart';
import 'package:kairete/core/models/reaction_icon.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/widgets/reaction_face.dart';

typedef ReactionSelected = Future<void> Function(int reactionId);

/// Mostra il picker stile XenForo (`.tooltip--reaction` / `.reactTooltip`)
/// ancorato al controllo Like, e invoca [onSelected] con la reazione scelta.
Future<void> pickReactionAndApply(
  BuildContext context,
  ReactionSelected onSelected,
) async {
  await ReactionCatalog.instance.ensureLoaded();
  final icons = ReactionCatalog.instance.icons;
  if (!context.mounted) return;

  if (icons.isEmpty) {
    await onSelected(1);
    return;
  }

  final box = context.findRenderObject() as RenderBox?;
  Rect? anchor;
  if (box != null && box.hasSize) {
    anchor = box.localToGlobal(Offset.zero) & box.size;
  }

  final reactionId = await showGeneralDialog<int>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return _ReactionTooltipOverlay(
        icons: icons,
        anchor: anchor,
        animation: animation,
      );
    },
  );
  if (reactionId != null && reactionId > 0) {
    await onSelected(reactionId);
  }
}

/// Bubble icon-only come sul web: riga orizzontale, bordo leggero, scale al tap.
class _ReactionTooltipOverlay extends StatelessWidget {
  const _ReactionTooltipOverlay({
    required this.icons,
    required this.animation,
    this.anchor,
  });

  final List<ReactionIcon> icons;
  final Animation<double> animation;
  final Rect? anchor;

  static const double _iconSize = 32;
  static const double _iconPad = 5;
  static const double _bubblePadH = 6;
  static const double _bubblePadV = 4;
  static const double _gapAboveAnchor = 6;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screen = media.size;
    final safe = media.padding;

    // Stima larghezza bubble (come XF: ~32px + margin 5px per lato).
    final contentW = icons.length * (_iconSize + _iconPad * 2) + _bubblePadH * 2;
    final contentH = _iconSize + _iconPad * 2 + _bubblePadV * 2;

    double left;
    double top;
    if (anchor != null) {
      left = anchor!.center.dx - contentW / 2;
      top = anchor!.top - contentH - _gapAboveAnchor;
      // Se non c'è spazio sopra, metti sotto (come tooltip XF flip).
      if (top < safe.top + 4) {
        top = anchor!.bottom + _gapAboveAnchor;
      }
    } else {
      left = (screen.width - contentW) / 2;
      top = screen.height * 0.4;
    }

    left = left.clamp(8.0, screen.width - contentW - 8.0);
    top = top.clamp(safe.top + 4.0, screen.height - safe.bottom - contentH - 4.0);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppTheme.cardBorder, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _bubblePadH,
                    vertical: _bubblePadV,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final icon in icons) _ReactionChoice(icon: icon),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionChoice extends StatefulWidget {
  const _ReactionChoice({required this.icon});

  final ReactionIcon icon;

  @override
  State<_ReactionChoice> createState() => _ReactionChoiceState();
}

class _ReactionChoiceState extends State<_ReactionChoice> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final icon = widget.icon;
    return Tooltip(
      message: icon.title.isNotEmpty ? icon.title : 'Reazione',
      waitDuration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () => Navigator.of(context).pop(icon.reactionId),
        child: AnimatedScale(
          scale: _pressed ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: ReactionFace(icon: icon, size: 32),
          ),
        ),
      ),
    );
  }
}
