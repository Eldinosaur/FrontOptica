import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9, // Hasta el 90% del ancho de pantalla
          maxHeight: screenHeight * 0.5, // Hasta el 50% del alto de pantalla
        ),
        child: Image.asset(
          'assets/logo.PNG',
          fit: BoxFit.contain, // Mantiene el aspecto original sin recortes
        ),
      ),
    );
  }
}
