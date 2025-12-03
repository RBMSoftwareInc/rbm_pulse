import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/pulse_repository.dart';
import '../data/repositories/question_repository.dart';
import '../features/notifications/notification_service.dart';

final profileRepoProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final pulseRepoProvider = Provider<PulseRepository>((ref) {
  return PulseRepository();
});

final questionRepoProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
