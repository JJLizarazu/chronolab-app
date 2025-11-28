import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum StepType { instruction, timer }

class ProtocolStep {
  final String id;
  final StepType type;
  final String title;
  final String description;
  final int durationSeconds;

  ProtocolStep({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'title': title,
    'description': description,
    'durationSeconds': durationSeconds,
  };

  factory ProtocolStep.fromJson(Map<String, dynamic> json) {
    return ProtocolStep(
      id: json['id'],
      type: json['type'] == 'StepType.timer' ? StepType.timer : StepType.instruction,
      title: json['title'],
      description: json['description'],
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }
}

class ProtocolModel {
  final String id;
  final String name;
  final int colorValue;
  final List<ProtocolStep> steps;

  ProtocolModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory ProtocolModel.fromJson(Map<String, dynamic> json) {
    return ProtocolModel(
      id: json['id'],
      name: json['name'],
      colorValue: json['colorValue'],
      steps: (json['steps'] as List).map((s) => ProtocolStep.fromJson(s)).toList(),
    );
  }
}

class ActiveProtocol {
  final String instanceId;
  final String sampleName;
  final ProtocolModel protocol;
  int currentStepIndex;

  Duration currentStepRemaining;
  bool isRunning;
  bool isStepFinished;

  ActiveProtocol({
    required this.instanceId,
    required this.sampleName,
    required this.protocol,
    this.currentStepIndex = 0,
    this.currentStepRemaining = Duration.zero,
    this.isRunning = false,
    this.isStepFinished = false,
  }) {
    if (currentStepRemaining == Duration.zero && protocol.steps.isNotEmpty) {
      _initCurrentStep();
    }
  }

  void _initCurrentStep() {
    final step = protocol.steps[currentStepIndex];
    if (step.type == StepType.timer) {
      currentStepRemaining = Duration(seconds: step.durationSeconds);
    } else {
      currentStepRemaining = Duration.zero;
    }
    isRunning = false;
    isStepFinished = false;
  }

  void nextStep() {
    if (currentStepIndex < protocol.steps.length - 1) {
      currentStepIndex++;
      _initCurrentStep();
    } else {
      isStepFinished = true;
    }
  }
}