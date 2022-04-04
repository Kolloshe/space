import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:redmtionfighter/game/bullet.dart';
import 'package:redmtionfighter/game/command.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';
import 'package:redmtionfighter/game/player.dart';

class Enemy extends SpriteComponent
    with KnowsGameSize, Hitbox, Collidable, HasGameRef<SpaceScapeGame> {
  double _speed = 250;
  Random _random = Random();

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Enemy({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size) {
    angle = pi;
  }

  @override
  void onMount() {
    super.onMount();
    final shape = HitboxCircle(definition: 0.8);
    addShape(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet || other is Player) {
      destroy();
    }
  }

  void destroy() {
         this.remove();

    final command = Command<Player>(action: (player) {
      player.addToScore(1);
    });
    gameRef.addCommand(command);
    final particleComponent = ParticleComponent(
        particle: Particle.generate(
            count: 20,
            lifespan: 0.1,
            generator: (i) => AcceleratedParticle(
                acceleration: getRandomVector().toOffset(),
                speed: getRandomVector().toOffset(),
                position: this.position.clone().toOffset(),
                child: CircleParticle(
                  radius: 1.5,
                  paint: Paint()..color = Colors.white,
                ))));
    gameRef.add(particleComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    this.position += Vector2(0, 1) * _speed * dt;
    if (this.position.y > this.gameSize.y) {
      remove();
    }
  }
}
