import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:life_force/flame_game/effects/explode_effect.dart';
import 'package:life_force/flame_game/effects/fly_effect.dart';

import '../../audio/sounds.dart';
import '../endless_runner.dart';
import '../endless_world.dart';
import '../effects/hurt_effect.dart';
import '../effects/jump_effect.dart';
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
      PlayerState.running: await game.loadSpriteAnimation(
        'dash/dash_spritesheet.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2.all(16),
          stepTime: 0.15,
        ),
      ),
      PlayerState.jumping: SpriteAnimation.spriteList(
        [await game.loadSprite('dash/dash_jumping.png')],
        stepTime: double.infinity,
      ),
      PlayerState.falling: SpriteAnimation.spriteList(
        [await game.loadSprite('dash/dash_falling.png')],
        stepTime: double.infinity,
      ),
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
          loop: false,
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

    if (_lastPosition.y > position.y) {
      current = PlayerState.flyingUp;
    } else if (_lastPosition.y < position.y) {
      current = PlayerState.flyingDown;
    } else {
      // current = PlayerState.flying;
    }

    _lastPosition.setFrom(position);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // When the player collides with an obstacle it should lose all its points.
    if (other is Obstacle) {
      game.audioController.playSfx(SfxType.damage);
      resetScore();
      add(ExplodeEffect());
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
    if (_lastPosition.y > vector.y) {
      current = PlayerState.flyingUp;
    } else {
      current = PlayerState.flyingDown;
    }

    position.x = vector.x;
    position.y = vector.y;

    // TODO: Make this work
    // final effect = FlyEffect(vector);
    // add(effect);
  }
}

enum PlayerState {
  running,
  jumping,
  falling,
  flying,
  flyingUp,
  flyingDown,
  exploding,
}
