import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:rive_game_flutter/gameobjects/bullets.dart';
import 'package:rive_game_flutter/gameobjects/explosion.dart';
import 'package:rive_game_flutter/gameobjects/score.dart';
import 'package:rive_game_flutter/levels/level.dart';
import 'package:rive_game_flutter/gameobjects/meteor.dart';
import 'package:rive_game_flutter/gameobjects/player.dart';
import 'package:rive_game_flutter/gameobjects/vitals.dart';

class Level1 extends Level {
  late Player player;
  late Artboard _bulletArtboard;
  late Artboard _vitalsArtboard;
  late Artboard _scoreArtboard;
  late Vitals _vitals;
  late Timer _spawnMeteorTimer;
  late Artboard _explosionArtboard;
  late RiveFile _file;
  bool _canReset = false;
  late FpsTextComponent _fps;
  double _minMeteorVelocity = 50;
  double _maxMeteorVelocity = 100;
  late Score _score;
  final _meteorValue = 100;
  int _scoreValue = 0;

  @override
  FutureOr<void> onLoad() async {
    gameRef.world = this;

    _file = await RiveFile.asset('assets/riv/spaceshooter.riv');
    final playerArtboard = await loadArtboard(_file, artboardName: 'hero');
    _bulletArtboard = await loadArtboard(_file, artboardName: 'bullet');
    _vitalsArtboard = await loadArtboard(_file, artboardName: 'vitals');
    _scoreArtboard = await loadArtboard(_file, artboardName: 'score');
    _explosionArtboard =
        await loadArtboard(_file, artboardName: 'meteor explosion');

    player = Player(playerArtboard, this);
    add(player);

    add(ScreenHitbox());

    _vitals = Vitals(_vitalsArtboard);
    _vitals.position = Vector2(140, 50);
    gameRef.camera.viewport.add(_vitals);

    _fps = FpsTextComponent();
    _fps.anchor = Anchor.topRight;
    _fps.position = Vector2(gameRef.size.x - 30, 30);
    gameRef.camera.viewport.add(_fps);

    _score = Score(_scoreArtboard);
    _score.anchor = Anchor.topCenter;
    _score.position = Vector2(gameRef.size.x / 2, 30);
    gameRef.camera.viewport.add(_score);

    _spawnMeteorTimer = Timer(2.0);
    _spawnMeteorTimer.start();

    _canReset = true;

    return super.onLoad();
  }

  void addBullet(position, angle) {
    final bullet = Bullet(_bulletArtboard, position, angle);
    add(bullet);
  }

  void updateVitals(int health, int lives, String healthText) {
    _vitals.setHealth(health);
    _vitals.setLives(lives);
    _vitals.setHealthText(healthText);
  }

  @override
  void update(double dt) {
    _spawnMeteorTimer.update(dt);
    if (_spawnMeteorTimer.finished) {
      _spawnAstroid();
      _spawnMeteorTimer.start();
    }

    // add explosions for dead meteors
    final explosions = <Explosion>[];
    for (final meteor in children.query<Meteor>()) {
      if (meteor.isDead) {
        _scoreValue += _meteorValue;
        _score.updateScore(_scoreValue);
        explosions.add(Explosion(_explosionArtboard, meteor.position));
      }
    }
    addAll(explosions);

    //remove dead meteors
    removeAll(children.query<Meteor>().where((meteor) => meteor.isDead));

    // remove offscreen meteors
    removeAll(children
        .query<Meteor>()
        .where((meteor) => meteor.canBeRemovedAfterOffscreen()));

    // remove done explosions
    removeAll(
        children.query<Explosion>().where((explosion) => explosion.isDone));

    // remove dead bullets
    removeAll(children.query<Bullet>().where((bullet) => bullet.isDead));
    // remove offscreen bullets
    removeAll(children.query<Bullet>().where((bullet) {
      return bullet.position.x < 0 ||
          bullet.position.x > gameRef.size.x ||
          bullet.position.y < 0 ||
          bullet.position.y > gameRef.size.y;
    }));

    super.update(dt);
  }

  @override
  void onRemove() {
    _spawnMeteorTimer.stop();
    super.onRemove();
  }

  Future<void> _spawnAstroid() async {
    final _meteorArtboard = await loadArtboard(_file, artboardName: 'meteor');
    final meteor = Meteor(
      artboard: _meteorArtboard,
      target: player.position,
      minVelocity: _minMeteorVelocity,
      maxVelocity: _maxMeteorVelocity,
    );
    add(meteor);
  }

  void reset() {
    player.reset();
    _vitals.reset();
    _spawnMeteorTimer.reset();
    _score.reset();
    _fps.position = Vector2(gameRef.size.x - 30, 30);

    removeAll(children.query<Meteor>());
    removeAll(children.query<Bullet>());
    removeAll(children.query<Explosion>());
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_canReset) {
      reset();
    }
  }
}
