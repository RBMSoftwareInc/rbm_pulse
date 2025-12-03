import '../supabase_client.dart';
import '../models/pulse.dart';

class PulseRepository {
  final _table = 'pulses';

  Future<void> submitPulse(Pulse pulse) async {
    await supabase.from(_table).insert(pulse.toInsertMap());
  }
}
