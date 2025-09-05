import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../providers/auth_notifier.dart';
import '../home/main_layout.dart';

class TelaLogin extends StatefulWidget {
  final AppDatabase database;
  const TelaLogin({super.key, required this.database});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> with TickerProviderStateMixin {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  late AnimationController _controller;

  void _doLogin() {
    final user = _userController.text;
    final pass = _passController.text;

    int sumOfDigits = user.runes
        .where((r) => r >= 48 && r <= 57)
        .map((r) => int.parse(String.fromCharCode(r)))
        .fold(0, (prev, element) => prev + element);
    
    final correctPass = 'admin$sumOfDigits';

    if (pass == correctPass) {
      Provider.of<AuthNotifier>(context, listen: false).login(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout(database: widget.database)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilizador ou senha inválidos.'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarAjudaSenha() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Como recuperar minha senha?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A senha é formada pela palavra "admin" seguida da soma dos dígitos do seu U-number.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Exemplo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('• U-number: u12345'),
            Text('• Soma dos dígitos: 1+2+3+4+5 = 15'),
            Text('• Senha: admin15'),
            SizedBox(height: 16),
            Text(
              'Para seu U-number, calcule a soma dos dígitos e use "admin" + esse resultado.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/login_bg.jpg', fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: Colors.blueGrey),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticlePainter(animation: _controller),
            ),
          ),
          Center(
            child: Card(
              color: Colors.black.withOpacity(0.7),
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Order to Smile', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _userController,
                        decoration: const InputDecoration(labelText: 'Utilizador', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _doLogin,
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _mostrarAjudaSenha,
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            position: Offset(-1, -1),
            speed: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
            radius: random.nextDouble() * 5 + 2,
            color: Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.1),
          );
        }),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.position == const Offset(-1, -1)) {
        particle.position = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      }
      particle.position += particle.speed;
      if (particle.position.dx < 0) particle.position = Offset(size.width, particle.position.dy);
      if (particle.position.dx > size.width) particle.position = Offset(0, particle.position.dy);
      if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, size.height);
      if (particle.position.dy > size.height) particle.position = Offset(particle.position.dx, 0);
      canvas.drawCircle(particle.position, particle.radius, Paint()..color = particle.color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
