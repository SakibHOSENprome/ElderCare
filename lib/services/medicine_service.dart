import '../core/supabase_config.dart';
import '../models/medicine.dart';

class MedicineService {
  final _table = supabase.from('medicines');

  Future<List<Medicine>> fetchAll(String userId) async {
    final data = await _table
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Medicine.fromMap(e)).toList();
  }

  Stream<List<Medicine>> watchAll(String userId) {
    return _table
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((rows) => rows.map((e) => Medicine.fromMap(e)).toList());
  }

  Future<void> add(Medicine medicine) async {
    await _table.insert(medicine.toInsertMap());
  }

  Future<void> updateStatus(String id, MedicineStatus status) async {
    await _table.update({'status': status.name}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
