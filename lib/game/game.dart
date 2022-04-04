import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:redmtionfighter/game/bullet.dart';
import 'package:redmtionfighter/game/command.dart';
import 'package:redmtionfighter/game/enemy.dart';
import 'package:redmtionfighter/game/enemy_manager.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';
import 'package:redmtionfighter/game/player.dart';

class SpaceScapeGame extends BaseGame with HasCollidables, HasDraggableComponents {
  late Player _player;
  late SpriteSheet spriteSheet;
  late EnemyManager _enemyManager;

  late TextComponent _playerScore;
  late TextComponent _playerHealth;

  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  bool _isAlreadyLoaded = false;

  @override
  Future<void> onLoad() async {

    if (!_isAlreadyLoaded) {
      await images.load('simpleSpace_tilesheet@2.png');

      spriteSheet = SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('simpleSpace_tilesheet@2.png'), columns: 8, rows: 6);

      _player = Player(
          sprite: spriteSheet.getSpriteById(4), size: Vector2(64, 64), position: canvasSize / 2);

      _player.anchor = Anchor.center;

      add(_player);

      _enemyManager = EnemyManager(spriteSheet: spriteSheet);
      add(_enemyManager);

      final joyStick = JoystickComponent(
        gameRef: this,
        directional: JoystickDirectional(
          size: 100,
        ),
        actions: [
          JoystickAction(actionId: 0, size: 60, margin: const EdgeInsets.all(30)),
          JoystickAction(
              actionId: 1, size: 60, margin: const EdgeInsets.all(100), color: Colors.red)
        ],
      );
      joyStick.addObserver(_player);
      add(joyStick);

      _playerScore = TextComponent(
        'Score: 0',
        position: Vector2(10, 10),
        config: TextConfig(
          color: Colors.white,
          fontSize: 16,
        ),
      );
      _playerScore.isHud = true;
      add(_playerScore);
      _playerHealth = TextComponent(
        'Health: 100%',
        position: Vector2(size.x - 10, 10),
        config: TextConfig(
          color: Colors.white,
          fontSize: 16,
        ),
      );
      _playerHealth.anchor = Anchor.topRight;
      _playerHealth.isHud = true;
      add(_playerHealth);

      this.camera.shakeIntensity = 20;
      _isAlreadyLoaded =true;
    }



  }

  @override
  void prepare(Component c) {
    if (c is KnowsGameSize) {
      c.onReSize(size);
    }
    super.prepare(c);
  }
  @override
  void onResize(Vector2 canvasSize) {
    super.onResize(canvasSize);

    // Loop over all the components of type KnowsGameSize and resize then as well.
  components.whereType<KnowsGameSize>().forEach((component) {
      component.onReSize(this.size);
    });
  }


  @override
  void update(double dt) {
    super.update(dt);

    _commandList.forEach((command) {
      components.forEach((component) {
        command.run(component);
      });
    });

    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    _playerScore.text = 'Score: ${_player.score}';
    _playerHealth.text = 'Health: ${_player.health}%';
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(size.x - 110, 10, _player.health.toDouble(), 20),
        Paint()..color = Colors.blue);
    super.render(canvas);
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    _player.reset();
    _enemyManager.reset();

    components.whereType<Enemy>().forEach((enemy) {
      enemy.remove();
    });
    components.whereType<Bullet>().forEach((bullet) {
      bullet.remove();
    });
  }
}
