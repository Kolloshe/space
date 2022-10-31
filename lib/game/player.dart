import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmtionfighter/game/audio_player_component.dart';
import 'package:redmtionfighter/game/enemy.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/game/knows_game_size.dart';
import 'package:redmtionfighter/models/player_data.dart';
import 'package:redmtionfighter/models/spaceship_details.dart';

import 'bullet.dart';
import 'command.dart';

class Player extends SpriteComponent
    with KnowsGameSize, Hitbox, Collidable, JoystickListener, HasGameRef<SpaceScapeGame> {
  Vector2 _moveDirection = Vector2.zero();





  int _health = 100;

  int get health => _health;

  Random _random = Random();

  SpaceshipType spaceshipType;
  Spaceship _spaceship;

late  PlayerData _playerData;

  int get score => _playerData.currentScore;

bool _shootMultipleBullets = false;
late Timer _powerUpTimer;

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 300;
  }

  Player({
    required this.spaceshipType,
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  })  : this._spaceship = Spaceship.getSpaceshipByType(spaceshipType),
        super(sprite: sprite, position: position, size: size){
    _powerUpTimer = Timer(4,callback: (){_shootMultipleBullets=false;});
  }


  @override
  void onMount() {
    super.onMount();
    final shape = HitboxCircle(definition: 0.8);
    addShape(shape);
    _playerData =  Provider.of<PlayerData>(gameRef.buildContext!,listen: false);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      gameRef.camera.shake(intensity: 20);

      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
_powerUpTimer.update(dt);
    this.position += _moveDirection.normalized() * _spaceship.speed * dt;

    this.position.clamp(Vector2.zero() + size / 2, gameSize - size / 2);

    final particleComponent = ParticleComponent(
        particle: Particle.generate(
            count: 10,
            lifespan: 0.1,
            generator: (i) => AcceleratedParticle(
                acceleration: getRandomVector(),
                speed: getRandomVector(),
                position: (this.position.clone() + Vector2(0, this.size.y / 3)),
                child: CircleParticle(
                  radius: 1,
                  paint: Paint()..color = Colors.white,
                ))));
    gameRef.add(particleComponent);
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
          position: this.position.clone(), level: _spaceship.level);
      bullet.anchor = Anchor.center;
      gameRef.add(bullet);
      gameRef.addCommand(Command<AudioPlayerComponent>(action:(audioPlayer){
        audioPlayer.platSfx('laserSmall_001.ogg');
      }));

      if(_shootMultipleBullets){
        for(int i =-1;i<2;i+=2)
        {
          Bullet bullet = Bullet(
              sprite: gameRef.spriteSheet.getSpriteById(28),
              size: Vector2(64, 64),
              position: this.position.clone(), level: _spaceship.level);
          bullet.anchor = Anchor.center;
          bullet.direction.rotate(i * pi / 6);
          gameRef.add(bullet);
        }

      }
    }

  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    switch (event.directional) {
      case JoystickMoveDirectional.moveUp:
        setMoveDirection(Vector2(0, -1));
        break;
      case JoystickMoveDirectional.moveUpLeft:
        setMoveDirection(Vector2(-1, -1));
        break;
      case JoystickMoveDirectional.moveUpRight:
        setMoveDirection(Vector2(1, -1));
        break;
      case JoystickMoveDirectional.moveRight:
        setMoveDirection(Vector2(1, 0));
        break;
      case JoystickMoveDirectional.moveDown:
        setMoveDirection(Vector2(0, 1));
        break;
      case JoystickMoveDirectional.moveDownRight:
        setMoveDirection(Vector2(1, 1));
        break;
      case JoystickMoveDirectional.moveDownLeft:
        setMoveDirection(Vector2(-1, 1));
        break;
      case JoystickMoveDirectional.moveLeft:
        setMoveDirection(Vector2(-1, 0));
        break;
      case JoystickMoveDirectional.idle:
        setMoveDirection(Vector2.zero());
        break;
    }
  }

  void addToScore(int point) {
    _playerData.currentScore += point;
    _playerData.money+=point;
    _playerData.save();
  }
void increaseHealthBy(int points){
    _health+=points;
    if(_health>100){
      _health = 100;
    }
}
  void reset() {
    _playerData.currentScore = 0;
    _health = 100;
    position = gameRef.viewport.canvasSize / 2;
  }
  void setSpaceshipType(SpaceshipType spaceshipType){
    this.spaceshipType = spaceshipType;
    this._spaceship = Spaceship.getSpaceshipByType(spaceshipType);
    sprite = gameRef.spriteSheet.getSpriteById(_spaceship.spriteId);
  }
  void shootMultipleBullets() {
_shootMultipleBullets = true;
_powerUpTimer.stop();
_powerUpTimer.start();
  }
}
