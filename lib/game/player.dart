import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:redmtionfighter/game/enemy.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';

import 'bullet.dart';

class Player extends SpriteComponent
    with KnowsGameSize, Hitbox, Collidable, JoystickListener, HasGameRef<SpaceScapeGame> {
  Vector2 _moveDirection = Vector2.zero();

  double _speed = 300;

  int score = 0 ;
  int health = 100;


  Random _random = Random();

  Vector2 getRandomVector() {
    return (Vector2.random(_random)- Vector2(0.5,-1))*300;
  }

  Player({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size);

  @override
  void onMount() {
    super.onMount();
    final shape = HitboxCircle(definition: 0.8);
    addShape(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy)
    {


gameRef.camera.shake();

     health -=10;
     if(health<=0)
     {
       health=0;
     }

    }
  }

  @override
  void update(double dt) {
    this.position += _moveDirection.normalized() * _speed * dt;

    this.position.clamp(Vector2.zero() + size / 2, gameSize - size / 2);

    final particleComponent = ParticleComponent(
        particle: Particle.generate(
            count: 10,
            lifespan: 0.1,
            generator: (i) => AcceleratedParticle(
              acceleration: getRandomVector().toOffset(),
                    speed: getRandomVector().toOffset(),
                    position: (this.position.clone() + Vector2 (0,this.size.y/3)).toOffset(),
                    child: CircleParticle(
                  radius: 1,
                  paint: Paint()..color = Colors.white,
                ))));
    gameRef.add(particleComponent);
    super.update(dt);
  }

  void setMoveDirection(Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.down) {
      Bullet bullet = Bullet(
          sprite: gameRef.spriteSheet.getSpriteById(28),
          size: Vector2(64, 64),
          position: this.position.clone());
      bullet.anchor = Anchor.center;
      gameRef.add(bullet);
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    switch (event.directional) {
      case JoystickMoveDirectional.moveUp:
        this.setMoveDirection(Vector2(0, -1));
        break;
      case JoystickMoveDirectional.moveUpLeft:
        this.setMoveDirection(Vector2(-1, -1));
        break;
      case JoystickMoveDirectional.moveUpRight:
        this.setMoveDirection(Vector2(1, -1));
        break;
      case JoystickMoveDirectional.moveRight:
        this.setMoveDirection(Vector2(1, 0));
        break;
      case JoystickMoveDirectional.moveDown:
        this.setMoveDirection(Vector2(0, 1));
        break;
      case JoystickMoveDirectional.moveDownRight:
        this.setMoveDirection(Vector2(1, 1));
        break;
      case JoystickMoveDirectional.moveDownLeft:
        this.setMoveDirection(Vector2(-1, 1));
        break;
      case JoystickMoveDirectional.moveLeft:
        this.setMoveDirection(Vector2(-1, 0));
        break;
      case JoystickMoveDirectional.idle:
        this.setMoveDirection(Vector2.zero());
        break;
    }
  }
}
