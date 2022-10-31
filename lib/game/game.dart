import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmtionfighter/game/audio_player_component.dart';
import 'package:redmtionfighter/game/bullet.dart';
import 'package:redmtionfighter/game/command.dart';
import 'package:redmtionfighter/game/enemy.dart';
import 'package:redmtionfighter/game/enemy_manager.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';
import 'package:redmtionfighter/game/player.dart';
import 'package:redmtionfighter/game/power_up.dart';
import 'package:redmtionfighter/game/power_up_manager.dart';
import 'package:redmtionfighter/models/player_data.dart';
import 'package:redmtionfighter/models/spaceship_details.dart';
import 'package:redmtionfighter/widgets/overlays/game_over_menu.dart';
import 'package:redmtionfighter/widgets/overlays/pause_button.dart';
import 'package:redmtionfighter/widgets/overlays/pausemenu.dart';

class SpaceScapeGame extends BaseGame with HasCollidables, HasDraggableComponents {
  late Player _player;
  late SpriteSheet spriteSheet;
  late EnemyManager _enemyManager;
  late PowerUpManager _powerUpManager;

  late AudioPlayerComponent _audioPlayerComponent;

  late TextComponent _playerScore;
  late TextComponent _playerHealth;

  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  bool _isAlreadyLoaded = false;

  @override
  Future<void> onLoad() async {
    if (!_isAlreadyLoaded) {
      await images.loadAll([
        'simpleSpace_tilesheet@2.png',
        'freeze.png',
        'multi_fire.png',
        'nuke.png',
        'icon_plusSmall.png'
      ]);

      _audioPlayerComponent = AudioPlayerComponent();
      add(_audioPlayerComponent);
      spriteSheet = SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('simpleSpace_tilesheet@2.png'), columns: 8, rows: 6);

      ParallaxComponent _stars = await ParallaxComponent.load([
        ParallaxImageData('stars1.png'),
        ParallaxImageData('stars2.png'),
      ],
      repeat: ImageRepeat.repeat,
      baseVelocity: Vector2(0, -50,),
      velocityMultiplierDelta: Vector2(0, 1.5));
      add(_stars);
      final spaceType = SpaceshipType.Canary;
      final spaceship = Spaceship.getSpaceshipByType(SpaceshipType.Canary);

      _player = Player(
          spaceshipType: spaceType,
          sprite: spriteSheet.getSpriteById(spaceship.spriteId),
          size: Vector2(64, 64),
          position: canvasSize / 2);

      _player.anchor = Anchor.center;

      add(_player);

      _enemyManager = EnemyManager(spriteSheet: spriteSheet);
      add(_enemyManager);

      _powerUpManager = PowerUpManager();
      add(_powerUpManager);

      final joyStick = JoystickComponent(
        gameRef: this,
        directional: JoystickDirectional(
          size: 100,
        ),
        actions: [
          JoystickAction(actionId: 0, size: 60, margin: const EdgeInsets.all(30)),
        ],
      );
      joyStick.addObserver(_player);
      add(joyStick);

      _playerScore = TextComponent(
        'Score: 0',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
            config: const TextPaintConfig(
          color: Colors.white,
          fontSize: 16,
        )),
      );
      _playerScore.isHud = true;
      add(_playerScore);
      _playerHealth = TextComponent(
        'Health: 100%',
        position: Vector2(size.x - 10, 10),
        textRenderer: TextPaint(
            config: const TextPaintConfig(
          color: Colors.white,
          fontSize: 16,
        )),
      );
      _playerHealth.anchor = Anchor.topRight;
      _playerHealth.isHud = true;
      add(_playerHealth);

      _isAlreadyLoaded = true;
    }
  }

  @override
  void onAttach() {
    if (buildContext != null) {
      final playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      _player.setSpaceshipType(playerData.spaceshipType);
    }
    _audioPlayerComponent.playBgm('FlangerParty.wav');
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
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
    if (_player.health <= 0 && (!camera.shaking)) {
      this.pauseEngine();
      this.overlays.remove(PauseButton.ID);
      this.overlays.add(GameOverMenu.ID);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(size.x - 110, 10, _player.health.toDouble(), 20),
        Paint()..color = Colors.blue);
    super.render(canvas);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:

      case AppLifecycleState.paused:

      case AppLifecycleState.detached:
        if (this._player.health > 0) {
          this.pauseEngine();
          this.overlays.remove(PauseButton.ID);
          this.overlays.add(PauseMenu.ID);
        }
        break;
    }
    super.lifecycleStateChange(state);
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    _player.reset();
    _enemyManager.reset();
    _powerUpManager.reset();

    components.whereType<Enemy>().forEach((enemy) {
      enemy.remove();
    });
    components.whereType<Bullet>().forEach((bullet) {
      bullet.remove();
    });
    components.whereType<PowerUp>().forEach((powerUp) {
      powerUp.remove();
    });
  }
}
