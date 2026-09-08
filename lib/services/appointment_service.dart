import '../core/supabase_config.dart';
import '../models/appointment.dart';

class AppointmentService {
  final _table = supabase.from('appointments');

  Future<List<Appointment>> fetchAll(String userId, {bool? upcoming}) async {
    var query = _table.select().eq('user_id', userId);
    if (upcoming != null) {
      query = query.eq('is_upcoming', upcoming);
    }
    final data = await query.order('date_time', ascending: true);
    return (data as List).map((e) => Appointment.fromMap(e)).toList();
  }

  Future<void> add(Appointment appointment) async {
    await _table.insert(appointment.toInsertMap());
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }

  Future<void> markPast(String id) async {
    await _table.update({'is_upcoming': false}).eq('id', id);
  }

  Future<void> updatePrescriptionLink(String id, String link) async {
    await _table.update({'prescription_link': link}).eq('id', id);
  }
}
