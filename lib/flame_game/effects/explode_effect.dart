import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../components/player.dart';

/// The [ExplodeEffect] is an effect that is composed of multiple different effects
/// that are added to the [Player] when it is hurt.
/// It spins the player, shoots it up in the air and makes it blink in white.
class ExplodeEffect extends Component with ParentIsA<Player> {
  // This is currently just tied to the longest animation and I'll work from there.
  Function() onComplete;
  ExplodeEffect(this.onComplete);

  @override
  void onMount() {
    super.onMount();
    const double effectTime = 0.5;
    const int repeatCount = 2;
    parent.addAll(
      [
        // ColorEffect(
        //   Colors.white,
        //   EffectController(
        //     duration: effectTime,
        //     alternate: true,
        //     repeatCount: repeatCount,
        //   ),
        //   opacityTo: 0.9,
        // ),
      ],
    );
    Future.delayed(
      Duration(milliseconds: (effectTime * repeatCount * 1000).toInt()),
    ).then(
      (value) => onComplete(),
    );
  }
}
