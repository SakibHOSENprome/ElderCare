import '../core/supabase_config.dart';
import '../models/app_user.dart';
import '../models/medicine.dart';
import '../models/health_record.dart';
import '../models/appointment.dart';
import '../models/caregiver_assignment.dart';

/// Aggregates data for a caregiver watching over an assigned elder, plus
/// the elder-side "browse & assign a caregiver" directory and the
/// caregiver-side "elders assigned to me" list.
class CaregiverService {
  Future<AppUser?> fetchLinkedElder(String elderId) async {
    final data = await supabase.from('profiles').select().eq('id', elderId).maybeSingle();
    return data == null ? null : AppUser.fromMap(data);
  }

  Future<List<Medicine>> fetchTodaysMedicines(String elderId) async {
    final data = await supabase
        .from('medicines')
        .select()
        .eq('user_id', elderId)
        .order('time');
    return (data as List).map((e) => Medicine.fromMap(e)).toList();
  }

  Future<Appointment?> fetchNextAppointment(String elderId) async {
    final data = await supabase
        .from('appointments')
        .select()
        .eq('user_id', elderId)
        .eq('is_upcoming', true)
        .order('date_time')
        .limit(1)
        .maybeSingle();
    return data == null ? null : Appointment.fromMap(data);
  }

  Future<HealthRecord?> fetchLatestHealth(String elderId) async {
    final data = await supabase
        .from('health_records')
        .select()
        .eq('user_id', elderId)
        .order('recorded_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return data == null ? null : HealthRecord.fromMap(data);
  }

  // ---- Caregiver directory (elder-side "Assign Caregiver" screen) --------

  /// Every registered caregiver, for an elder to browse and assign.
  Future<List<AppUser>> fetchAllCaregivers() async {
    final data = await supabase.from('profiles').select().eq('role', 'caregiver');
    return (data as List).map((e) => AppUser.fromMap(e)).toList();
  }

  /// The caregivers this elder has already assigned, keyed by caregiver id
  /// so the directory screen can show "Assigned" and allow un-assigning.
  Future<Map<String, CaregiverAssignment>> fetchAssignmentsForElder(String elderId) async {
    final data =
        await supabase.from('caregiver_assignments').select().eq('elder_id', elderId);
    final assignments =
        (data as List).map((e) => CaregiverAssignment.fromMap(e)).toList();
    return {for (final a in assignments) a.caregiverId: a};
  }

  Future<void> assignCaregiver({required String elderId, required String caregiverId}) async {
    await supabase.from('caregiver_assignments').insert({
      'elder_id': elderId,
      'caregiver_id': caregiverId,
    });
  }

  Future<void> unassignCaregiver(String assignmentId) async {
    await supabase.from('caregiver_assignments').delete().eq('id', assignmentId);
  }

  // ---- Assigned elders (caregiver-side "My Assigned Elders" screen) ------

  /// Every elder currently assigned to this caregiver.
  Future<List<AppUser>> fetchAssignedElders(String caregiverId) async {
    final assignmentData = await supabase
        .from('caregiver_assignments')
        .select()
        .eq('caregiver_id', caregiverId);
    final elderIds =
        (assignmentData as List).map((e) => e['elder_id'] as String).toList();
    if (elderIds.isEmpty) return [];
    final profileData = await supabase.from('profiles').select().inFilter('id', elderIds);
    return (profileData as List).map((e) => AppUser.fromMap(e)).toList();
  }
}
