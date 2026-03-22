import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String classId;
  final GameTask? taskToEdit; // 👇 Si recibe una tarea, entra en modo Edición

  const CreateTaskScreen({super.key, this.classId = '', this.taskToEdit});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedGameId = 'rompe_silencio';
  double _targetScore = 15;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  final Map<String, String> _availableGames = {
    'puertas': '🚪 Las Puertas de la Confianza',
    'torre': '🏗️ La Gran Torre de Isla',
    'shawarma': '🥙 El Shawarma Seguro',
    'rompe_silencio': '🎤 Rompe el Silencio',
    'emocionometro': '🧭 Emocionómetro',
    'semaforo_situaciones': '🚦 Semáforo Situaciones',
    'semaforo_cuerpo': '🚦 Semáforo del Cuerpo',
    'detecta_engano': '📱 Detecta el Engaño',
    'circulo_seguro': '🛡️ Mi Círculo Seguro',
    'cuerpo_reglas': '🙅‍♀️ Mi cuerpo, mis reglas',
  };

  final Map<String, String> _gameImages = {
    'puertas': 'assets/images/PELRC.png',
    'torre': 'assets/images/islalogo.png',
    'shawarma': 'assets/images/SHWS.png',
  };

  @override
  void initState() {
    super.initState();
    // 👇 Si estamos editando, llenamos los campos con los datos existentes
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _selectedGameId = widget.taskToEdit!.targetGameId;
      _targetScore = widget.taskToEdit!.targetScore.toDouble();
      _selectedDate = widget.taskToEdit!.dueDate;
    }
  }

  // 👇 Selector combinado de Fecha y Hora
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // No se pueden poner fechas pasadas
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.taskToEdit != null) {
          // ACTUALIZAR TAREA EXISTENTE
          final updatedTask = GameTask(
            id: widget.taskToEdit!.id,
            classId: widget.classId,
            title: _titleController.text,
            description: _descController.text,
            targetGameId: _selectedGameId,
            targetScore: _targetScore.toInt(),
            dueDate: _selectedDate,
          );
          // 👇 Agregamos await
          await ref.read(taskProvider.notifier).updateTask(updatedTask);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Tarea actualizada',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          // CREAR NUEVA TAREA
          // 👇 Agregamos await
          await ref
              .read(taskProvider.notifier)
              .addTask(
                classId: widget.classId,
                title: _titleController.text,
                description: _descController.text,
                targetGameId: _selectedGameId,
                targetScore: _targetScore.toInt(),
                dueDate: _selectedDate,
              );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Tarea asignada',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFF2ed573),
            ),
          );
        }

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        // 🚨 SI FIREBASE FALLA, TE LO MOSTRARÁ AQUÍ
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: $e',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Formateador de texto para la fecha
  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} a las ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Tarea' : 'Nueva Tarea',
          style: GoogleFonts.nunito(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? '✏️ Editar Tarea' : '📝 Nueva Tarea',
                style: titleStyle.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 30),

              Text(
                'Título de la Tarea',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ej: Aprende a cuidarte',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un título' : null,
              ),
              const SizedBox(height: 20),

              Text(
                '¿Qué minijuego deben jugar?',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGameId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _availableGames.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedGameId = value!;
                }),
              ),

              if (_gameImages.containsKey(_selectedGameId))
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        _gameImages[_selectedGameId]!,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const SizedBox(height: 0),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // 👇 SECCIÓN DE FECHA Y HORA LÍMITE
              Text(
                'Fecha y Hora Límite',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(_selectedDate),
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkLight,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppTheme.lilac),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Puntos a conseguir:',
                    style: titleStyle.copyWith(fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_targetScore.toInt()} pts',
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.lilac,
                  thumbColor: AppTheme.lilac,
                ),
                child: Slider(
                  value: _targetScore,
                  min: 5,
                  max: 60,
                  divisions: 11,
                  onChanged: (value) => setState(() {
                    _targetScore = value;
                  }),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Mensaje para los alumnos',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ej: Repasen lo visto en clase...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2c3e50),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: _submitTask,
                icon: Icon(
                  isEditing ? Icons.save : Icons.send,
                  color: Colors.white,
                ),
                label: Text(
                  isEditing ? 'Guardar Cambios' : 'Asignar Tarea',
                  style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
