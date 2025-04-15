import 'package:flutter/material.dart';

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Cerrar sesión?'),
      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  ) ?? false;
}
