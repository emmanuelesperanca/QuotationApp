import 'dart:math';
import 'package:flutter/material.dart';

// --- LÓGICA DA ANIMAÇÃO DE PARTÍCULAS ---
class Particle {
  Offset position;
  Offset speed;
  double radius;
  Color color;

  Particle({required this.position, required this.speed, required this.radius, required this.color});
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles;
  static final Random random = Random();

  ParticlePainter({required this.animation})
      : particles = List.generate(50, (index) {
          return Particle(
            position: Offset(-1, -1), // Inicia fora da tela
            speed: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
            radius: random.nextDouble() * 5 + 2,
            color: Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.1),
          );
        }),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Inicializa a posição na primeira vez que pinta
      if (particle.position == const Offset(-1, -1)) {
        particle.position = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      }

      // Move a partícula
      particle.position += particle.speed;

      // Faz a partícula reaparecer do outro lado se sair da tela
      if (particle.position.dx < 0) particle.position = Offset(size.width, particle.position.dy);
      if (particle.position.dx > size.width) particle.position = Offset(0, particle.position.dy);
      if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, size.height);
      if (particle.position.dy > size.height) particle.position = Offset(particle.position.dx, 0);

      // Desenha o círculo
      canvas.drawCircle(particle.position, particle.radius, Paint()..color = particle.color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
