import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/bg.jpg',
        fit: BoxFit.none, // No escala la imagen
      ),
    );
  }
}
