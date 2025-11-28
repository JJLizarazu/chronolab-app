import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timer_provider.dart';

class CreateTimerSheet extends StatefulWidget {
  const CreateTimerSheet({super.key});

  @override
  State<CreateTimerSheet> createState() => _CreateTimerSheetState();
}

class _CreateTimerSheetState extends State<CreateTimerSheet> {
  final _nameController = TextEditingController();
  final _hourController = TextEditingController(text: "0");
  final _minController = TextEditingController(text: "0");
  final _secController = TextEditingController(text: "00");

  Color _selectedColor = const Color(0xFF009688);

  final List<int> _quickTimes = [1, 3, 5, 10, 15, 30, 45, 60];
  final List<Color> _colors = [
    const Color(0xFFE91E63),
    const Color(0xFFFFC107),
    const Color(0xFF2196F3),
    const Color(0xFF009688),
    const Color(0xFF9C27B0),
  ];

  void _normalizeTime(String changedField) {
    if (!mounted) return;

    int hours = int.tryParse(_hourController.text) ?? 0;
    int minutes = int.tryParse(_minController.text) ?? 0;
    int seconds = int.tryParse(_secController.text) ?? 0;

    if (seconds >= 60) {
      minutes += seconds ~/ 60;
      seconds = seconds % 60;
    }

    if (minutes >= 60) {
      hours += minutes ~/ 60;
      minutes = minutes % 60;
    }

    if (int.tryParse(_hourController.text) != hours) _hourController.text = hours.toString();
    if (int.tryParse(_minController.text) != minutes) _minController.text = minutes.toString();
    if (int.tryParse(_secController.text) != seconds) _secController.text = seconds.toString();

    if (seconds < 10) {
      _secController.text = seconds.toString().padLeft(2, '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timer_outlined, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              const Text(
                "Configurar Temporizador",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: "Nombre de la muestra",
              hintText: "Ej. 204",
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTimeInput(_hourController, "Horas", cardColor, (val) => _normalizeTime('hour'))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeInput(_minController, "Minutos", cardColor, (val) => _normalizeTime('minute'))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeInput(_secController, "Segundos", cardColor, (val) => _normalizeTime('second'))),
            ],
          ),

          const SizedBox(height: 20),

          const Text("Selección Rápida:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickTimes.map((min) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text("$min m"),
                    backgroundColor: cardColor,
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    elevation: 1,
                    onPressed: () {
                      setState(() {
                        _hourController.text = "0";
                        _minController.text = min.toString();
                        _secController.text = "00";
                        _normalizeTime('');
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          const Text("Identificador:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _colors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 48 : 40,
                  height: isSelected ? 48 : 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: isSelected ? 12 : 4,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: isSelected ? Border.all(color: isDark ? Colors.black : Colors.white, width: 3) : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              foregroundColor: Colors.white,
              shadowColor: _selectedColor.withOpacity(0.5),
            ),
            onPressed: () {
              final hours = int.tryParse(_hourController.text) ?? 0;
              final minutes = int.tryParse(_minController.text) ?? 0;
              final seconds = int.tryParse(_secController.text) ?? 0;

              if (hours == 0 && minutes == 0 && seconds == 0) return;

              final name = _nameController.text.isEmpty
                  ? "Muestra sin Nombre"
                  : _nameController.text;

              final duration = Duration(hours: hours, minutes: minutes, seconds: seconds);

              Provider.of<TimerProvider>(context, listen: false)
                  .addTimer(name, duration, _selectedColor);

              Navigator.pop(context);
            },
            child: const Text("INICIAR TIMER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label, Color bgColor, ValueChanged<String> onChanged) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            fillColor: bgColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
      ],
    );
  }
}