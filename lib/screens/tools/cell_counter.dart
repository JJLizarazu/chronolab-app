import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CellCounterScreen extends StatefulWidget {
  const CellCounterScreen({super.key});

  @override
  State<CellCounterScreen> createState() => _CellCounterScreenState();
}

class _CellCounterScreenState extends State<CellCounterScreen> {
  List<Map<String, dynamic>> _cells = [
    {'name': 'Neutrófilos', 'count': 0, 'color': 0xFFF48FB1},
    {'name': 'Linfocitos', 'count': 0, 'color': 0xFF90CAF9},
    {'name': 'Monocitos', 'count': 0, 'color': 0xFFCE93D8},
    {'name': 'Eosinófilos', 'count': 0, 'color': 0xFFFFCC80},
    {'name': 'Basófilos', 'count': 0, 'color': 0xFFB39DDB},
  ];

  int _targetCount = 100;

  @override
  void initState() {
    super.initState();
    _loadCells();
  }

  Future<void> _loadCells() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_cells_config')) {
      final String data = prefs.getString('saved_cells_config')!;
      List<dynamic> decoded = jsonDecode(data);
      setState(() {
        _cells = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
    _targetCount = prefs.getInt('cell_target_count') ?? 100;
  }

  Future<void> _saveCellsConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configToSave = _cells.map((c) => {'name': c['name'], 'color': c['color'], 'count': 0}).toList();
    await prefs.setString('saved_cells_config', jsonEncode(configToSave));
    await prefs.setInt('cell_target_count', _targetCount);
  }

  int get _total => _cells.fold(0, (sum, item) => sum + (item['count'] as int));

  void _increment(int index) {
    if (_targetCount != -1 && _total >= _targetCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("¡Meta de $_targetCount alcanzada!"), backgroundColor: Colors.green),
      );
      HapticFeedback.heavyImpact();
      return;
    }
    setState(() {
      _cells[index]['count'] = (_cells[index]['count'] as int) + 1;
    });
    HapticFeedback.lightImpact();

    if (_targetCount != -1 && _total == _targetCount) {
      HapticFeedback.vibrate();
      _showCompletionDialog();
    }
  }

  void _reset() {
    setState(() {
      for (var c in _cells) c['count'] = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¡Conteo Finalizado!", style: TextStyle(color: Colors.teal)),
        content: Text("Has llegado a $_targetCount células."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Revisar")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () { Navigator.pop(ctx); _reset(); },
              child: const Text("Nuevo")
          )
        ],
      ),
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (ctx) => _EditCellsDialog(
        initialCells: _cells,
        initialTarget: _targetCount,
        onSave: (newCells, newTarget) {
          setState(() {
            _cells = newCells;
            _targetCount = newTarget;
          });
          _saveCellsConfig();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white);

    int crossAxisCount = 2;
    double aspectRatio = 1.0;

    if (_cells.length == 1) { crossAxisCount = 1; aspectRatio = 2.2; }
    else if (_cells.length == 2) { crossAxisCount = 1; aspectRatio = 1.6; }
    else if (_cells.length == 3) { crossAxisCount = 1; aspectRatio = 1.4; }
    else if (_cells.length == 4) { crossAxisCount = 2; aspectRatio = 1.1; }
    else { crossAxisCount = 2; aspectRatio = 1.1; }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contador", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))]
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("PROGRESO TOTAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    Text("$_total${_targetCount == -1 ? '' : ' / $_targetCount'}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 12,
                    child: Row(
                      children: _cells.map((c) {
                        if ((c['count'] as int) == 0) return const SizedBox.shrink();
                        return Expanded(flex: c['count'] as int, child: Container(color: Color(c['color'])));
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: _cells.length,
                itemBuilder: (ctx, i) {
                  return _BigButton(
                    label: _cells[i]['name'],
                    count: _cells[i]['count'],
                    color: Color(_cells[i]['color']),
                    total: _total,
                    onTap: () => _increment(i),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCellsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> initialCells;
  final int initialTarget;
  final Function(List<Map<String, dynamic>>, int) onSave;

  const _EditCellsDialog({required this.initialCells, required this.initialTarget, required this.onSave});

  @override
  State<_EditCellsDialog> createState() => _EditCellsDialogState();
}

class _EditCellsDialogState extends State<_EditCellsDialog> {
  late List<Map<String, dynamic>> _tempCells;
  final _targetController = TextEditingController();
  bool _isInfinite = false;

  @override
  void initState() {
    super.initState();
    _tempCells = widget.initialCells.map((e) => Map<String, dynamic>.from(e)).toList();
    if (widget.initialTarget == -1) {
      _isInfinite = true;
      _targetController.text = "100";
    } else {
      _targetController.text = widget.initialTarget.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF303030) : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Configuración de Conteo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
            const SizedBox(height: 20),
            const Text("Meta (Células)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    enabled: !_isInfinite,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "100",
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text("Infinito", style: TextStyle(fontWeight: FontWeight.bold)),
                  selected: _isInfinite,
                  onSelected: (val) => setState(() => _isInfinite = val),
                  selectedColor: Colors.teal.withOpacity(0.2),
                  labelStyle: TextStyle(color: _isInfinite ? Colors.teal : Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Células Activas", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),

            Container(
              height: 250,
              decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2))
              ),
              child: ReorderableListView(
                padding: const EdgeInsets.all(8),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = _tempCells.removeAt(oldIndex);
                    _tempCells.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < _tempCells.length; i++)
                    Card(
                      key: ValueKey(_tempCells[i]['name'] + i.toString()),
                      elevation: 0,
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        leading: ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_handle_rounded, color: Colors.grey),
                        ),
                        title: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _pickColor(i),
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                    color: Color(_tempCells[i]['color']),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.withOpacity(0.3))
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_tempCells[i]['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => setState(() => _tempCells.removeAt(i)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: _addNewCell,
                icon: const Icon(Icons.add, color: Colors.teal),
                label: const Text("Agregar Célula", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: () {
                  int target = _isInfinite ? -1 : (int.tryParse(_targetController.text) ?? 100);
                  widget.onSave(_tempCells, target);
                  Navigator.pop(context);
                },
                child: const Text("GUARDAR CAMBIOS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addNewCell() {
    final ctrl = TextEditingController();
    Color selectedColor = Colors.teal;
    final colors = [Colors.teal, Colors.purple, Colors.orange, Colors.blue, Colors.red, Colors.pink, Colors.green, Colors.indigo];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Nueva Célula", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Color identificador:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: colors.map((c) {
                      final isSelected = selectedColor == c;
                      return GestureDetector(
                        onTap: () => setInnerState(() => selectedColor = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                              boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () {
                    if (ctrl.text.isNotEmpty) {
                      setState(() {
                        _tempCells.add({'name': ctrl.text, 'count': 0, 'color': selectedColor.value});
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Agregar", style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            );
          }
      ),
    );
  }

  void _pickColor(int index) {
    setState(() {
      final colors = [0xFFF48FB1, 0xFF90CAF9, 0xFFCE93D8, 0xFFFFCC80, 0xFFB39DDB, 0xFF80CBC4, 0xFFEF9A9A];
      final current = _tempCells[index]['color'];
      final nextIndex = (colors.indexOf(current) + 1) % colors.length;
      _tempCells[index]['color'] = colors[nextIndex];
    });
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final int total;
  final VoidCallback onTap;
  const _BigButton({required this.label, required this.count, required this.color, required this.total, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (count / total * 100).toStringAsFixed(1) : "0";
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [color.withOpacity(0.9), color],
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count.toString(), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))])),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5), textAlign: TextAlign.center),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
                child: Text("$percent%", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))
            )
          ],
        ),
      ),
    );
  }
}