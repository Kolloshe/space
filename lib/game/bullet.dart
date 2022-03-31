import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:redmtionfighter/game/enemy.dart';

class Bullet extends SpriteComponent  with Hitbox,Collidable{
  double _speed = 450;

  Bullet({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
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
    position += Vector2(0, -1) * _speed * dt;

    if (position.y < 0) {
      remove();
    }
  }
}
