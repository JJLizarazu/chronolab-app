import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/timer_model.dart';
import '../../../../providers/timer_provider.dart';

class TimerCard extends StatelessWidget {
  final TimerModel timer;
  final bool isCompact;

  const TimerCard({super.key, required this.timer, this.isCompact = false});

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours.abs();
    final minutes = d.inMinutes.remainder(60).abs();
    final seconds = d.inSeconds.remainder(60).abs();
    final sign = d.isNegative ? '-' : '';

    if (hours > 0) {
      return "$sign$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "$sign${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color baseColor = timer.color;
    Color bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    Color timeColor = isDark ? Colors.white : Colors.black87;

    if (timer.isOvertime) {
      baseColor = Colors.red;
      bgColor = isDark ? const Color(0xFF3F0000) : Colors.red.shade50;
      timeColor = isDark ? Colors.redAccent : Colors.red.shade900;
    } else if (!timer.isRunning && timer.initialDuration != timer.remainingTime) {
      baseColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 0 : 16), // Sin margen si es grid
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : baseColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: timer.isOvertime
            ? Border.all(color: isDark ? Colors.redAccent.withOpacity(0.5) : Colors.red.shade200)
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 10.0 : 20.0),
        child: isCompact
            ? _buildCompactLayout(context, provider, timeColor, baseColor, isDark)
            : _buildFullLayout(context, provider, timeColor, baseColor, isDark),
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context, TimerProvider provider, Color timeColor, Color baseColor, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.science, color: baseColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timer.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
                  if (timer.isOvertime)
                    Text("EXCEDIDO", style: TextStyle(color: isDark ? Colors.redAccent : Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                  else if (!timer.isRunning)
                    Text("Pausado", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Text(_formatTime(timer.remainingTime), style: TextStyle(fontSize: 36, fontFamily: 'monospace', fontWeight: FontWeight.w700, color: timeColor)),
          ],
        ),
        const SizedBox(height: 20),
        _buildButtonRow(provider, baseColor, isDark),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context, TimerProvider provider, Color timeColor, Color baseColor, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.science, color: baseColor, size: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                    timer.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.black54, fontWeight: FontWeight.w500)
                ),
              ),
            ),
          ],
        ),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatTime(timer.remainingTime),
            style: TextStyle(fontSize: 28, fontFamily: 'monospace', fontWeight: FontWeight.w700, color: timeColor),
          ),
        ),

        if (timer.isOvertime)
          Text("TIEMPO EXTRA", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Restart
            _ActionButton(
              icon: Icons.replay,
              color: Colors.grey,
              onTap: () => provider.resetTimer(timer.id),
              isDark: isDark,
              size: 18,
            ),

            InkWell(
              onTap: () => provider.toggleTimer(timer.id),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: timer.isRunning
                      ? (isDark ? Colors.amber.withOpacity(0.2) : Colors.amber.shade100)
                      : (isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50),
                  shape: BoxShape.circle,
                  border: Border.all(color: timer.isRunning ? Colors.amber : Colors.teal, width: 2),
                ),
                child: Icon(
                    timer.isRunning ? Icons.pause : Icons.play_arrow_rounded,
                    size: 24,
                    color: timer.isRunning ? (isDark ? Colors.amber : Colors.amber.shade800) : Colors.teal
                ),
              ),
            ),

            _ActionButton(
              icon: Icons.delete_outline,
              color: Colors.grey,
              onTap: () => provider.deleteTimer(timer.id),
              isDark: isDark,
              size: 18,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildButtonRow(TimerProvider provider, Color baseColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          _ActionButton(icon: Icons.replay, color: Colors.grey, onTap: () => provider.resetTimer(timer.id), isDark: isDark),
          const SizedBox(width: 8),
          _ActionButton(icon: Icons.delete_outline, color: Colors.grey, onTap: () => provider.deleteTimer(timer.id), isDark: isDark),
        ]),
        Row(children: [
          TextButton(onPressed: () => provider.addOneMinute(timer.id), child: const Text("+1 MIN")),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => provider.toggleTimer(timer.id),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: timer.isRunning ? (isDark ? Colors.amber.withOpacity(0.2) : Colors.amber.shade100) : (isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50),
                shape: BoxShape.circle,
                border: Border.all(color: timer.isRunning ? Colors.amber : Colors.teal, width: 2),
              ),
              child: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow_rounded, color: timer.isRunning ? Colors.amber.shade800 : Colors.teal, size: 32),
            ),
          ),
        ]),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: isDark ? Colors.white10 : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Icon(icon, color: isDark ? Colors.grey.shade400 : color, size: size),
      ),
    );
  }
}