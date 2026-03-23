import 'package:flutter/material.dart';

class AppTheme {
  // --- PALETA DE COLORES WEB OFICIAL (Extrayendo de CSS e Imagen) ---

  // Colores Base
  static const Color paperLight = Color(0xFFF4F6F8); // Fondo claro de la web
  static const Color inkLight = Color(0xFF2C3E50); // Texto oscuro principal

  // Colores de la Marca (KIVA)
  static const Color kivaBlue = Color(0xFF0056A8); // El azul del texto "KIVA"
  static const Color kivaPurple = Color(
    0xFF6C3A9B,
  ); // El morado de "- Kid's Integrity..."

  // Colores de Interacción y Acentos (Basados en CSS pasteles)
  static const Color lilac = Color(0xFFA594F9); // Lavanda suave
  static const Color pink = Color(0xFFFF9EAA); // Rosa suave pastel
  static const Color yellow = Color(
    0xFFFFD93D,
  ); // Amarillo vibrante (se mantiene)
  static const Color green = Color(0xFF2ED573); // Verde éxito (se mantiene)
  static const Color peach = Color(0xFFFFD1A9); // Melocotón pastel

  static const Color ringLight = Color(0xFFE2E8F0); // Bordes y líneas suaves

  // --- WIDGET AUXILIAR: FONDO DE CÍRCULOS PASTELES (CSS Style) ---
  // He creado este widget para que puedas usar el fondo web en cualquier pantalla.
  // Es súper optimizado porque no usa imágenes, usa formas de Flutter.
  static Widget buildWebBackground({required Widget child}) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: paperLight)),

        // Círculo Morado Pastel (Superior Derecha)
        Positioned(
          top: -100,
          right: -80,
          child: _buildPastelCircle(250, kivaPurple.withOpacity(0.08)),
        ),

        // Círculo Azul Pastel (Centro Izquierda)
        Positioned(
          bottom: 200,
          left: -120,
          child: _buildPastelCircle(300, kivaBlue.withOpacity(0.06)),
        ),

        // Círculo Rosa Pastel (Inferior Derecha)
        Positioned(
          bottom: -50,
          right: 50,
          child: _buildPastelCircle(150, pink.withOpacity(0.12)),
        ),

        child, // El contenido de la pantalla va encima
      ],
    );
  }

  // Generador de los círculos pasteles difuminados
  static Widget _buildPastelCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        // Difuminado suave como el diseño web
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: size / 2,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
