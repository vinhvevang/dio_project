import 'dart:async';

import 'package:flutter/material.dart';

class FlyingCartOverlay {
  static Future<void> animate({
    required BuildContext context,
    required Rect from,
    required Rect to,
    required Widget child,
    Duration duration = const Duration(milliseconds: 650),
  }) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final completer = Completer<void>();
    final entry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: duration,
          curve: Curves.easeInOutCubic,
          onEnd: () {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          builder: (context, t, _) {
            final x = _lerp(from.center.dx, to.center.dx, t);
            final y = _arcY(from.center.dy, to.center.dy, t, from, to);
            final scale = 1.0 - (0.35 * t);

            return IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    left: x - from.width / 4,
                    top: y - from.height / 4,
                    child: Opacity(
                      opacity: 1 - t,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);
    await completer.future;
    entry.remove();
  }

  static double _lerp(double start, double end, double t) => start + ((end - start) * t);

  static double _arcY(double start, double end, double t, Rect from, Rect to) {
    final base = _lerp(start, end, t);
    final lift = (t * (1 - t)) * 4 * (from.height > to.height ? from.height : to.height) * 0.75;
    return base - lift;
  }
}
