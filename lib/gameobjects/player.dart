import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/services.dart';
import 'package:rive_game_flutter/game/game.dart';
import 'package:rive_game_flutter/levels/level.dart';
import 'package:rive_game_flutter/gameobjects/meteor.dart';

const moveSpeed = 300.0;
const rotationSpeed = 2;

typedef MoveCallback = void Function(Vector2 position);

class Player extends RiveComponent
    with HasGameRef<SpaceshooterGame>, KeyboardHandler, CollisionCallbacks {
  Vector2 _direction = Vector2.zero();
  double _turnDirection = 0;
  late StateMachineController _controller;
  var _health = 100;
  var _lives = 3;
  get health => _health;
  get lives => _lives;
  late Timer _shootCooldownTimer;
  double _middleBulletSpawnDistance = 0.0;
  Level world;
  MoveCallback? moveCallback;

  Player(Artboard artboard, this.world, this.moveCallback)
      : super(artboard: artboard);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    position = gameRef.size / 2;
    artboard.addController(_controller);
    _shootCooldownTimer = Timer(0.3);
    _shootCooldownTimer.start();
    _middleBulletSpawnDistance = artboard.height / 2 + 30.0;

    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _direction = Vector2(
        sin(angle),
        -cos(angle),
      ).normalized();
    } else {
      _direction = Vector2.zero();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _turnDirection = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _turnDirection = 1;
    } else {
      _turnDirection = 0;
    }

    return false;
  }

  @override
  void update(double dt) {
    position += _direction * moveSpeed * dt;
    angle += _turnDirection * rotationSpeed * dt;

    _shootCooldownTimer.update(dt);
    shoot();

    moveCallback?.call(position);

    super.update(dt);
  }

  void shoot() {
    if (!_shootCooldownTimer.finished) {
      return;
    }

    final middleBulletSpawnPosition = Vector2(
      position.x + sin(angle) * _middleBulletSpawnDistance,
      position.y + cos(angle) * -_middleBulletSpawnDistance,
    );
    world.addBullet(middleBulletSpawnPosition, angle);

    _shootCooldownTimer.start();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Meteor) {
      other.removeFromParent();

      _health -= 10;

      if (_health <= 0) {
        _lives -= 1;
        _health = 100;
      }

      if (_lives <= 0) {
        world.reset();
      }

      world.updateVitals(_health, _lives, '$_health%');
    }

    if (other is ScreenHitbox) {
      if (position.x - artboard.width < 0) {
        position.x = artboard.width;
      } else if (position.x + artboard.width > gameRef.size.x) {
        position.x = gameRef.size.x - artboard.width;
      } else if (position.y - artboard.height < 0) {
        position.y = artboard.height;
      } else if (position.y + artboard.height > gameRef.size.y) {
        position.y = gameRef.size.y - artboard.height;
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onRemove() {
    _shootCooldownTimer.stop();
    super.onRemove();
  }

  void reset() {
    _health = 100;
    _lives = 3;
    _shootCooldownTimer.reset();
    position = gameRef.size / 2;
  }
}
