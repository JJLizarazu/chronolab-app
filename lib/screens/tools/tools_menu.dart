import 'package:flutter/material.dart';
import 'dilution_calc.dart';
import 'cell_counter.dart';
import 'reference_vals.dart';
import 'voice_notes.dart';
import 'history_screen.dart';
import 'unit_converter.dart';
import 'techniques_screen.dart';

class ToolsMenu extends StatelessWidget {
  const ToolsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {
        'title': 'Técnicas',
        'icon': Icons.menu_book,
        'color': Colors.indigo,
        'page': const TechniquesScreen(),
      },
      {
        'title': 'Calculadora',
        'icon': Icons.calculate_outlined,
        'color': Colors.orange,
        'page': const DilutionCalcScreen(),
      },
      {
        'title': 'Conversor',
        'icon': Icons.sync_alt,
        'color': Colors.green,
        'page': const UnitConverterScreen(),
      },
      {
        'title': 'Contador Células',
        'icon': Icons.grid_on,
        'color': Colors.purple,
        'page': const CellCounterScreen(),
      },
      {
        'title': 'Valores Ref.',
        'icon': Icons.list_alt,
        'color': Colors.blue,
        'page': const ReferenceValuesScreen(),
      },
      {
        'title': 'Notas Voz',
        'icon': Icons.mic,
        'color': Colors.red,
        'page': const VoiceNotesScreen(),
      },
      {
        'title': 'Historial',
        'icon': Icons.history,
        'color': Colors.teal,
        'page': const HistoryScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return _ToolCard(
            title: tool['title'],
            icon: tool['icon'],
            color: tool['color'],
            onTap: () {
              if (tool['page'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => tool['page']),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Próximamente...")),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}