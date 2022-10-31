import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:provider/provider.dart';
import 'package:redmtionfighter/game/enemy.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';
import 'package:redmtionfighter/game/player.dart';
import 'package:redmtionfighter/models/enemy_data.dart';
import 'package:redmtionfighter/models/player_data.dart';

class EnemyManager extends BaseComponent with KnowsGameSize, HasGameRef<SpaceScapeGame> {
  late Timer _timer;
  late Timer _freezeTimer;
  SpriteSheet spriteSheet;
  Random random = Random();

  EnemyManager({required this.spriteSheet}) : super() {
    _timer = Timer(1, callback: _spawnEnemy, repeat: true);
    _freezeTimer = Timer(2, callback: () {
      _timer.start();
    });
  }

  void _spawnEnemy() {
    Vector2 initaialSize = Vector2(64, 64);

    Vector2 position = Vector2(random.nextDouble() * gameSize.x, 0);

    position.clamp(Vector2.zero() + initaialSize / 2, gameSize - initaialSize / 2);

    if (gameRef.buildContext != null) {
      int currentScore = Provider.of<PlayerData>(gameRef.buildContext!,listen: false).currentScore;
      int maxLevel = mapScoreToMaxEnemyLevel(currentScore);
      final enemyData = _enemyDataList.elementAt(random.nextInt(maxLevel * 4));
      Enemy enemy = Enemy(
          sprite: this.spriteSheet.getSpriteById(enemyData.spriteId),
          position: position,
          size: initaialSize,
          enemyData: enemyData);
      enemy.anchor = Anchor.center;
      gameRef.add(enemy);
    }
  }

  int mapScoreToMaxEnemyLevel(int score) {
    int level = 1;
    if (score > 1500) {
      level = 4;
    } else if (score > 500) {
      level = 3;
    } else if (score > 100) {
      level = 2;
    }

    return level;
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
    _freezeTimer.update(dt);
  }

  void reset() {
    _timer.stop();
    _timer.start();
  }

  void freeze() {
    _timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }

  static const List<EnemyData> _enemyDataList = [
    EnemyData(
      killPoint: 1,
      speed: 200,
      spriteId: 8,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 2,
      speed: 200,
      spriteId: 9,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 4,
      speed: 200,
      spriteId: 10,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 4,
      speed: 200,
      spriteId: 11,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 250,
      spriteId: 12,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 250,
      spriteId: 13,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 250,
      spriteId: 14,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 250,
      spriteId: 15,
      level: 2,
      hMove: true,
    ),
    EnemyData(
      killPoint: 10,
      speed: 350,
      spriteId: 16,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 350,
      spriteId: 17,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 400,
      spriteId: 18,
      level: 3,
      hMove: true,
    ),
    EnemyData(
      killPoint: 10,
      speed: 400,
      spriteId: 19,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 400,
      spriteId: 20,
      level: 4,
      hMove: false,
    ),
    EnemyData(
      killPoint: 50,
      speed: 250,
      spriteId: 21,
      level: 4,
      hMove: true,
    ),
    EnemyData(
      killPoint: 50,
      speed: 250,
      spriteId: 22,
      level: 4,
      hMove: false,
    ),
    EnemyData(
      killPoint: 50,
      speed: 250,
      spriteId: 23,
      level: 4,
      hMove: false,
    )
  ];
}
