import 'home.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _entrada, _saida;
  double _angulo = -45 * 3.14 / 180, _opacidade = 1.0;
  bool _primeiraEntrada = false;
  @override
  void initState() {
    super.initState();
    paraDireita();
  }

  void paraDireita() {
    _opacidade = 1.0;
    _entrada = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _entrada.addListener(() {
      setState(() {
        _angulo = _entrada.value * 90 * 3.14 / 180 - 45 * 3.14 / 180;
      });
    });
    _entrada.forward();
    _primeiraEntrada = true;
  }

  void paraEsquerda() {
    _opacidade = 1.0;
    _entrada = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _entrada.addListener(() {
      setState(() {
        _angulo = -(_entrada.value * 90 * 3.14 / 180 - 45 * 3.14 / 180);
      });
    });
    _entrada.forward();
    _primeiraEntrada = false;
  }

  void saida() async {
    _saida = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _saida.addListener(() {
      setState(() {
        _opacidade = 1.0 - _saida.value;
      });
    });
    await _saida.forward();
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
      paraDireita();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _entrada.dispose();
    _saida.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Transform.rotate(
              angle: _angulo,
              // Deixar o centro da imagem em sua base para a rotação
              origin: Offset(0, 75),
              child: GestureDetector(
                onTap: _primeiraEntrada ? paraEsquerda : paraDireita,
                child: Image.asset(
                  'assets/icone.png',
                  width: 150,
                  opacity: AlwaysStoppedAnimation(_opacidade),
                ),
              ),
            ),
            ElevatedButton(onPressed: saida, child: const Text('Iniciar')),
          ],
        ),
      ),
    );
  }
}
