import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/pulse.dart';
import '../../state/app_providers.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/app_drawer.dart';
import 'color_wheel.dart';
import 'models/scientific_question.dart';
import 'services/survey_scoring_service.dart';
import 'thanks_screen.dart';

const _logoAsset = 'assets/logo/rbm-logo.svg';

const Map<ScientificScale, String> _scaleDescriptions = {
  ScientificScale.gallupQ12:
      'Gallup Q12 measures inclusion and engagement signals.',
  ScientificScale.uwes: 'UWES tracks vigor, dedication, and absorption.',
  ScientificScale.phq2: 'PHQ-2 screens for mood dips needing care.',
  ScientificScale.inclusion:
      'Inclusion scale captures belonging in hybrid setups.',
  ScientificScale.jdR:
      'Job Demands-Resources (JD-R) highlights pressure vs. support.',
};

const Map<ScientificScale, IconData> _scaleIcons = {
  ScientificScale.gallupQ12: Icons.bar_chart_rounded,
  ScientificScale.uwes: Icons.stars_rounded,
  ScientificScale.phq2: Icons.favorite_border,
  ScientificScale.inclusion: Icons.diversity_2_rounded,
  ScientificScale.jdR: Icons.speed_rounded,
};

const Map<SurveyFactor, String> _factorDescriptions = {
  SurveyFactor.autonomy: 'How much agency you feel over decisions and craft.',
  SurveyFactor.workloadPressure: 'Deadlines, intensity, and demand spikes.',
  SurveyFactor.socialSupport: 'Peer safety nets and coaching availability.',
  SurveyFactor.feedbackQuality: 'Timely, actionable guidance from leads.',
  SurveyFactor.belonging: 'Connection to the team when remote/hybrid.',
};

const Map<SurveyFactor, IconData> _factorIcons = {
  SurveyFactor.autonomy: Icons.psychology,
  SurveyFactor.workloadPressure: Icons.timer_rounded,
  SurveyFactor.socialSupport: Icons.handshake,
  SurveyFactor.feedbackQuality: Icons.chat_bubble_outline,
  SurveyFactor.belonging: Icons.groups_2,
};

class SequentialCheckinScreen extends ConsumerStatefulWidget {
  const SequentialCheckinScreen({required this.profileId, super.key});

  final String profileId;

  @override
  ConsumerState<SequentialCheckinScreen> createState() =>
      _SequentialCheckinScreenState();
}

class _SequentialCheckinScreenState
    extends ConsumerState<SequentialCheckinScreen> {
  final _scoringService = const SurveyScoringService();
  final Map<String, QuestionResponse> _responses = {};
  final TextEditingController _noteController = TextEditingController();

  int _currentIndex = 0;
  String _selectedColor = '';
  double _valence = 50;
  double _energy = 50;
  bool _isSubmitting = false;
  late DateTime _flowStartedAt;
  late DateTime _questionStartedAt;

  ScientificQuestion get _currentQuestion =>
      scientificQuestionBank[_currentIndex];

  @override
  void initState() {
    super.initState();
    _flowStartedAt = DateTime.now();
    _questionStartedAt = _flowStartedAt;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_selectedColor.isEmpty) return;
    final dwell = DateTime.now().difference(_questionStartedAt);
    _responses[_currentQuestion.id] = QuestionResponse(
      color: _selectedColor,
      valence: _valence,
      energy: _energy,
      note: _noteController.text,
      dwellTime: dwell,
    );

    if (_currentIndex < scientificQuestionBank.length - 1) {
      setState(() {
        _currentIndex += 1;
        _selectedColor = '';
        _valence = 50;
        _energy = 50;
        _noteController.clear();
        _questionStartedAt = DateTime.now();
      });
    } else {
      _submitAll();
    }
  }

  Future<void> _submitAll() async {
    setState(() => _isSubmitting = true);
    final scoring = _scoringService.score(
      questions: scientificQuestionBank,
      responses: _responses,
    );

    final aggregatedNote = _responses.values
        .map((r) => r.note.trim())
        .where((text) => text.isNotEmpty)
        .join(' • ');

    final pulse = Pulse(
      profileId: widget.profileId,
      createdAt: DateTime.now(),
      color: scoring.dominantColor,
      energy: scoring.averageEnergy.round(),
      stress: _stressBand(scoring.burnoutRisk),
      focusScore: _focusBand(scoring.engagement),
      wellnessTags: scoring.recommendedActions,
      notes: aggregatedNote.isEmpty ? null : aggregatedNote,
      sentimentScore: scoring.sentimentScore,
      responseTime: DateTime.now().difference(_flowStartedAt),
      attentionCheckPassed: scoring.attentionCheckPassed,
      burnoutRiskScore: scoring.burnoutRisk,
      engagementScore: scoring.engagement,
      questionResponses:
          _responses.map((key, value) => MapEntry(key, value.toJson())),
      factorScores:
          scoring.factorScores.map((key, value) => MapEntry(key.name, value)),
    );

    try {
      await ref.read(pulseRepoProvider).submitPulse(pulse);
      if (!mounted) return;
      // Navigate to thanks screen, then pop back to main when done
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ThanksScreen(
            burnoutScore: scoring.burnoutRisk,
            engagementScore: scoring.engagement,
            moodSummary: _moodSummary(scoring),
            personalTips: scoring.recommendedActions.isEmpty
                ? const [
                    'Keep sharing what supports your best work.',
                    'Take a restorative pause before the next sprint.',
                  ]
                : scoring.recommendedActions,
            color: scoring.dominantColor,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  int _stressBand(double burnout) {
    if (burnout >= 75) return 5;
    if (burnout >= 55) return 4;
    if (burnout >= 40) return 3;
    if (burnout >= 25) return 2;
    return 1;
  }

  int _focusBand(double engagement) {
    if (engagement >= 75) return 9;
    if (engagement >= 55) return 8;
    if (engagement >= 40) return 7;
    return 5;
  }

  String _moodSummary(SurveyAggregateScore scoring) {
    if (scoring.factorScores.isEmpty) {
      return 'We captured your current mood and energy.';
    }
    final highest = scoring.factorScores.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final lowest = scoring.factorScores.entries.reduce(
      (a, b) => a.value <= b.value ? a : b,
    );
    return 'High energy in ${_factorLabel(highest.key)} while ${_factorLabel(lowest.key)} could use support.';
  }

  String _scaleLabel(ScientificScale scale) {
    switch (scale) {
      case ScientificScale.gallupQ12:
        return 'Gallup Q12';
      case ScientificScale.uwes:
        return 'UWES';
      case ScientificScale.phq2:
        return 'PHQ-2';
      case ScientificScale.inclusion:
        return 'Inclusion';
      case ScientificScale.jdR:
        return 'JD-R';
    }
  }

  String _factorLabel(SurveyFactor factor) {
    switch (factor) {
      case SurveyFactor.autonomy:
        return 'Autonomy';
      case SurveyFactor.workloadPressure:
        return 'Workload Pressure';
      case SurveyFactor.socialSupport:
        return 'Social Support';
      case SurveyFactor.feedbackQuality:
        return 'Feedback Quality';
      case SurveyFactor.belonging:
        return 'Sense of Belonging';
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = scientificQuestionBank.length;
    final question = _currentQuestion;

    // Get user info for drawer
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id ?? widget.profileId;
    const userRole = 'employee'; // Default, could be fetched from profile

    return Scaffold(
      drawer: AppDrawer(
        userId: userId,
        role: userRole,
      ),
      appBar: AppHeader(
        title: 'Pulse Survey - Well-Being Index',
        showMenu: true,
        showBackButton: false,
        userId: userId,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: const Color(0xFF1B1B1B),
                                    border: Border.all(color: Colors.white12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: SvgPicture.asset(_logoAsset),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'RBM-Pulse Check-in',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Use the color wheel, sliders, and quick note to log your scientific pulse.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Q${_currentIndex + 1}/$total',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  question.prompt,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Tooltip(
                                      message:
                                          _scaleDescriptions[question.scale] ??
                                              '',
                                      child: Chip(
                                        avatar: Icon(
                                          _scaleIcons[question.scale],
                                          size: 18,
                                        ),
                                        label:
                                            Text(_scaleLabel(question.scale)),
                                      ),
                                    ),
                                    Tooltip(
                                      message: _factorDescriptions[
                                              question.factor] ??
                                          '',
                                      child: Chip(
                                        avatar: Icon(
                                          _factorIcons[question.factor],
                                          size: 18,
                                        ),
                                        label:
                                            Text(_factorLabel(question.factor)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1C1C),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline,
                                          color: Colors.white70),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _scaleDescriptions[question.scale] ??
                                              '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ColorWheel(
                                  selectedColor: _selectedColor,
                                  onSelected: (color) =>
                                      setState(() => _selectedColor = color),
                                ),
                                const SizedBox(height: 12),
                                _SliderCard(
                                  title: 'Feeling (Valence)',
                                  subtitle: 'Unpleasant 😔 — Pleasant 😊',
                                  value: _valence,
                                  icon: Icons.mood,
                                  accentColor: const Color(0xFF00C9A7),
                                  onChanged: (value) => setState(
                                    () => _valence = value.roundToDouble(),
                                  ),
                                ),
                                _SliderCard(
                                  title: 'Energy (Arousal)',
                                  subtitle: 'Exhausted 😴 — Energized ⚡',
                                  value: _energy,
                                  icon: Icons.bolt,
                                  accentColor: const Color(0xFFFFA500),
                                  onChanged: (value) => setState(
                                    () => _energy = value.roundToDouble(),
                                  ),
                                ),
                                TextField(
                                  controller: _noteController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Short context (optional)',
                                    prefixIcon:
                                        const Icon(Icons.edit_note_outlined),
                                    filled: true,
                                    fillColor: const Color(0xFF111111),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  minLines: 1,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed:
                                _selectedColor.isNotEmpty ? _handleNext : null,
                            child: Text(
                              _currentIndex < total - 1 ? 'Next' : 'Submit',
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final double value;
  final ValueChanged<double> onChanged;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accentColor.withOpacity(0.2),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: accentColor,
              activeTrackColor: accentColor,
              inactiveTrackColor: Colors.white12,
              overlayColor: accentColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0,
              max: 100,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              value.round().toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
