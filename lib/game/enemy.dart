import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:redmtionfighter/game/audio_player_component.dart';
import 'package:redmtionfighter/game/bullet.dart';
import 'package:redmtionfighter/game/command.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';
import 'package:redmtionfighter/game/player.dart';
import 'package:redmtionfighter/models/enemy_data.dart';

class Enemy extends SpriteComponent
    with KnowsGameSize, Hitbox, Collidable, HasGameRef<SpaceScapeGame> {
  double _speed = 250;

  Vector2 moveDirection = Vector2(0, 1);

  late Timer _freezeTimer;

  Random _random = Random();

  final EnemyData enemyData;

  int _hitPoints = 10;

  TextComponent _hpText = TextComponent(
    '10 HP',
    textRenderer: TextPaint(
        config: const TextPaintConfig(
      color: Colors.white,
      fontSize: 12,
    )),
  );

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Vector2 getRandomDirection() {
    return (Vector2.random(_random) - Vector2(0.5, -1).normalized());
  }

  Enemy({
    required Sprite? sprite,
    required this.enemyData,
    required Vector2? position,
    required Vector2? size,
  }) : super(sprite: sprite, position: position, size: size) {
    angle = pi;
    _speed = enemyData.speed;

    _hitPoints = enemyData.level * 10;
    _hpText.text = '$_hitPoints HP';

    _freezeTimer = Timer(2, callback: () {
      _speed = enemyData.speed;
    });
    if (enemyData.hMove) {
      moveDirection = getRandomDirection();
    }
  }

  @override
  void onMount() {
    super.onMount();
    final shape = HitboxCircle(definition: 0.8);
    addShape(shape);
    _hpText.angle = pi;
    _hpText.position =  Vector2(50,80);
    addChild(_hpText);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet) {
      _hitPoints -= other.level * 10;
    } else if (other is Player) {
      _hitPoints = 0;
    }
  }

  void destroy() {
    this.remove();

    gameRef.addCommand(Command<AudioPlayerComponent>(action:(audioPlayer){
      audioPlayer.platSfx('laser1.ogg');
    }));


    final command = Command<Player>(action: (player) {
      player.addToScore(enemyData.killPoint);
    });
    gameRef.addCommand(command);
    final particleComponent = ParticleComponent(
        particle: Particle.generate(
            count: 20,
            lifespan: 0.1,
            generator: (i) => AcceleratedParticle(
                acceleration: getRandomVector(),
                speed: getRandomVector(),
                position: this.position.clone(),
                child: CircleParticle(
                  radius: 1.5,
                  paint: Paint()..color = Colors.white,
                ))));
    gameRef.add(particleComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _hpText.text = '$_hitPoints HP';

    if (_hitPoints <= 0) {
      destroy();
    }

    _freezeTimer.update(dt);
    this.position += moveDirection * _speed * dt;
    if (this.position.y > this.gameSize.y) {
      remove();
    } else if ((this.position.x < this.size.x / 2 ||
        (this.position.x > (this.gameSize.x - size.x / 2)))) {
      moveDirection.x *= -1;
    }
  }

  void freeze() {
    _speed = 0;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
