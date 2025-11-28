import 'package:flutter/material.dart';

class TimerModel {
  final String id;
  String label;
  Duration initialDuration;
  Duration remainingTime;
  bool isRunning;
  Color color;

  DateTime? lastSavedTime;

  TimerModel({
    required this.id,
    required this.label,
    required this.initialDuration,
    required this.color,
    this.remainingTime = Duration.zero,
    this.isRunning = false,
    this.lastSavedTime,
  }) {
    if (remainingTime == Duration.zero && initialDuration > Duration.zero) {
      remainingTime = initialDuration;
    }
  }

  bool get isFinished => remainingTime.inSeconds <= 0;
  bool get isOvertime => remainingTime.isNegative;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'initialDuration': initialDuration.inSeconds,
      'remainingTime': remainingTime.inSeconds,
      'isRunning': isRunning,
      'color': color.value,
      'lastSavedTime': DateTime.now().toIso8601String(),
    };
  }

  factory TimerModel.fromJson(Map<String, dynamic> json) {
    var model = TimerModel(
      id: json['id'],
      label: json['label'],
      initialDuration: Duration(seconds: json['initialDuration']),
      remainingTime: Duration(seconds: json['remainingTime']),
      isRunning: json['isRunning'],
      color: Color(json['color']),
      lastSavedTime: json['lastSavedTime'] != null
          ? DateTime.parse(json['lastSavedTime'])
          : null,
    );

    if (model.isRunning && model.lastSavedTime != null) {
      final timePassed = DateTime.now().difference(model.lastSavedTime!);
      model.remainingTime -= timePassed;
    }

    return model;
  }
}