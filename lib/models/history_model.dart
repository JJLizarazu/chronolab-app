class HistoryItem {
  final String id;
  final String label;
  final int durationSeconds;
  final DateTime finishTime;
  final int colorValue;

  HistoryItem({
    required this.id,
    required this.label,
    required this.durationSeconds,
    required this.finishTime,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'durationSeconds': durationSeconds,
      'finishTime': finishTime.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      label: json['label'],
      durationSeconds: json['durationSeconds'],
      finishTime: DateTime.parse(json['finishTime']),
      colorValue: json['colorValue'],
    );
  }
}