import 'package:flutter/material.dart';

class WasteTypeChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted; // Fonction appelée quand on clique sur l'icône de suppression
  // Vous pourriez ajouter une couleur, etc.

  const WasteTypeChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: Icon(Icons.cancel, size: 18),
    );
  }
}