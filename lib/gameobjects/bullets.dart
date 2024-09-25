import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';

const bulletSpeed = 1000.0;

enum BulletState {
  live,
  dead,
}

class Bullet extends RiveComponent {
  late StateMachineController _controller;
  Vector2 spawnPosition;
  double spawnRotation;
  BulletState _state = BulletState.live;

  Bullet(Artboard artboard, this.spawnPosition, this.spawnRotation)
      : super(artboard: artboard);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    artboard.addController(_controller);
    position = spawnPosition;
    angle = spawnRotation;

    add(RectangleHitbox(collisionType: CollisionType.passive));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    final direction = Vector2(
      sin(angle),
      -cos(angle),
    ).normalized();

    position += direction * bulletSpeed * dt;

    super.update(dt);
  }

  void kill() {
    _state = BulletState.dead;
  }

  bool get isDead => _state == BulletState.dead;
}
