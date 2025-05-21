import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? iconPath;
  final BorderSide? borderSide;
  final double elevation;
  final double borderRadius;
  final double minHeight;
  final FontWeight fontWeight;
  final double fontSize;

  AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.iconPath,
    this.borderSide,
    this.elevation = 0,
    this.borderRadius = 10.0,
    this.minHeight = 50.0,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(double.infinity, minHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide ?? BorderSide.none,
        ),
        elevation: elevation,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconPath != null) ...[
            Image.asset(
              iconPath!,
              height: 24,
              width: 24,
              // Si vos icônes Apple/Google sont sombres sur fond clair,
              // et claires sur fond sombre, vous pourriez avoir besoin de logique ici
              // ou de fournir différentes versions des icônes.
              // Pour l'icône Apple sur fond blanc, elle est généralement noire.
              // Pour l'icône Google, elle est colorée.
              // color: (backgroundColor == Colors.white && iconPath!.contains("apple"))
              //     ? Colors.black
              //     : null, // Exemple simple
            ),
            const SizedBox(width: 12),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}