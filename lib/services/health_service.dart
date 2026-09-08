import '../core/supabase_config.dart';
import '../models/health_record.dart';

class HealthService {
  final _table = supabase.from('health_records');

  Future<List<HealthRecord>> fetchAll(String userId, {int limit = 60}) async {
    final data = await _table
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => HealthRecord.fromMap(e)).toList();
  }

  Future<HealthRecord?> fetchLatest(String userId) async {
    final data = await _table
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return data == null ? null : HealthRecord.fromMap(data);
  }

  Future<void> add(HealthRecord record) async {
    await _table.insert(record.toInsertMap());
  }
}
