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
    final res = await supabase
        .from(_table)
        .insert({
          'random_id': randomId,
          'device_id': deviceId,
          'current_streak': 0,
          'longest_streak': 0,
          'total_checkins': 0,
        })
        .select()
        .single();

    return Profile.fromMap(res);
  }

  String _generateRandomId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(10, (_) => chars[_rand.nextInt(chars.length)]).join();
  }
}
