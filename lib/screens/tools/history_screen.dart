import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/timer_provider.dart';
import '../../models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white);
    final List<HistoryItem> filteredList = provider.history.where((item) {
      return item.label.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Eventos", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          // MENU DE OPCIONES (Exportar / Borrar)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportToCSV(provider.history);
              } else if (value == 'clear') {
                _showClearDialog(context, provider);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.teal),
                      SizedBox(width: 8),
                      Text('Exportar Reporte (CSV)', style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Borrar Todo', style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Buscar por nombre...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),

          Expanded(
            child: filteredList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 10),
                  Text(
                    _searchQuery.isEmpty ? "No hay historial aún" : "No se encontraron resultados",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildHistoryCard(item, cardColor, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV(List<HistoryItem> history) async {
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay datos para exportar", style: TextStyle(fontWeight: FontWeight.bold),)),
      );
      return;
    }

    try {
      String csvContent = "Fecha,Hora,Muestra,Duracion Original\n";

      for (var item in history) {
        final date = DateFormat('yyyy-MM-dd').format(item.finishTime);
        final time = DateFormat('HH:mm:ss').format(item.finishTime);
        final duration = "${(item.durationSeconds / 60).toStringAsFixed(1)} min";

        final cleanLabel = item.label.replaceAll(',', ' ');

        csvContent += "$date,$time,$cleanLabel,$duration\n";
      }

      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/Reporte_Laboratorio_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv";
      final file = File(path);
      await file.writeAsString(csvContent);

      final xFile = XFile(path);
      await Share.shareXFiles([xFile], text: 'Aquí está el reporte de tiempos del laboratorio.');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al exportar: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildHistoryCard(HistoryItem item, Color bgColor, bool isDark) {
    final DateFormat timeFormat = DateFormat('h:mm a');
    final DateFormat dateFormat = DateFormat('MMM d');

    final Duration d = Duration(seconds: item.durationSeconds);
    String durationText = "";
    if (d.inHours > 0) durationText = "${d.inHours}h ";
    if (d.inMinutes.remainder(60) > 0) durationText += "${d.inMinutes.remainder(60)}m";
    if (durationText.isEmpty) durationText = "${d.inSeconds}s";

    return Card(
      color: bgColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(item.colorValue).withOpacity(0.2),
          child: Icon(Icons.check, color: Color(item.colorValue), size: 20),
        ),
        title: Text(
          item.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Duración: $durationText",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeFormat.format(item.finishTime),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              dateFormat.format(item.finishTime),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, TimerProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Borrar Historial?", style: TextStyle(fontWeight: FontWeight.bold),),
        content: const Text("Esta acción no se puede deshacer.", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold),)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text("Borrar", style: TextStyle(fontWeight: FontWeight.bold),),
          )
        ],
      ),
    );
  }
}