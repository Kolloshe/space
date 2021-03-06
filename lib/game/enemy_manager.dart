import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:redmtionfighter/game/enemy.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';

class EnemyManager extends BaseComponent with KnowsGameSize, HasGameRef<SpaceScapeGame> {
  late Timer _timer;
  SpriteSheet spriteSheet;
  Random random = Random();

  EnemyManager({required this.spriteSheet}) : super() {
    _timer = Timer(1, callback: _spawnEnemy, repeat: true);
  }

  void _spawnEnemy() {
    Vector2 initaialSize = Vector2(64, 64);

    Vector2 position = Vector2(random.nextDouble() * gameSize.x, 0);

    position.clamp(Vector2.zero() + initaialSize / 2, gameSize - initaialSize / 2);

    Enemy enemy =
        Enemy(sprite: this.spriteSheet.getSpriteById(12), position: position, size: initaialSize);
    enemy.anchor = Anchor.center;
    gameRef.add(enemy);
  }

  @override
  void onMount() {
    super.onMount();
    _timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    _timer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }


  void reset () {
    _timer.stop();
    _timer.start();
  }
}
