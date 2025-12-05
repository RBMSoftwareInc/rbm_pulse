#!/usr/bin/env bash
set -e

APP_NAME="rbm_pulse"

echo "==> Creating Flutter project ${APP_NAME}..."
flutter create --platforms=android,ios,web ${APP_NAME}

cd ${APP_NAME}

echo "==> Updating pubspec.yaml..."
cat > pubspec.yaml << 'EOF'
name: rbm_pulse
description: Internal wellbeing app (RBM-Pulse) using Flutter + Supabase.
publish_to: "none"

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.5.0
  connectivity_plus: ^6.0.3
  uuid: ^4.5.0
  shared_preferences: ^2.3.2
  flutter_local_notifications: ^17.2.2
  url_launcher: ^6.3.0
  intl: ^0.19.0
  lottie: ^3.1.2
  flutter_haptic: ^0.5.0
  fl_chart: ^0.69.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/lottie/color_wheel.json
  fonts:
    - family: Satoshi
      fonts:
        - asset: assets/fonts/Satoshi-Regular.ttf
        - asset: assets/fonts/Satoshi-Medium.ttf
        - asset: assets/fonts/Satoshi-Bold.ttf
EOF

echo "==> Creating folders..."
mkdir -p assets/lottie
mkdir -p assets/fonts
mkdir -p lib/{core/{env,theme,routing,utils,widgets},data/{models,repositories,offline},features/{onboarding,auth,checkin,dashboard,admin,notifications},state/checkin}

echo "==> Placing placeholder Lottie and fonts notes..."
cat > assets/lottie/README.txt << 'EOF'
Put your color wheel Lottie file here as color_wheel.json.
EOF

cat > assets/fonts/README.txt << 'EOF'
Add Satoshi font TTF files here and update pubspec.yaml paths if needed.
EOF

echo "==> Writing lib/core/env/constants.dart..."
cat > lib/core/env/constants.dart << 'EOF'
class Env {
  static const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static const attentionCheckMinDays = 10;
  static const attentionCheckMaxDays = 14;

  static const minGroupSizeForAggregation = 10;
}
EOF

echo "==> Writing lib/data/supabase_client.dart..."
cat > lib/data/supabase_client.dart << 'EOF'
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/env/constants.dart';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
}
EOF

echo "==> Writing lib/core/utils/device_id.dart..."
cat > lib/core/utils/device_id.dart << 'EOF'
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceId {
  static const _key = 'device_id';
  static final _uuid = const Uuid();

  static Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await prefs.setString(_key, id);
    return id;
  }
}
EOF

echo "==> Writing lib/core/utils/haptics.dart..."
cat > lib/core/utils/haptics.dart << 'EOF'
import 'package:flutter/services.dart';

class Haptics {
  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }
}
EOF

echo "==> Writing lib/core/theme/app_theme.dart..."
cat > lib/core/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF5F5F8),
    fontFamily: 'Satoshi',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: colorScheme.onBackground,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
EOF

echo "==> Writing lib/data/models/profile.dart..."
cat > lib/data/models/profile.dart << 'EOF'
class Profile {
  final String id;
  final String randomId;
  final String deviceId;
  final int currentStreak;
  final int longestStreak;
  final int totalCheckins;
  final double? burnoutRiskScore;
  final double? engagementScore;

  Profile({
    required this.id,
    required this.randomId,
    required this.deviceId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckins,
    this.burnoutRiskScore,
    this.engagementScore,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      randomId: map['random_id'] as String,
      deviceId: map['device_id'] as String,
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
      totalCheckins: map['total_checkins'] ?? 0,
      burnoutRiskScore: (map['burnout_risk_score'] as num?)?.toDouble(),
      engagementScore: (map['engagement_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'random_id': randomId,
      'device_id': deviceId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_checkins': totalCheckins,
      'burnout_risk_score': burnoutRiskScore,
      'engagement_score': engagementScore,
    };
  }
}
EOF

echo "==> Writing lib/data/models/pulse.dart..."
cat > lib/data/models/pulse.dart << 'EOF'
class Pulse {
  final int? id;
  final String profileId;
  final DateTime createdAt;
  final String color;
  final int energy;
  final int stress;
  final int focusScore;
  final List<String> wellnessTags;
  final String? notes;
  final double? sentimentScore;
  final Duration responseTime;
  final bool attentionCheckPassed;

  Pulse({
    this.id,
    required this.profileId,
    required this.createdAt,
    required this.color,
    required this.energy,
    required this.stress,
    required this.focusScore,
    required this.wellnessTags,
    this.notes,
    this.sentimentScore,
    required this.responseTime,
    required this.attentionCheckPassed,
  });

  Map<String, dynamic> toInsertMap() {
    return {
      'profile_id': profileId,
      'created_at': createdAt.toIso8601String(),
      'color': color,
      'energy': energy,
      'stress': stress,
      'focus_score': focusScore,
      'wellness_tags': wellnessTags,
      'notes': notes,
      'sentiment_score': sentimentScore,
      'response_time_ms': responseTime.inMilliseconds,
      'attention_check_passed': attentionCheckPassed,
    };
  }
}
EOF

echo "==> Writing lib/data/repositories/profile_repository.dart..."
cat > lib/data/repositories/profile_repository.dart << 'EOF'
import '../supabase_client.dart';
import '../../core/utils/device_id.dart';
import '../models/profile.dart';
import 'dart:math';

class ProfileRepository {
  final _table = 'profiles';
  final _rand = Random();

  Future<Profile> getOrCreateAnonymousProfile() async {
    final deviceId = await DeviceId.getOrCreate();

    final existing = await supabase
        .from(_table)
        .select()
        .eq('device_id', deviceId)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      return Profile.fromMap(existing);
    }

    final randomId = _generateRandomId();
    final res = await supabase.from(_table).insert({
      'random_id': randomId,
      'device_id': deviceId,
      'current_streak': 0,
      'longest_streak': 0,
      'total_checkins': 0,
    }).select().single();

    return Profile.fromMap(res);
  }

  String _generateRandomId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(10, (_) => chars[_rand.nextInt(chars.length)]).join();
  }
}
EOF

echo "==> Writing lib/data/repositories/pulse_repository.dart..."
cat > lib/data/repositories/pulse_repository.dart << 'EOF'
import '../supabase_client.dart';
import '../models/pulse.dart';

class PulseRepository {
  final _table = 'pulses';

  Future<void> submitPulse(Pulse pulse) async {
    await supabase.from(_table).insert(pulse.toInsertMap());
  }
}
EOF

echo "==> Writing lib/state/app_providers.dart..."
cat > lib/state/app_providers.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/pulse_repository.dart';
import '../features/notifications/notification_service.dart';

final profileRepoProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final pulseRepoProvider = Provider<PulseRepository>((ref) {
  return PulseRepository();
});

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
EOF

echo "==> Writing lib/state/checkin/checkin_controller.dart..."
cat > lib/state/checkin/checkin_controller.dart << 'EOF'
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
EOF

echo "==> Writing lib/features/checkin/color_wheel.dart..."
cat > lib/features/checkin/color_wheel.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

typedef ColorSelected = void Function(String colorName);

class ColorWheel extends StatelessWidget {
  final String selectedColor;
  final ColorSelected onSelected;

  const ColorWheel({
    super.key,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      'Green',
      'Blue',
      'Yellow',
      'Orange',
      'Red',
      'Purple',
      'Grey',
      'Pink',
    ];

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Lottie.asset(
            'assets/lottie/color_wheel.json',
            repeat: true,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) {
            final isSelected = c == selectedColor;
            return ChoiceChip(
              label: Text(c),
              selected: isSelected,
              onSelected: (_) => onSelected(c),
            );
          }).toList(),
        ),
      ],
    );
  }
}
EOF

echo "==> Writing lib/features/checkin/checkin_screen.dart..."
cat > lib/features/checkin/checkin_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/checkin/checkin_controller.dart';
import 'color_wheel.dart';
import '../../core/utils/haptics.dart';

class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkinControllerProvider);
    final controller = ref.read(checkinControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RBM-Pulse'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: state.phase == CheckinPhase.main
            ? _MainPhase(state: state, controller: controller)
            : _ExtraQuestionPhase(state: state, controller: controller),
      ),
    );
  }
}

class _MainPhase extends StatelessWidget {
  final CheckinState state;
  final CheckinController controller;

  const _MainPhase({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ColorWheel(
            selectedColor: state.color,
            onSelected: controller.setColor,
          ),
          const SizedBox(height: 24),
          _SliderCard(
            title: 'Overall feeling',
            subtitle: 'Unpleasant 😔 — Pleasant 😊',
            value: state.valence,
            onChanged: controller.setValence,
          ),
          const SizedBox(height: 16),
          _SliderCard(
            title: 'Energy',
            subtitle: 'Exhausted 😴 — Energized ⚡',
            value: state.energy,
            onChanged: controller.setEnergy,
          ),
          const Spacer(),
          FilledButton(
            onPressed: state.canSubmitMain
                ? () {
                    Haptics.light();
                    controller.onMainNext();
                  }
                : null,
            child: const Text('Next'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ExtraQuestionPhase extends StatelessWidget {
  final CheckinState state;
  final CheckinController controller;

  const _ExtraQuestionPhase({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final q = state.extraQuestion;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            q?.text ?? '',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Slider(
            value: state.extraAnswer,
            min: 0,
            max: 10,
            divisions: 10,
            label: state.extraAnswer.round().toString(),
            onChanged: controller.setExtraAnswer,
          ),
          const Spacer(),
          FilledButton(
            onPressed: () async {
              Haptics.medium();
              final success = await controller.submitAll();
              if (!context.mounted) return;
              if (success) Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Slider(
              value: value,
              onChanged: onChanged,
              min: 0,
              max: 100,
            ),
          ],
        ),
      ),
    );
  }
}
EOF

echo "==> Writing lib/features/onboarding/onboarding_screen.dart..."
cat > lib/features/onboarding/onboarding_screen.dart << 'EOF'
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const OnboardingScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to RBM-Pulse',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'This app gives our organisation a daily “heartbeat” of how people feel at work using a scientific mood model (valence + energy). '
                'Your responses are anonymous and used only in aggregate to guide wellbeing decisions, not for performance reviews.',
              ),
              const SizedBox(height: 16),
              Text(
                'You will answer a 20–25 second daily check-in using colours and two sliders. '
                'Occasionally you may see one extra question from short, validated wellbeing scales.',
              ),
              const SizedBox(height: 16),
              Text(
                'Participation is voluntary. Data is never used to single out individuals; it is about patterns over time so leaders can improve workload, support, and work design.',
              ),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                child: const Text('I understand, continue'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "==> Writing lib/features/notifications/notification_service.dart..."
cat > lib/features/notifications/notification_service.dart << 'EOF'
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
    tzdata.initializeTimeZones();
  }

  Future<void> scheduleDailyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 16);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      1,
      'RBM-Pulse check-in',
      'Take 20 seconds to check in with yourself today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_checkin',
          'Daily Check-in',
          channelDescription: 'Daily wellbeing reminder',
          importance: Importance.defaultImportance,
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
EOF

echo "==> Writing lib/main.dart..."
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/supabase_client.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/checkin/checkin_screen.dart';
import 'features/notifications/notification_service.dart';
import 'state/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const ProviderScope(child: OrgPulseApp()));
}

class OrgPulseApp extends ConsumerStatefulWidget {
  const OrgPulseApp({super.key});

  @override
  ConsumerState<OrgPulseApp> createState() => _OrgPulseAppState();
}

class _OrgPulseAppState extends ConsumerState<OrgPulseApp> {
  bool _seenOnboarding = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    await ref.read(notificationServiceProvider).init();
    await ref.read(notificationServiceProvider).scheduleDailyReminder();

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'RBM-Pulse',
      theme: buildAppTheme(),
      initialRoute: _seenOnboarding ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (context) => OnboardingScreen(
              onContinue: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen_onboarding', true);
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
        '/home': (context) => const CheckinScreen(),
        // TODO: add /dashboard and /admin routes.
      },
    );
  }
}
EOF

echo "==> Writing README.md..."
cat > README.md << 'EOF'
# RBM-Pulse

Internal, anonymous daily wellbeing check-in app using Flutter + Supabase.

## Setup

1. Install Flutter 3.24+.
2. Create a Supabase project and add tables: profiles, pulses, tips, daily_insights.
3. Update `lib/core/env/constants.dart` with your Supabase URL and anon key.
4. Run:
   - `flutter pub get`
   - `flutter run`

## Build

- Android: `flutter build apk --release`
- iOS: `flutter build ios --release`
- Web: `flutter build web --release`
EOF

echo "==> Running flutter pub get..."
flutter pub get

echo "==> Done. Project scaffolded in ${APP_NAME}/"

