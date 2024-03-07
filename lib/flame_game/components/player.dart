import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:life_force/flame_game/effects/explode_effect.dart';
import 'package:life_force/flame_game/effects/resurrect_effect.dart';

import '../../audio/sounds.dart';
import '../endless_runner.dart';
import '../endless_world.dart';
import 'obstacle.dart';
import 'point.dart';

/// The [Player] is the component that the physical player of the game is
/// controlling.
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        CollisionCallbacks,
        HasWorldReference<EndlessWorld>,
        HasGameReference<EndlessRunner> {
  Player({
    required this.addScore,
    required this.resetScore,
    super.position,
  }) : super(size: Vector2(96, 48), anchor: Anchor.center, priority: 1);

  final void Function({int amount}) addScore;
  final VoidCallback resetScore;

  // Used to store the last position of the player, so that we later can
  // determine which direction that the player is moving.
  final Vector2 _lastPosition = Vector2.zero();

  // When the player has velocity pointing downwards it is counted as falling,
  // this is used to set the correct animation for the player.
  bool get isFalling => _lastPosition.y < position.y;

  @override
  Future<void> onLoad() async {
    // This defines the different animation states that the player can be in.
    animations = {
      PlayerState.flying: await game.loadSpriteAnimation(
        'ship/ship_spritesheet.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2.all(24),
          stepTime: 0.15,
        ),
      ),
      PlayerState.flyingUp: SpriteAnimation.spriteList(
        [await game.loadSprite('ship/ship_up.png')],
        stepTime: double.infinity,
      ),
      PlayerState.flyingDown: SpriteAnimation.spriteList(
        [await game.loadSprite('ship/ship_down.png')],
        stepTime: double.infinity,
      ),
      PlayerState.exploding: await game.loadSpriteAnimation(
        'ship/explode_spritesheet_28x18.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(28, 18),
          stepTime: 0.15,
          loop: true,
        ),
      ),
      // Same as the fly state. The ResurrectEffect will make the ship flash
      PlayerState.resurrect: await game.loadSpriteAnimation(
        'ship/ship_spritesheet.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2.all(24),
          stepTime: 0.15,
        ),
      ),
    };
    // The starting state will be that the player is flying.
    current = PlayerState.flying;
    position.y = height / 2;
    _lastPosition.setFrom(position);

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing
    // it.
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (current
        case PlayerState.flying ||
            PlayerState.flyingUp ||
            PlayerState.flyingDown) {
      if (_lastPosition.y > position.y) {
        current = PlayerState.flyingUp;
      } else if (_lastPosition.y < position.y) {
        current = PlayerState.flyingDown;
      } else {
        current = PlayerState.flying;
      }
    } else if (current case PlayerState.exploding) {
      // Do nothing...
    } else if (current case PlayerState.resurrect) {
      // Do nothing...
    } else if (current case null) {
      // Then there's an error...
      current = PlayerState.flying;
    }

    _lastPosition.setFrom(position);
  }

  /// This is called when the player has finished resurrecting.
  void onResurrectComplete() {
    print("Resurrect complete");
    current = PlayerState.flying;
  }

  // This happens when the player is done exploding
  // Make the player resurrect and then flying when the effect is done.
  void onExplodeComplete() {
    print("Explode complete");
    current = PlayerState.resurrect;
    add(ResurrectEffect(onResurrectComplete));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (current != PlayerState.flying &&
        current != PlayerState.flyingUp &&
        current != PlayerState.flyingDown) {
      // Then we don't detect a colision
      return;
    }
    super.onCollisionStart(intersectionPoints, other);
    // When the player collides with an obstacle it should lose all its points.
    if (other is Obstacle) {
      game.audioController.playSfx(SfxType.damage);
      resetScore();
      add(ExplodeEffect(onExplodeComplete));
      current = PlayerState.exploding;
    } else if (other is Point) {
      // When the player collides with a point it should gain a point and remove
      // the `Point` from the game.
      game.audioController.playSfx(SfxType.score);
      other.removeFromParent();
      addScore();
    }
  }

  void fly(Vector2 vector) {
    if (current == PlayerState.exploding) {
      return;
    }
    position.x = vector.x;
    position.y = vector.y;

    // TODO: Make this work
    // final effect = FlyEffect(vector);
    // add(effect);
  }
}

enum PlayerState {
  flying,
  flyingUp,
  flyingDown,
  exploding,
  resurrect,
}
