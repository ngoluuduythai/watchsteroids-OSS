import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/game/game.dart';

class Radar extends PositionComponent with HasGameRef<WatchsteroidsGame> {
  Radar() : super(anchor: Anchor.center, priority: 10);

  static const radarWidth = 400.0;

  @override
  Future<void> onLoad() async {
    // size = Vector2(400, 400);
    position = Vector2(0, 0);

    await add(
      RadarDetector(
        radius: radarWidth * 0.35,
        onCollisionStartCallback: handleCollision,
      ),
    );
  }

  void handleCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is AsteroidSprite) {
      const alertSize = radarWidth * 0.15;

      final intersectionPoint = intersectionPoints.first;
      final angle = atan2(intersectionPoint.x, -intersectionPoint.y);
      final CircleComponent alert;
      add(
        alert = CircleComponent(
          anchor: Anchor.center,
          radius: alertSize,
          paint: Paint()
            ..strokeWidth = 4.0
            ..shader = Gradient.radial(
              Offset(alertSize, 0),
              alertSize,
              [
                WatchsteroidsColors.ringColor.withOpacity(0.4),
                WatchsteroidsColors.ringColor.withOpacity(0.2),
                WatchsteroidsColors.ringColor.withOpacity(0.0),
              ],
              [0.0, 0.3, 1.0],
            ),
        )
          ..opacity = 0.0
          ..angle = angle,
      );

      const alertDuration = 1.5;

      final controller = EffectController(
        duration: alertDuration / 2,
        reverseDuration: alertDuration / 2,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
        alternate: true,
      );

      alert.add(
          SequenceEffect([OpacityEffect.to(1.0, controller), RemoveEffect()]));
    }
  }
}

class RadarDetector extends CircleComponent with CollisionCallbacks {
  RadarDetector({
    required this.onCollisionStartCallback,
    super.radius,
  }) : super(
            anchor: Anchor.center,
            paint: Paint()..color = WatchsteroidsColors.transparent,
            children: [
              CircleHitbox(),
            ]);

  final CollisionCallback<PositionComponent> onCollisionStartCallback;
}
