import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';

// --- MODELOS ---
class RuleItem {
  final String id;
  final String label;
  final String icon;
  final String correctZone; // 'ok', 'bad'

  RuleItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.correctZone,
  });
}

class MyBodyRulesScreen extends ConsumerStatefulWidget {
  const MyBodyRulesScreen({super.key});

  @override
  ConsumerState<MyBodyRulesScreen> createState() => _MyBodyRulesScreenState();
}

class _MyBodyRulesScreenState extends ConsumerState<MyBodyRulesScreen> {
  // Marcador local
  int _internalScore = 0;
  String _feedbackMessage = "Arrastra la ficha hacia la zona correcta.";
  Color _feedbackColor = Colors.grey.shade700;

  // Lista de fichas exacta de app.js
  final List<RuleItem> _allItems = [
    RuleItem(
      id: '1',
      label: 'Abrazo que quiero',
      icon: '🤗',
      correctZone: 'ok',
    ),
    RuleItem(id: '2', label: 'Tocar bajo ropa', icon: '👙', correctZone: 'bad'),
    RuleItem(
      id: '3',
      label: 'Guardar secreto malo',
      icon: '🤐',
      correctZone: 'bad',
    ),
    RuleItem(id: '4', label: 'Doctor con mamá', icon: '🩺', correctZone: 'ok'),
    RuleItem(id: '5', label: 'Fotos sin ropa', icon: '📸', correctZone: 'bad'),
    RuleItem(id: '6', label: 'Decir NO', icon: '✋', correctZone: 'ok'),
  ];

  late List<RuleItem> _availableItems;

  // Contenedores para las fichas soltadas
  Map<String, List<RuleItem>> _zoneItems = {'ok': [], 'bad': []};

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _internalScore = 0;
      _feedbackMessage = "Arrastra la ficha hacia la zona correcta.";
      _feedbackColor = Colors.grey.shade700;
      _availableItems = List.from(_allItems)..shuffle(); // Barajamos
      _zoneItems = {'ok': [], 'bad': []};
    });
  }

  void _handleDrop(RuleItem item, String zoneId) {
    if (item.correctZone == zoneId) {
      // ✅ ACIERTO
      setState(() {
        _availableItems.removeWhere((i) => i.id == item.id);
        _zoneItems[zoneId]!.add(item); // Lo metemos en su zona
        _internalScore += 10;
        _feedbackMessage =
            "¡Correcto! Tú decides sobre tu cuerpo."; // Mensaje original JS
        _feedbackColor = const Color(0xFF2ed573);
      });
      ref.read(miniGamesProvider.notifier).addCuerpoReglasScore(10);

      // Si terminó el juego
      if (_availableItems.isEmpty) {
        setState(() {
          _feedbackMessage = "¡Felicidades! Completaste el juego. 🎉";
          _feedbackColor = AppTheme.lilac;
        });
      }
    } else {
      // ❌ ERROR
      setState(() {
        _feedbackMessage =
            "Ups. Recuerda: si te incomoda, NO está permitido."; // Mensaje original JS
        _feedbackColor = const Color(0xFFe11d48); // Color rojo exacto de tu JS
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
                        '🙅‍♀️ Mi cuerpo, mis reglas',
                        style: titleStyle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Clasifica las acciones.',
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
          const SizedBox(height: 20),

          // --- LAS 2 ZONAS GRANDES DE SOLTADO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropZone(
                    'ok',
                    'Permitido',
                    '👍',
                    const Color(0xFF2ed573),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDropZone(
                    'bad',
                    'NO Permitido',
                    '⛔',
                    const Color(0xFFe11d48),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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
                    '👇 Arrástralas a la zona correcta',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
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
                          vertical: 15,
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
    return DragTarget<RuleItem>(
      onAcceptWithDetails: (details) {
        _handleDrop(details.data, zoneId);
      },
      builder: (context, candidateItems, rejectedItems) {
        bool isHovered = candidateItems.isNotEmpty;
        final droppedItems = _zoneItems[zoneId]!;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 180, // Altura fija para mantener simetría
          decoration: BoxDecoration(
            color: isHovered ? color.withOpacity(0.3) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
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

              // Fichas soltadas (Mostramos los íconos)
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
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: droppedItems
                                  .map(
                                    (e) => Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        e.icon,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
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
  Widget _buildDraggableChip(RuleItem item) {
    Widget chipVisual(bool isDragging) {
      return Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Text(item.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: GoogleFonts.nunito(
                  fontSize: 16,
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

    return Draggable<RuleItem>(
      data: item,
      feedback: chipVisual(true),
      childWhenDragging: Opacity(opacity: 0.3, child: chipVisual(false)),
      child: chipVisual(false),
    );
  }
}
