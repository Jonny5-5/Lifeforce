import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../components/player.dart';

class ResurrectEffect extends Component with ParentIsA<Player> {
  // This is currently just tied to the longest animation and I'll work from there.
  Function() onComplete;
  ResurrectEffect(this.onComplete);

  @override
  void onMount() {
    super.onMount();
    const double effectTime = 1.0;
    const int repeatCount = 2;
    Path path = Path();
    path.lineTo(300, 0);

    parent.addAll(
      [
        MoveToEffect(
          Vector2(-800, 0),
          EffectController(duration: 0),
        ),
        MoveAlongPathEffect(
          path,
          EffectController(
            duration: effectTime,
            curve: Curves.easeOut,
          ),
          onComplete: removeFromParent,
        ),
        ColorEffect(
          Colors.white,
          EffectController(
            duration: effectTime,
            alternate: true,
            curve: Curves.easeIn,
          ),
          opacityTo: 0.9,
        ),
      ],
    );
    Future.delayed(
      Duration(milliseconds: effectTime.toInt() * repeatCount * 1000),
    ).then(
      (value) => onComplete(),
    );
  }
}
