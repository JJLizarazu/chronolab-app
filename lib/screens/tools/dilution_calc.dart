import 'package:flutter/material.dart';

class DilutionCalcScreen extends StatefulWidget {
  const DilutionCalcScreen({super.key});

  @override
  State<DilutionCalcScreen> createState() => _DilutionCalcScreenState();
}

class _DilutionCalcScreenState extends State<DilutionCalcScreen> {
  final _totalVolumeController = TextEditingController();
  final _dilutionFactorController = TextEditingController();

  double _sampleAmount = 0;
  double _diluentAmount = 0;
  double _currentFactor = 0;
  bool _hasResult = false;

  void _calculate() {
    final totalVolume = double.tryParse(_totalVolumeController.text);
    final factor = double.tryParse(_dilutionFactorController.text);

    setState(() {
      if (totalVolume != null && factor != null && factor > 1) {
        _currentFactor = factor;
        _sampleAmount = totalVolume / factor;
        _diluentAmount = totalVolume - _sampleAmount;
        _hasResult = true;
        FocusScope.of(context).unfocus();
      } else {
        _hasResult = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Revisa los datos. El factor debe ser mayor a 1."), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _clear() {
    setState(() {
      _totalVolumeController.clear();
      _dilutionFactorController.clear();
      _hasResult = false;
      _sampleAmount = 0;
      _diluentAmount = 0;
    });
  }

  String _formatNumber(double num) {
    return num.toStringAsFixed(num % 1 == 0 ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calcular Dilución", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _totalVolumeController,
                      label: "Volumen Total Deseado",
                      hint: "",
                      suffix: "ul / ml",
                      icon: Icons.opacity,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _dilutionFactorController,
                      label: "Factor de Dilución",
                      hint: "",
                      suffix: "X",
                      icon: Icons.science,
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [2, 5, 10, 20, 50, 100].map((val) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4.6),
                            child: ActionChip(
                              label: Text("x$val"),
                              backgroundColor: Colors.teal.withOpacity(0.1),
                              labelStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                              side: BorderSide.none,
                              onPressed: () {
                                _dilutionFactorController.text = val.toString();
                                if (_totalVolumeController.text.isNotEmpty) _calculate();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 4,
                shadowColor: Colors.teal.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("CALCULAR MEZCLA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),

            const SizedBox(height: 32),

            if (_hasResult) ...[
              const Divider(),
              const SizedBox(height: 16),

              Text(
                "Receta para: x${_formatNumber(_currentFactor)}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTubeVisual(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildResultCard(
                            title: "DILUYENTE",
                            value: _formatNumber(_diluentAmount),
                            subtitle: "Reactivo / Agua",
                            color: const Color(0xFF2196F3),
                            icon: Icons.water_drop,
                            cardColor: cardColor,
                            isDark: isDark
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        _buildResultCard(
                            title: "MUESTRA",
                            value: _formatNumber(_sampleAmount),
                            subtitle: "Suero / Sangre",
                            color: const Color(0xFFE91E63),
                            icon: Icons.bloodtype,
                            cardColor: cardColor,
                            isDark: isDark
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      "Volumen Final: ${_formatNumber(_sampleAmount + _diluentAmount)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: Colors.teal.shade300),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTubeVisual() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: (_diluentAmount * 10).toInt(),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                ),
              ),
              Expanded(
                flex: (_sampleAmount * 10).toInt(),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}