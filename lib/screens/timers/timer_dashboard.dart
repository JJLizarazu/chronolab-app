import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timer_provider.dart';
import 'widgets/timer_card.dart';
import 'widgets/protocol_card.dart';
import 'create_timer_sheet.dart';

class TimerDashboard extends StatelessWidget {
  const TimerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final timerData = Provider.of<TimerProvider>(context);
    final timers = timerData.timers;
    final protocols = timerData.activeProtocols;
    final isGrid = timerData.isGridView;

    final totalItems = timers.length + protocols.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: totalItems == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("Sin actividades", style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (protocols.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text("TÉCNICAS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ...protocols.map((p) => ProtocolCard(active: p)).toList(),
            const SizedBox(height: 16),
          ],

          if (timers.isNotEmpty && protocols.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text("TEMPORIZADORES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),

          if (isGrid)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: timers.length,
              itemBuilder: (ctx, i) => TimerCard(timer: timers[timers.length - 1 - i], isCompact: true),
            )
          else
            ...timers.reversed.map((t) => TimerCard(timer: t, isCompact: false)).toList(),

          const SizedBox(height: 80),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (ctx) => const CreateTimerSheet(),
          );
        },
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}