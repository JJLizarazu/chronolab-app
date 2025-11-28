import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final Map<String, double> _factors = {
    'Glucosa': 0.0555,
    'Colesterol': 0.0259,
    'Triglicéridos': 0.0113,
    'Urea': 0.166,
    'Creatinina': 88.4,
    'Ácido Úrico': 59.48,
    'Bilirrubina': 17.1,
  };

  final Map<String, String> _unitsSI = {
    'Glucosa': 'mmol/L',
    'Colesterol': 'mmol/L',
    'Triglicéridos': 'mmol/L',
    'Urea': 'mmol/L',
    'Creatinina': 'µmol/L',
    'Ácido Úrico': 'µmol/L',
    'Bilirrubina': 'µmol/L',
  };

  String _selectedTest = 'Glucosa';
  final TextEditingController _inputController = TextEditingController();
  String _result = "0.00";
  bool _toSI = true;

  void _calculate(String val) {
    if (val.isEmpty) {
      setState(() => _result = "0.00");
      return;
    }

    final double input = double.tryParse(val) ?? 0;
    final double factor = _factors[_selectedTest]!;
    double output;

    if (_toSI) {
      output = input * factor;
    } else {
      output = input / factor;
    }

    setState(() {
      _result = output.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white);
    final unitConv = "mg/dL";
    final unitSI = _unitsSI[_selectedTest]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversor de Unidades", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTest,
                    isExpanded: true,
                    icon: const Icon(Icons.science, color: Colors.teal),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87
                    ),
                    dropdownColor: cardColor,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTest = newValue!;
                        _calculate(_inputController.text);
                      });
                    },
                    items: _factors.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    // INPUT
                    _buildIOField(
                      label: _toSI ? "Convencional ($unitConv)" : "Internacional ($unitSI)",
                      controller: _inputController,
                      readOnly: false,
                      color: Colors.teal,
                      onChanged: _calculate,
                    ),
                    const SizedBox(height: 40),
                    _buildOutputField(
                      label: _toSI ? "Internacional ($unitSI)" : "Convencional ($unitConv)",
                      value: _result,
                      color: Colors.orange,
                    ),
                  ],
                ),

                Positioned(
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    onPressed: () {
                      setState(() {
                        _toSI = !_toSI;
                        _inputController.clear();
                        _result = "0.00";
                      });
                    },
                    child: const Icon(Icons.swap_vert, size: 28),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              _toSI
                  ? "Fórmula: $_selectedTest (mg/dL) x ${_factors[_selectedTest]} = $unitSI"
                  : "Fórmula: $_selectedTest ($unitSI) / ${_factors[_selectedTest]} = mg/dL",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOField({
    required String label,
    required TextEditingController controller,
    required bool readOnly,
    required Color color,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color.withOpacity(0.8), fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: color.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: color, width: 2),
        ),
        filled: true,
      ),
    );
  }

  Widget _buildOutputField({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}