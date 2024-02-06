import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

/// The [FlyEffect] is simply a [MoveByEffect] which has the properties of the
/// effect pre-defined.
class FlyEffect extends MoveByEffect {
  FlyEffect(Vector2 offset)
      : super(
            offset, EffectController(duration: 0.1, curve: Curves.decelerate));
}
