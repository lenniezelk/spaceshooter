import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:rive_game_flutter/gameobjects/bullets.dart';
import 'package:rive_game_flutter/game/game.dart';

const minRotationSpeed = 0.1;
const maxRotationSpeed = 1.0;

final random = Random();

enum MeteorState {
  live,
  dead,
}

class Meteor extends RiveComponent
    with HasGameRef<SpaceshooterGame>, CollisionCallbacks {
  late StateMachineController _controller;
  late Vector2 _movement;
  late double _rotationSpeed;
  late SMINumber _rock;
  Vector2 target;
  late Timer _lifeTimer;
  MeteorState _meteorState = MeteorState.live;
  double minVelocity;
  double maxVelocity;

  Meteor(
      {required Artboard artboard,
      required this.target,
      required this.minVelocity,
      required this.maxVelocity})
      : super(artboard: artboard);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    artboard.addController(_controller);

    final radius = gameRef.size.x / 2;
    final angle = random.nextDouble() * 2 * pi;
    position = Vector2(
      target.x + cos(angle) * radius,
      target.y + sin(angle) * radius,
    );

    final _velocity =
        minVelocity + random.nextDouble() * (maxVelocity - minVelocity);
    final _direction = (target - position).normalized();
    _movement = _direction * _velocity;

    final randomValue = random.nextDouble();
    _rotationSpeed = minRotationSpeed +
        randomValue *
            (maxRotationSpeed - minRotationSpeed) *
            (randomValue > 0.5 ? 1 : -1);

    _rock = _controller.findInput<double>('rock') as SMINumber;
    _rock.value = random.nextDouble() > 0.5 ? 1 : 2;

    _lifeTimer = Timer(5.0);

    add(CircleHitbox());

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      _meteorState = MeteorState.dead;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    _lifeTimer.update(dt);

    position += _movement * dt;
    angle += _rotationSpeed * dt;

    super.update(dt);
  }

  bool canBeRemovedAfterOffscreen() {
    if ((position.x < 0 ||
            position.x > gameRef.size.x ||
            position.y < 0 ||
            position.y > gameRef.size.y) &&
        _lifeTimer.finished) {
      return true;
    }
    return false;
  }

  bool get isDead => _meteorState == MeteorState.dead;
}
