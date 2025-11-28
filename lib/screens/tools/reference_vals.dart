import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferenceValuesScreen extends StatefulWidget {
  const ReferenceValuesScreen({super.key});

  @override
  State<ReferenceValuesScreen> createState() => _ReferenceValuesScreenState();
}

class _ReferenceValuesScreenState extends State<ReferenceValuesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _defaultValues = [
    {'test': 'Glucosa (Ayunas)', 'normal': '70 - 100 mg/dL', 'cat': 'Química'},
    {'test': 'Glucosa (Post)', 'normal': '< 140 mg/dL', 'cat': 'Química'},
    {'test': 'Urea', 'normal': '15 - 45 mg/dL', 'cat': 'Química'},
    {'test': 'Creatinina (H)', 'normal': '0.7 - 1.3 mg/dL', 'cat': 'Química'},
    {'test': 'Colesterol Total', 'normal': '< 200 mg/dL', 'cat': 'Lípidos'},
    {'test': 'Triglicéridos', 'normal': '< 150 mg/dL', 'cat': 'Lípidos'},
    {'test': 'HDL (Bueno)', 'normal': '> 40 mg/dL', 'cat': 'Lípidos'},
    {'test': 'Hemoglobina (H)', 'normal': '13.5 - 17.5 g/dL', 'cat': 'Hematología'},
    {'test': 'Leucocitos', 'normal': '4.5 - 11.0 x10³/uL', 'cat': 'Hematología'},
    {'test': 'Plaquetas', 'normal': '150 - 450 x10³/uL', 'cat': 'Hematología'},
  ];

  List<Map<String, String>> _customValues = [];
  List<Map<String, String>> _combinedList = [];
  List<Map<String, String>> _filteredList = [];

  final List<String> _categories = ["Todos", "Química", "Hematología", "Lípidos", "Otros"];
  String _selectedCategory = "Todos";

  bool _isSelectionMode = false;
  final Set<Map<String, String>> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCustomValues();
  }

  Future<void> _loadCustomValues() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('custom_refs')) {
      final String data = prefs.getString('custom_refs')!;
      final List<dynamic> decoded = jsonDecode(data);
      _customValues = decoded.map((e) => Map<String, String>.from(e)).toList();
    }
    _updateList();
  }

  Future<void> _saveCustomValues() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_customValues);
    await prefs.setString('custom_refs', data);
    _updateList();
  }

  void _updateList() {
    _combinedList = [..._customValues, ..._defaultValues];

    setState(() {
      _filteredList = _combinedList.where((item) {
        final passCategory = _selectedCategory == "Todos" || item['cat'] == _selectedCategory;
        final passSearch = item['test']!.toLowerCase().contains(_searchController.text.toLowerCase());
        return passCategory && passSearch;
      }).toList();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear(); // Limpiar al cambiar modo
    });
  }

  void _toggleItemSelection(Map<String, String> item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _deleteSelected() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("¿Borrar ${_selectedItems.length} elementos?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _customValues.removeWhere((element) => _selectedItems.contains(element));
                _selectedItems.clear();
                _isSelectionMode = false;
              });
              _saveCustomValues();
              Navigator.pop(ctx);
            },
            child: const Text("Borrar"),
          )
        ],
      ),
    );
  }

  // --- AGREGAR NUEVO VALOR ---
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    String catSelect = "Otros";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Agregar Referencia"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre del Examen", hintText: "Ej. Ferritina", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: valCtrl, decoration: const InputDecoration(labelText: "Valor Normal", hintText: "Ej. 30 - 400 ng/mL", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: catSelect,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _categories.where((c) => c != "Todos").map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) => setStateSB(() => catSelect = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && valCtrl.text.isNotEmpty) {
                      _customValues.insert(0, {
                        'test': nameCtrl.text,
                        'normal': valCtrl.text,
                        'cat': catSelect,
                        'isCustom': 'true'
                      });
                      _saveCustomValues();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Guardar"),
                )
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? "${_selectedItems.length} Seleccionados" : "Valores Normales", style: TextStyle(fontWeight: FontWeight.bold),),
        leading: _isSelectionMode
            ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _selectedItems.isNotEmpty ? _deleteSelected : null)
            : null,
        actions: [
          if (_isSelectionMode)
            TextButton(
                onPressed: _toggleSelectionMode,
                child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.bold))
            )
          else
            IconButton(
                icon: const Icon(Icons.checklist_rtl),
                tooltip: "Seleccionar para borrar",
                onPressed: _toggleSelectionMode
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat);
                      _updateList();
                    },
                    selectedColor: Colors.teal.withOpacity(0.2),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.teal : Colors.grey,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _updateList(),
              decoration: InputDecoration(
                hintText: "Buscar examen...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                fillColor: cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: _filteredList.isEmpty
                ? Center(child: Text("No hay resultados", style: TextStyle(color: Colors.grey.shade500)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final item = _filteredList[index];
                final isCustom = item['isCustom'] == 'true';
                final isSelected = _selectedItems.contains(item);

                return Card(
                  elevation: 2,
                  color: isSelected ? Colors.teal.withOpacity(0.1) : (isCustom ? cardColor : cardColor.withOpacity(0.6)),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected ? const BorderSide(color: Colors.teal, width: 2) : BorderSide.none
                  ),
                  child: ListTile(
                    onTap: _isSelectionMode
                        ? (isCustom ? () => _toggleItemSelection(item) : null)
                        : null,
                    leading: _isSelectionMode
                        ? Checkbox(
                      value: isSelected,
                      onChanged: isCustom ? (val) => _toggleItemSelection(item) : null,
                      activeColor: Colors.teal,
                    )
                        : CircleAvatar(
                      backgroundColor: _getCatColor(item['cat']!),
                      child: Text(item['test']![0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                        item['test']!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (!isCustom && _isSelectionMode) ? Colors.grey : null
                        )
                    ),
                    subtitle: Text(item['cat']!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    trailing: _isSelectionMode
                        ? null
                        : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(item['normal']!, style: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getCatColor(String cat) {
    switch (cat) {
      case 'Química': return Colors.blue;
      case 'Lípidos': return Colors.orange;
      case 'Hematología': return Colors.red;
      default: return Colors.teal;
    }
  }
}