import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../utils/sound_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final timerProvider = Provider.of<TimerProvider>(context);

    final isDark = themeProvider.isDarkMode;

    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final dangerBgColor = isDark ? const Color(0xFF3F0000) : Colors.red.shade50;
    final dangerBorderColor = isDark ? Colors.red.shade900 : Colors.red.shade200;
    final dangerTextColor = isDark ? Colors.redAccent : Colors.red.shade900;
    final dangerIconColor = isDark ? Colors.redAccent : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ajustes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Alertas y Sonido",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text("Tono de Temporizador"),
                  subtitle: Text(_getSoundName(timerProvider.selectedSound)),
                  leading: const Icon(Icons.music_note, color: Colors.teal),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSoundPicker(context, timerProvider);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Visual",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Modo Oscuro"),
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.orange,
                  ),
                  value: isDark,
                  activeColor: Colors.teal,
                  onChanged: (val) => themeProvider.toggleTheme(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Vista de Galería"),
                  secondary: const Icon(
                    Icons.grid_view_rounded,
                    color: Colors.purple,
                  ),
                  value: timerProvider.isGridView,
                  activeColor: Colors.purple,
                  onChanged: (val) => timerProvider.setGridView(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Comportamiento del Temporizador",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Tiempo Negativo (Overtime)"),
                  subtitle: const Text(
                    "Permitir que el temporizador cuente en negativo al terminar.",
                  ),
                  secondary: const Icon(Icons.timelapse, color: Colors.red),
                  value: timerProvider.enableOvertime,
                  activeColor: Colors.red,
                  onChanged: (val) => timerProvider.setOvertime(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text("Zona de Peligro", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: dangerBgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: dangerBorderColor)),
            child: ListTile(
              title: Text("Borrar todo", style: TextStyle(color: dangerTextColor, fontWeight: FontWeight.bold)),
              subtitle: Text("Eliminar temporizadores y pruebas activas", style: TextStyle(color: dangerTextColor.withOpacity(0.7))),
              leading: Icon(Icons.delete_forever, color: dangerIconColor, size: 30),
              onTap: () {
                _showDeleteDialog(context, timerProvider, isDark);
              },
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              "ChronoLab",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          Center(
            child: Text(
              "Hecho por Juan Jose Lizarazu Quiroga",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TimerProvider provider, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            SizedBox(width: 10),
            Expanded(child: Text("¿ESTÁS SEGURO?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          "Esta acción borrará todos los temporizadores activos y protocolos en curso.\n\n¡No se puede deshacer!",
          style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.red, width: 2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCELAR", style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text("BORRAR TODO"),
            onPressed: () {
              provider.clearAllTimers();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Limpieza completa!"), backgroundColor: Colors.red)
              );
            },
          ),
        ],
      ),
    );
  }

  String _getSoundName(String fileName) {
    final sound = SoundHelper.availableSounds.firstWhere(
      (s) => s['file'] == fileName,
      orElse: () => {'name': 'Desconocido'},
    );
    return sound['name']!;
  }

  void _showSoundPicker(BuildContext context, TimerProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Elige un sonido",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...SoundHelper.availableSounds.map((sound) {
                final isSelected = provider.selectedSound == sound['file'];
                return ListTile(
                  title: Text(sound['name']!),
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: Colors.teal,
                  ),
                  onTap: () {
                    provider.setSound(sound['file']!);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
