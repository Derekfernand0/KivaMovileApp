import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';

// --- MODELOS ---
class TrustItem {
  final String id;
  final String label;
  final String icon;
  final String correctZone; // 'family', 'friends', 'community', 'strangers'

  TrustItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.correctZone,
  });
}

class SafeCircleGameScreen extends ConsumerStatefulWidget {
  const SafeCircleGameScreen({super.key});

  @override
  ConsumerState<SafeCircleGameScreen> createState() =>
      _SafeCircleGameScreenState();
}

class _SafeCircleGameScreenState extends ConsumerState<SafeCircleGameScreen> {
  // Marcador
  int _internalScore = 0;
  String _feedbackMessage = "Selecciona una ficha y arrástrala a su lugar.";
  Color _feedbackColor = Colors.grey.shade700;

  // Lista de fichas pedagógicas exactas de tu app.js
  final List<TrustItem> _allItems = [
    TrustItem(
      id: 't1',
      label: 'Dar un abrazo',
      icon: '🤗',
      correctZone: 'family',
    ),
    TrustItem(
      id: 't2',
      label: 'Contar un secreto',
      icon: '💬',
      correctZone: 'family',
    ),
    TrustItem(
      id: 't3',
      label: 'Jugar en el parque',
      icon: '⚽',
      correctZone: 'friends',
    ),
    TrustItem(
      id: 't4',
      label: 'Prestar juguetes',
      icon: '🧸',
      correctZone: 'friends',
    ),
    TrustItem(
      id: 't5',
      label: 'Saludar de lejos',
      icon: '👋',
      correctZone: 'community',
    ),
    TrustItem(
      id: 't6',
      label: 'Pedir ayuda si me pierdo',
      icon: '👮',
      correctZone: 'community',
    ),
    TrustItem(
      id: 't7',
      label: 'No abrir la puerta',
      icon: '🚪',
      correctZone: 'strangers',
    ),
    TrustItem(
      id: 't8',
      label: 'No aceptar regalos',
      icon: '🍬',
      correctZone: 'strangers',
    ),
    TrustItem(
      id: 't9',
      label: 'Decir mi nombre',
      icon: '🗣️',
      correctZone: 'family',
    ),
  ];

  late List<TrustItem> _availableItems;

  // Guardamos los items soltados para mostrarlos dentro de las cajas
  Map<String, List<TrustItem>> _zoneItems = {
    'family': [],
    'friends': [],
    'community': [],
    'strangers': [],
  };

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _internalScore = 0;
      _feedbackMessage = "Selecciona una ficha y arrástrala a su lugar.";
      _feedbackColor = Colors.grey.shade700;
      _availableItems = List.from(_allItems)..shuffle(); // Barajamos
      _zoneItems = {
        'family': [],
        'friends': [],
        'community': [],
        'strangers': [],
      };
    });
  }

  void _handleDrop(TrustItem item, String zoneId) {
    if (item.correctZone == zoneId) {
      // ✅ ACIERTO
      setState(() {
        _availableItems.removeWhere((i) => i.id == item.id);
        _zoneItems[zoneId]!.add(item); // Lo guardamos en su nueva zona
        _internalScore += 10;
        _feedbackMessage = "¡Muy bien! Esa es la zona correcta.";
        _feedbackColor = const Color(0xFF16a34a); // Color verde exacto de tu JS
      });
      ref.read(miniGamesProvider.notifier).addCirculoSeguroScore(10);

      // Si terminó el juego
      if (_availableItems.isEmpty) {
        setState(() {
          _feedbackMessage =
              "¡Felicidades! Has completado tu círculo de seguridad. 🎉";
          _feedbackColor = AppTheme.lilac;
        });
      }
    } else {
      // ❌ ERROR
      setState(() {
        _feedbackMessage = "Mmm, creo que esa acción no va con esa persona.";
        _feedbackColor = const Color(0xFFdc2626); // Color rojo exacto de tu JS
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Centro de Exploración',
          style: GoogleFonts.nunito(color: AppTheme.inkLight),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: Column(
        children: [
          // --- CABECERA CON MARCADOR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🛡️ Mi Círculo Seguro',
                        style: titleStyle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '¿Con quién harías esto? Arrastra la ficha.',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2c3e50),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Puntos: $_internalScore',
                    style: GoogleFonts.fredoka(
                      color: AppTheme.yellow,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // --- LAS 4 ZONAS DE SOLTADO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio:
                  1.25, // Un poco más alto para que quepan los emojis soltados
              children: [
                _buildDropZone(
                  'family',
                  'Familia',
                  '👨‍👩‍👧',
                  const Color(0xFF3498db),
                ),
                _buildDropZone(
                  'friends',
                  'Amigos',
                  '👫',
                  const Color(0xFF2ecc71),
                ),
                _buildDropZone(
                  'community',
                  'Ayudantes',
                  '👮‍♂️',
                  const Color(0xFFe67e22),
                ),
                _buildDropZone(
                  'strangers',
                  'Extraños',
                  '🛑',
                  const Color(0xFFe74c3c),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // --- ZONA DE FEEDBACK ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: _feedbackColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _feedbackColor, width: 2),
            ),
            child: Center(
              child: Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _feedbackColor == Colors.grey.shade700
                      ? AppTheme.inkLight
                      : _feedbackColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- PISCINA DE FICHAS ---
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '👇 Fichas disponibles (Arrástralas)',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: _availableItems
                            .map((item) => _buildDraggableChip(item))
                            .toList(),
                      ),
                    ),
                  ),

                  // Botón Reiniciar
                  if (_availableItems.isEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lilac,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _resetGame,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'Jugar de Nuevo',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Creador de las Zonas (DragTarget)
  Widget _buildDropZone(
    String zoneId,
    String title,
    String emoji,
    Color color,
  ) {
    return DragTarget<TrustItem>(
      onAcceptWithDetails: (details) {
        _handleDrop(details.data, zoneId);
      },
      builder: (context, candidateItems, rejectedItems) {
        bool isHovered = candidateItems.isNotEmpty;
        final droppedItems = _zoneItems[zoneId]!; // Elementos ya soltados aquí

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isHovered ? color.withOpacity(0.3) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isHovered ? color : color.withOpacity(0.5),
              width: isHovered ? 4 : 2,
            ),
            boxShadow: [
              if (isHovered)
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
            ],
          ),
          child: Column(
            children: [
              // Cabecera de la zona
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Muestra los iconos de las acciones que se soltaron aquí
              Expanded(
                child: Center(
                  child: droppedItems.isEmpty
                      ? Text(
                          'Arrastra aquí',
                          style: GoogleFonts.nunito(
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          // Muestra solo los emojis de las fichas soltadas
                          children: droppedItems
                              .map(
                                (e) => Text(
                                  e.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Creador de las Fichas (Draggable)
  Widget _buildDraggableChip(TrustItem item) {
    Widget chipVisual(bool isDragging) {
      return Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDragging ? AppTheme.yellow : AppTheme.paperLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade400, width: 2),
            boxShadow: isDragging
                ? const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.inkLight,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Draggable<TrustItem>(
      data: item,
      feedback: chipVisual(true),
      childWhenDragging: Opacity(opacity: 0.3, child: chipVisual(false)),
      child: chipVisual(false),
    );
  }
}
