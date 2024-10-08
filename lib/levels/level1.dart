import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:rive_game_flutter/gameobjects/bullets.dart';
import 'package:rive_game_flutter/gameobjects/explosion.dart';
import 'package:rive_game_flutter/gameobjects/score.dart';
import 'package:rive_game_flutter/gameobjects/stage.dart';
import 'package:rive_game_flutter/levels/level.dart';
import 'package:rive_game_flutter/gameobjects/meteor.dart';
import 'package:rive_game_flutter/gameobjects/player.dart';
import 'package:rive_game_flutter/gameobjects/vitals.dart';
import 'package:rive_game_flutter/levels/level1_bg.dart';

class Level1 extends Level {
  late Player _player;

  late RiveFile _file;

  late Artboard _bulletArtboard;
  late Artboard _vitalsArtboard;
  late Artboard _scoreArtboard;
  late Artboard _stageArtboard;
  late Artboard _explosionArtboard;
  late Artboard _bgArtboard;
  late Level1Bg _bg;

  late Vitals _vitals;
  late Stage _stage;
  late Score _score;
  late FpsTextComponent _fps;

  late Timer _spawnMeteorTimer;

  bool _canReset = false;
  double _minMeteorVelocity = 50;
  double _maxMeteorVelocity = 100;
  final _meteorValue = 100;
  int _scoreValue = 0;
  int _destroyedMeteors = 0;

  int _difficultyLevel = 1;
  final _maxTime = 3.0;
  final _maxDifficultyLevel = 10;

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
    _stageArtboard = await loadArtboard(_file, artboardName: 'stage');
    _bgArtboard = await loadArtboard(_file, artboardName: 'level1 bg');
    _bgArtboard.frameOrigin = false;

    _bg = Level1Bg(_bgArtboard);
    gameRef.camera.backdrop = _bg;

    _player = Player(playerArtboard, this, moveBg);
    add(_player);

    _vitals = Vitals(_vitalsArtboard);
    _vitals.position = Vector2(140, 50);
    gameRef.camera.viewport.add(_vitals);

    _fps = FpsTextComponent();
    _fps.anchor = Anchor.topRight;
    _fps.position = Vector2(gameRef.size.x - 30, 40);
    gameRef.camera.viewport.add(_fps);

    _score = Score(_scoreArtboard);
    _score.anchor = Anchor.topCenter;
    _score.position = Vector2(gameRef.size.x / 2, 40);
    gameRef.camera.viewport.add(_score);

    _stage = Stage(_stageArtboard);
    _stage.anchor = Anchor.topCenter;
    _stage.position = Vector2(gameRef.size.x / 2, 100);
    _stage.updateStage(_difficultyLevel);
    gameRef.camera.viewport.add(_stage);

    _spawnMeteorTimer = Timer(_maxTime);
    _spawnMeteorTimer.start();

    _canReset = true;

    add(ScreenHitbox());

    return super.onLoad();
  }

  @override
  void addBullet(position, angle) {
    final bullet = Bullet(_bulletArtboard, position, angle);
    add(bullet);
  }

  @override
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
        if (++_destroyedMeteors >= 10) {
          _updateDifficultyLevel();
        }
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
      target: _player.position,
      minVelocity: _minMeteorVelocity,
      maxVelocity: _maxMeteorVelocity,
    );
    add(meteor);
  }

  @override
  void reset() {
    _player.reset();
    _vitals.reset();
    _spawnMeteorTimer.reset();
    _score.reset();
    _fps.position = Vector2(gameRef.size.x - 30, 30);
    _stage.position = Vector2(gameRef.size.x / 2, 100);
    _score.position = Vector2(gameRef.size.x / 2, 40);
    _scoreValue = 0;
    _destroyedMeteors = 0;
    _difficultyLevel = 1;
    _minMeteorVelocity = 50;
    _maxMeteorVelocity = 100;
    _spawnMeteorTimer = Timer(_maxTime);
    _spawnMeteorTimer.start();
    _stage.reset();

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

  void _updateDifficultyLevel() {
    if (++_difficultyLevel > _maxDifficultyLevel) {
      reset();
      return;
    }
    _minMeteorVelocity += 10;
    _maxMeteorVelocity += 10;
    _destroyedMeteors = 0;
    _spawnMeteorTimer.stop();
    _spawnMeteorTimer = Timer(_maxTime - _difficultyLevel * 0.2);
    _spawnMeteorTimer.start();
    _stage.updateStage(_difficultyLevel);
  }

  void moveBg(Vector2 position) {
    final centerX = gameRef.size.x / 2;
    final centerY = gameRef.size.y / 2;

    final x = ((position.x - centerX) / centerX) * 100;
    final y = ((position.y - centerY) / centerY) * 100;

    _bg.move(x, y);
  }
}
