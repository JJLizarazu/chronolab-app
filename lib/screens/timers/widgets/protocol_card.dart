import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/protocol_model.dart';
import '/providers/timer_provider.dart';

class ProtocolCard extends StatelessWidget {
  final ActiveProtocol active;

  const ProtocolCard({super.key, required this.active});

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "$h:${twoDigits(m)}:${twoDigits(s)}";
    return "${twoDigits(m)}:${twoDigits(s)}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Color(active.protocol.colorValue);

    final currentStep = active.protocol.steps[active.currentStepIndex];
    final bool isLastStep =
        active.currentStepIndex >= active.protocol.steps.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active.sampleName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        active.protocol.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () =>
                      provider.cancelActiveProtocol(active.instanceId),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "PASO ${active.currentStepIndex + 1} / ${active.protocol.steps.length}",
                        style: TextStyle(
                          color: baseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        currentStep.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (currentStep.type == StepType.timer)
                  Column(
                    children: [
                      if (currentStep.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            currentStep.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      Text(
                        _formatTime(active.currentStepRemaining),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: active.isStepFinished
                              ? Colors.red
                              : (isDark ? Colors.white : Colors.black87),
                          fontFamily: 'monospace',
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (!active.isStepFinished)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () => provider.restartProtocolStep(
                                active.instanceId,
                              ),
                              icon: const Icon(Icons.replay),
                              iconSize: 28,
                              padding: const EdgeInsets.all(12),
                            ),
                            const SizedBox(width: 20),
                            IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: active.isRunning
                                    ? Colors.amber
                                    : Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => provider.toggleProtocolTimer(
                                active.instanceId,
                              ),
                              icon: Icon(
                                active.isRunning
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              iconSize: 28,
                              padding: const EdgeInsets.all(12),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => provider.stopAlarm(),
                                icon: const Icon(Icons.volume_off),
                                label: const Text("DETENER"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () => provider.restartProtocolStep(
                                active.instanceId,
                              ),
                              icon: const Icon(Icons.replay),
                              tooltip: "Reiniciar paso",
                              padding: const EdgeInsets.all(12),
                            ),
                          ],
                        ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentStep.description.isNotEmpty
                              ? currentStep.description
                              : "Sigue las instrucciones del laboratorio.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20, // ¡MÁS GRANDE!
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                if (currentStep.type == StepType.instruction ||
                    active.isStepFinished)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: baseColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (isLastStep) {
                          // Fin total
                          provider.cancelActiveProtocol(active.instanceId);
                        } else {
                          provider.nextProtocolStep(active.instanceId);
                        }
                      },
                      label: Text(
                        isLastStep ? "FINALIZAR PROTOCOLO" : "SIGUIENTE PASO",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
