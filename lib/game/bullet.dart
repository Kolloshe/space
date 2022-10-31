import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:redmtionfighter/game/enemy.dart';

class Bullet extends SpriteComponent  with Hitbox,Collidable{
  double _speed = 450;
  Vector2 direction = Vector2(0, -1);

  final  int level ;

  Bullet({
    required Sprite? sprite,
    required Vector2? position,
    required Vector2? size,
    required this.level,
  }) : super(sprite: sprite, position: position, size: size);


  @override
  void onMount() {
    super.onMount();
    final shape = HitboxCircle(definition: 0.5);
    addShape(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);

    if(other is Enemy)
    {
      this.remove();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * _speed * dt;

    if (position.y < 0) {
      remove();
    }
  }
}
