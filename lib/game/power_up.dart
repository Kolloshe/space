import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:redmtionfighter/game/enemy_manager.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/player.dart';
import 'package:redmtionfighter/game/power_up_manager.dart';

import 'audio_player_component.dart';
import 'command.dart';
import 'enemy.dart';

abstract class PowerUp extends SpriteComponent with HasGameRef<SpaceScapeGame>, Hitbox, Collidable {
  late Timer _timer;

  Sprite getSprite();

  void onActivated();

  PowerUp({Vector2? position, Vector2? size, Sprite? sprite})
      : super(position: position, size: size, sprite: sprite) {
    _timer = Timer(3, callback: this.remove);
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onMount() {
    final shape = HitboxCircle(definition: 0.5);
    addShape(shape);

    this.sprite = getSprite();

   _timer.start();
    super.onMount();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is Player) {
      gameRef.addCommand(Command<AudioPlayerComponent>(action:(audioPlayer){
        audioPlayer.platSfx('powerUp6.ogg');
      }));

      onActivated();
      remove();
    }
    super.onCollision(intersectionPoints, other);
  }
}

class Nuke extends PowerUp{
  Nuke({
    Vector2? position,Vector2? size
}):super(position: position,size: size);
  @override
  Sprite getSprite() {
    return PowerUpManager.nukeSprite;
  }

  @override
  void onActivated() {
    final command = Command< Enemy>(action: (enemy) {
      enemy.destroy();
    });

    gameRef.addCommand(command);
  }
}

class Health extends PowerUp{
  Health({
    Vector2? position,Vector2? size
  }):super(position: position,size: size);
  @override
  Sprite getSprite() {
    return PowerUpManager.healthSprite;
  }

  @override
  void onActivated() {
    final command = Command<Player>(action: (player) {
      player.increaseHealthBy(10);
    });

    gameRef.addCommand(command);
  }
}

class Freeze extends PowerUp{
  Freeze({
    Vector2? position,Vector2? size
  }):super(position: position,size: size);
  @override
  Sprite getSprite() {
    return PowerUpManager.freezeSprite;
  }

  @override
  void onActivated() {
    final command1 = Command<Enemy>(action: (enemy) {
    enemy.freeze();
    });

    gameRef.addCommand(command1);
    final command2 = Command<EnemyManager>(action: (enemyManager) {
      enemyManager.freeze();
    });

    gameRef.addCommand(command2);

    final command3 = Command<PowerUpManager>(action: (powerUpManager) {
      powerUpManager.freeze();
    });

    gameRef.addCommand(command3);
  }



}

class MultiFire extends PowerUp{
  MultiFire({
    Vector2? position,Vector2? size
  }):super(position: position,size: size);
  @override
  Sprite getSprite() {
    return PowerUpManager.multiFireSprite;
  }

  @override
  void onActivated() {
    final command = Command<Player>(action: (player) {
      player.shootMultipleBullets();
    });
gameRef.addCommand(command);
  }
}