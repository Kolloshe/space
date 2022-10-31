import 'dart:math';

import 'package:flame/components.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';
import 'package:redmtionfighter/game/power_up.dart';

enum PowerUpTypes { health, freeze, nuke, multiFire }

class PowerUpManager extends BaseComponent with KnowsGameSize, HasGameRef<SpaceScapeGame> {
  late Timer _spawnTimer;
  late Timer _freezeTimer;

  Random random = Random();

  static late Sprite healthSprite;
  static late Sprite nukeSprite;
  static late Sprite freezeSprite;
  static late Sprite multiFireSprite;

  static Map<PowerUpTypes, PowerUp Function(Vector2 position, Vector2 size)> _powerUpMap = {
    PowerUpTypes.health: (position, size) => Health(position: position, size: size),
    PowerUpTypes.freeze: (position, size) => Freeze(position: position, size: size),
    PowerUpTypes.nuke: (position, size) => Nuke(position: position, size: size),
    PowerUpTypes.multiFire: (position, size) => MultiFire(position: position, size: size),
  };

  PowerUpManager() : super() {
    _spawnTimer = Timer(5, callback: _spawnPowerUp, repeat: true);
    _freezeTimer = Timer(2, callback: () {
      _spawnTimer.start();
    });
  }

  void _spawnPowerUp() {
    Vector2 initaialSize = Vector2(64, 64);

    Vector2 position = Vector2(random.nextDouble() * gameSize.x, random.nextDouble() * gameSize.y);

    position.clamp(Vector2.zero() + initaialSize / 2, gameSize - initaialSize / 2);

    int randomIndex = random.nextInt(PowerUpTypes.values.length);
    final fu = _powerUpMap[PowerUpTypes.values.elementAt(randomIndex)];
    var powerUp = fu?.call(position, initaialSize);
    powerUp?.anchor = Anchor.center;
    if (powerUp != null) {
      gameRef.add(powerUp);
    }
  }

  @override
  void onMount() {
    _spawnTimer.start();

    healthSprite = Sprite(gameRef.images.fromCache('icon_plusSmall.png'));
    nukeSprite = Sprite(gameRef.images.fromCache('nuke.png'));
    freezeSprite = Sprite(gameRef.images.fromCache('freeze.png'));
    multiFireSprite = Sprite(gameRef.images.fromCache('multi_fire.png'));

    super.onMount();
  }

  @override
  void onRemove() {
    super.onRemove();
    _spawnTimer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer.update(dt);
    _freezeTimer.update(dt);
  }

  void reset() {
    _spawnTimer.stop();
    _spawnTimer.start();
  }

  void freeze() {
    _spawnTimer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
