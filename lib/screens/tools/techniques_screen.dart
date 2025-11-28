import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/timer_provider.dart';
import '../../models/protocol_model.dart';

class TechniquesScreen extends StatelessWidget {
  const TechniquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Técnicas", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: provider.savedProtocols.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 10),
            const Text("No hay técnicas guardadas", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.savedProtocols.length,
        itemBuilder: (ctx, i) {
          final protocol = provider.savedProtocols[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: Color(protocol.colorValue),
                child: const Icon(Icons.science, color: Colors.white),
              ),
              title: Text(protocol.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${protocol.steps.length} pasos"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (c) => CreateTechniqueScreen(protocolToEdit: protocol)
                      ));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => provider.deleteProtocolTemplate(protocol.id),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.green.shade50),
                    icon: const Icon(Icons.play_arrow, color: Colors.green, size: 28),
                    onPressed: () => _startProtocolDialog(context, provider, protocol),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateTechniqueScreen()));
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  void _startProtocolDialog(BuildContext context, TimerProvider provider, ProtocolModel protocol) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Iniciar ${protocol.name}"),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: "Número de Muestra",
            hintText: "Ej. 104 - López",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                provider.startProtocol(protocol, ctrl.text);
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Técnica iniciada!"), backgroundColor: Colors.teal));
              }
            },
            child: const Text("INICIAR"),
          )
        ],
      ),
    );
  }
}

class CreateTechniqueScreen extends StatefulWidget {
  final ProtocolModel? protocolToEdit;

  const CreateTechniqueScreen({super.key, this.protocolToEdit});

  @override
  State<CreateTechniqueScreen> createState() => _CreateTechniqueScreenState();
}

class _CreateTechniqueScreenState extends State<CreateTechniqueScreen> {
  final _titleCtrl = TextEditingController();
  List<ProtocolStep> _steps = [];
  Color _selectedColor = Colors.teal;

  final List<Color> _colors = [Colors.teal, Colors.purple, Colors.orange, Colors.blue, Colors.red, Colors.pink, Colors.indigo];

  @override
  void initState() {
    super.initState();
    if (widget.protocolToEdit != null) {
      _titleCtrl.text = widget.protocolToEdit!.name;
      _selectedColor = Color(widget.protocolToEdit!.colorValue);
      _steps = List.from(widget.protocolToEdit!.steps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white);

    return Scaffold(
      appBar: AppBar(title: Text(widget.protocolToEdit == null ? "Nueva Técnica" : "Editar Técnica", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "Nombre de la Técnica",
                    hintText: "Ej. Tinción de Gram",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: cardColor,
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _colors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: isSelected ? 42 : 34,
                          height: isSelected ? 42 : 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: isSelected ? 10 : 4, offset: const Offset(0, 3))],
                            border: isSelected ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5) : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.all(16),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _steps.removeAt(oldIndex);
                  _steps.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _steps.length; i++)
                  Card(
                    key: ValueKey(_steps[i].id),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Text("${i + 1}", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(_steps[i].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_steps[i].type == StepType.timer
                          ? "${_steps[i].durationSeconds ~/ 60}m ${_steps[i].durationSeconds % 60}s${_steps[i].description.isNotEmpty ? ' - ${_steps[i].description}' : ''}"
                          : "${_steps[i].description}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _steps.removeAt(i)),
                      ),
                    ),
                  )
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addStepDialog(StepType.instruction),
                    icon: const Icon(Icons.text_fields),
                    label: const Text("Instrucción"),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addTimerStepDialog(),
                    icon: const Icon(Icons.timer),
                    label: const Text("Temporizador"),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _save,
                child: const Text("GUARDAR TÉCNICA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addStepDialog(StepType type) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Agregar Instrucción",  style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Título", hintText: "Ej. Lavar muestra", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar",  style: TextStyle(fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  _steps.add(ProtocolStep(
                    id: const Uuid().v4(),
                    type: StepType.instruction,
                    title: titleCtrl.text,
                    description: descCtrl.text,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Agregar",  style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _addTimerStepDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final hCtrl = TextEditingController(text: "0");
    final mCtrl = TextEditingController(text: "00");
    final sCtrl = TextEditingController(text: "00");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Agregar Temporizador",  style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Título", hintText: "Ej. Incubación", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripción (Opcional)", hintText: "Ej. Dejar en oscuridad", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimeInput(hCtrl, "Horas")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTimeInput(mCtrl, "Minutos")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTimeInput(sCtrl, "Segundos")),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar",  style: TextStyle(fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                final h = int.tryParse(hCtrl.text) ?? 0;
                final m = int.tryParse(mCtrl.text) ?? 0;
                final s = int.tryParse(sCtrl.text) ?? 0;
                final totalSeconds = (h * 3600) + (m * 60) + s;

                if (totalSeconds > 0) {
                  setState(() {
                    _steps.add(ProtocolStep(
                      id: const Uuid().v4(),
                      type: StepType.timer,
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      durationSeconds: totalSeconds,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text("Agregar",  style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController c, String label) {
    return Column(
      children: [
        TextField(
          controller: c, keyboardType: TextInputType.number, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(contentPadding: const EdgeInsets.all(10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
      ],
    );
  }

  void _save() {
    if (_titleCtrl.text.isEmpty || _steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Falta nombre o pasos")));
      return;
    }

    if (widget.protocolToEdit != null) {
      Provider.of<TimerProvider>(context, listen: false).deleteProtocolTemplate(widget.protocolToEdit!.id);
    }

    final newProtocol = ProtocolModel(id: const Uuid().v4(), name: _titleCtrl.text, colorValue: _selectedColor.value, steps: _steps);
    Provider.of<TimerProvider>(context, listen: false).saveProtocol(newProtocol);
    Navigator.pop(context);
  }
}