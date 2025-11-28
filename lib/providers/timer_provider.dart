import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/timer_model.dart';
import '../models/history_model.dart';
import '../models/protocol_model.dart';
import '../utils/notification_helper.dart';
import '../utils/sound_helper.dart';

class TimerProvider with ChangeNotifier {
  List<TimerModel> _timers = [];
  List<HistoryItem> _history = [];
  List<ProtocolModel> _savedProtocols = [];
  List<ActiveProtocol> _activeProtocols = [];

  Timer? _globalTicker;
  bool _isWakelockEnabled = false;

  bool _isGridView = false;
  bool _enableOvertime = true;
  String _selectedSound = 'alarm_1.mp3';

  List<TimerModel> get timers => _timers;

  List<HistoryItem> get history => _history;

  List<ProtocolModel> get savedProtocols => _savedProtocols;

  List<ActiveProtocol> get activeProtocols => _activeProtocols;

  bool get isGridView => _isGridView;

  bool get enableOvertime => _enableOvertime;

  String get selectedSound => _selectedSound;

  TimerProvider() {
    _loadData();
    _startGlobalTicker();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _isGridView = prefs.getBool('cfg_grid_view') ?? false;
    _enableOvertime = prefs.getBool('cfg_overtime') ?? true;
    _selectedSound = prefs.getString('cfg_sound') ?? 'alarm_1.mp3';

    if (prefs.containsKey('saved_timers')) {
      final String? data = prefs.getString('saved_timers');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _timers = decoded.map((item) => TimerModel.fromJson(item)).toList();
      }
    }

    if (prefs.containsKey('saved_protocols')) {
      final String? pData = prefs.getString('saved_protocols');
      if (pData != null) {
        final List<dynamic> decodedP = jsonDecode(pData);
        _savedProtocols = decodedP
            .map((item) => ProtocolModel.fromJson(item))
            .toList();
      }
    }
    notifyListeners();
  }

  void saveProtocol(ProtocolModel protocol) {
    _savedProtocols.add(protocol);
    _persistProtocols();
    notifyListeners();
  }

  void deleteProtocolTemplate(String id) {
    _savedProtocols.removeWhere((p) => p.id == id);
    _persistProtocols();
    notifyListeners();
  }

  Future<void> _persistProtocols() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(
      _savedProtocols.map((p) => p.toJson()).toList(),
    );
    await prefs.setString('saved_protocols', data);
  }

  void startProtocol(ProtocolModel protocol, String sampleName) {
    final active = ActiveProtocol(
      instanceId: const Uuid().v4(),
      sampleName: sampleName,
      protocol: protocol,
    );
    _activeProtocols.add(active);
    notifyListeners();
  }

  void nextProtocolStep(String instanceId) {
    final index = _activeProtocols.indexWhere(
      (p) => p.instanceId == instanceId,
    );
    if (index != -1) {
      _activeProtocols[index].nextStep();
      stopAlarm();
      notifyListeners();
    }
  }

  void toggleProtocolTimer(String instanceId) {
    stopAlarm();
    final index = _activeProtocols.indexWhere(
      (p) => p.instanceId == instanceId,
    );
    if (index != -1) {
      final p = _activeProtocols[index];
      if (p.protocol.steps[p.currentStepIndex].type == StepType.timer) {
        p.isRunning = !p.isRunning;
        notifyListeners();
      }
    }
  }

  void restartActiveProtocol(String instanceId) {
    final index = _activeProtocols.indexWhere(
      (p) => p.instanceId == instanceId,
    );
    if (index != -1) {
      final old = _activeProtocols[index];
      _activeProtocols[index] = ActiveProtocol(
        instanceId: old.instanceId,
        sampleName: old.sampleName,
        protocol: old.protocol,
      );
      stopAlarm();
      notifyListeners();
    }
  }

  void restartProtocolStep(String instanceId) {
    stopAlarm();
    final index = _activeProtocols.indexWhere(
      (p) => p.instanceId == instanceId,
    );
    if (index != -1) {
      final p = _activeProtocols[index];
      final step = p.protocol.steps[p.currentStepIndex];
      if (step.type == StepType.timer) {
        p.currentStepRemaining = Duration(seconds: step.durationSeconds);
        p.isRunning = false;
        p.isStepFinished = false;
        notifyListeners();
      }
    }
  }

  void cancelActiveProtocol(String instanceId) {
    _activeProtocols.removeWhere((p) => p.instanceId == instanceId);
    stopAlarm();
    notifyListeners();
  }

  void stopAlarm() {
    SoundHelper.stop();
    Vibration.cancel();
  }

  void _startGlobalTicker() {
    _globalTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool needsNotify = false;
      bool anyRunning = false;
      bool justFinished = false;

      for (var t in _timers) {
        if (t.isRunning) {
          anyRunning = true;
          t.remainingTime -= const Duration(seconds: 1);
          needsNotify = true;

          if (t.remainingTime.inSeconds == 0) {
            NotificationHelper.showTimerFinished(t.id, t.label);
            _addToHistory(t.label, t.initialDuration.inSeconds, t.color.value);
            justFinished = true;
            if (!_enableOvertime) t.isRunning = false;
          }
        }
      }

      for (var p in _activeProtocols) {
        final currentStep = p.protocol.steps[p.currentStepIndex];

        if (currentStep.type == StepType.timer &&
            p.isRunning &&
            !p.isStepFinished) {
          anyRunning = true;
          p.currentStepRemaining -= const Duration(seconds: 1);
          needsNotify = true;

          if (p.currentStepRemaining.inSeconds == 0) {
            p.isStepFinished = true;
            p.isRunning = false;
            NotificationHelper.showTimerFinished(
              p.instanceId,
              "${p.sampleName}: ${currentStep.title}",
            );
            justFinished = true;
          }
        }
      }

      if (justFinished) SoundHelper.playAlarm(_selectedSound);
      _manageWakelock(anyRunning);
      if (needsNotify) notifyListeners();
    });
  }

  void _addToHistory(String label, int seconds, int colorVal) {
    final item = HistoryItem(
      id: const Uuid().v4(),
      label: label,
      durationSeconds: seconds,
      finishTime: DateTime.now(),
      colorValue: colorVal,
    );
    _history.insert(0, item);
    if (_history.length > 100) _history.removeLast();
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_history.map((h) => h.toJson()).toList());
    await prefs.setString('saved_history', data);
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cfg_grid_view', _isGridView);
    await prefs.setBool('cfg_overtime', _enableOvertime);
    await prefs.setString('cfg_sound', _selectedSound);
    notifyListeners();
  }

  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_timers.map((t) => t.toJson()).toList());
    await prefs.setString('saved_timers', data);
  }

  void _manageWakelock(bool shouldEnable) {
    if (shouldEnable && !_isWakelockEnabled) {
      WakelockPlus.enable();
      _isWakelockEnabled = true;
    } else if (!shouldEnable && _isWakelockEnabled) {
      WakelockPlus.disable();
      _isWakelockEnabled = false;
    }
  }

  void addTimer(String label, Duration duration, Color color) {
    final newTimer = TimerModel(
      id: const Uuid().v4(),
      label: label,
      initialDuration: duration,
      remainingTime: duration,
      color: color,
      isRunning: true,
    );
    _timers.add(newTimer);
    _saveTimers();
    notifyListeners();
  }

  void toggleTimer(String id) {
    stopAlarm();
    final index = _timers.indexWhere((t) => t.id == id);
    if (index != -1) {
      if (timers[index].isFinished && !_enableOvertime) return;
      _timers[index].isRunning = !_timers[index].isRunning;
      _saveTimers();
      notifyListeners();
    }
  }

  void resetTimer(String id) {
    stopAlarm();
    final index = _timers.indexWhere((t) => t.id == id);
    if (index != -1) {
      _timers[index].remainingTime = _timers[index].initialDuration;
      _timers[index].isRunning = true;
      _saveTimers();
      notifyListeners();
    }
  }

  void deleteTimer(String id) {
    stopAlarm();
    _timers.removeWhere((t) => t.id == id);
    _saveTimers();
    notifyListeners();
  }

  void addOneMinute(String id) {
    stopAlarm();
    final index = _timers.indexWhere((t) => t.id == id);
    if (index != -1) {
      _timers[index].remainingTime += const Duration(minutes: 1);
      if (!_timers[index].isRunning && !_enableOvertime)
        _timers[index].isRunning = true;
      _saveTimers();
      notifyListeners();
    }
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  void clearAllTimers() {
    stopAlarm();
    _timers.clear();
    _activeProtocols.clear();
    _saveTimers();
    notifyListeners();
  }

  void setGridView(bool value) {
    _isGridView = value;
    _saveConfig();
  }

  void setOvertime(bool value) {
    _enableOvertime = value;
    _saveConfig();
  }

  void setSound(String fileName) {
    _selectedSound = fileName;
    _saveConfig();
    SoundHelper.preview(fileName);
  }

  @override
  void dispose() {
    _globalTicker?.cancel();
    super.dispose();
  }
}
