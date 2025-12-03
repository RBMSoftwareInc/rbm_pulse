import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/pulse_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/pulse.dart';
import '../app_providers.dart';

enum CheckinPhase { main, extra }

class ExtraQuestion {
  final String id;
  final String text;
  final String scale;
  ExtraQuestion({required this.id, required this.text, required this.scale});
}

class CheckinState {
  final String color;
  final double valence;
  final double energy;
  final CheckinPhase phase;
  final DateTime startedAt;
  final ExtraQuestion? extraQuestion;
  final double extraAnswer;

  CheckinState({
    required this.color,
    required this.valence,
    required this.energy,
    required this.phase,
    required this.startedAt,
    this.extraQuestion,
    required this.extraAnswer,
  });

  bool get canSubmitMain => color.isNotEmpty;

  CheckinState copyWith({
    String? color,
    double? valence,
    double? energy,
    CheckinPhase? phase,
    DateTime? startedAt,
    ExtraQuestion? extraQuestion,
    double? extraAnswer,
  }) {
    return CheckinState(
      color: color ?? this.color,
      valence: valence ?? this.valence,
      energy: energy ?? this.energy,
      phase: phase ?? this.phase,
      startedAt: startedAt ?? this.startedAt,
      extraQuestion: extraQuestion ?? this.extraQuestion,
      extraAnswer: extraAnswer ?? this.extraAnswer,
    );
  }
}

final checkinControllerProvider =
    StateNotifierProvider<CheckinController, CheckinState>((ref) {
  final pulseRepo = ref.read(pulseRepoProvider);
  final profileRepo = ref.read(profileRepoProvider);
  return CheckinController(pulseRepo, profileRepo);
});

class CheckinController extends StateNotifier<CheckinState> {
  final PulseRepository _pulseRepo;
  final ProfileRepository _profileRepo;

  CheckinController(this._pulseRepo, this._profileRepo)
      : super(
          CheckinState(
            color: '',
            valence: 50,
            energy: 50,
            phase: CheckinPhase.main,
            startedAt: DateTime.now(),
            extraAnswer: 5,
          ),
        );

  void setColor(String color) {
    state = state.copyWith(color: color);
  }

  void setValence(double value) {
    state = state.copyWith(valence: value);
  }

  void setEnergy(double value) {
    state = state.copyWith(energy: value);
  }

  void setExtraAnswer(double value) {
    state = state.copyWith(extraAnswer: value);
  }

  void onMainNext() {
    if (_needsExtraQuestion(state.color)) {
      final q = _pickRandomQuestion();
      state = state.copyWith(
        phase: CheckinPhase.extra,
        extraQuestion: q,
      );
    } else {
      submitAll();
    }
  }

  bool _needsExtraQuestion(String color) {
    const risky = {
      'Yellow',
      'Orange',
      'Red',
      'Purple',
      'Grey',
      'Pink',
    };
    return risky.contains(color);
  }

  ExtraQuestion _pickRandomQuestion() {
    return ExtraQuestion(
      id: 'phq2_item1',
      text:
          'Over the last 2 weeks, how often have you felt little interest or pleasure in doing things?',
      scale: 'PHQ2',
    );
  }

  Future<bool> submitAll() async {
    try {
      final profile = await _profileRepo.getOrCreateAnonymousProfile();
      final now = DateTime.now();
      final responseTime = now.difference(state.startedAt);
      final suspicious = responseTime.inSeconds < 3;

      final pulse = Pulse(
        profileId: profile.id,
        createdAt: now,
        color: state.color,
        energy: state.energy.round(),
        stress: _deriveStress(),
        focusScore: _deriveFocus(),
        wellnessTags: const [],
        notes: null,
        sentimentScore: null,
        responseTime: responseTime,
        attentionCheckPassed: !suspicious,
      );

      await _pulseRepo.submitPulse(pulse);
      return true;
    } catch (_) {
      return false;
    }
  }

  int _deriveStress() {
    final val = state.valence;
    if (val > 70) return 1;
    if (val > 40) return 2;
    if (val > 30) return 3;
    if (val > 20) return 4;
    return 5;
  }

  int _deriveFocus() {
    if (state.energy > 70) return 8;
    if (state.energy > 40) return 6;
    return 4;
  }
}
