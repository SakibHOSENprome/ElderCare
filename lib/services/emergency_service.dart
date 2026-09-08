import '../core/supabase_config.dart';
import '../models/emergency_contact.dart';

class EmergencyService {
  final _contactsTable = supabase.from('emergency_contacts');
  final _alertsTable = supabase.from('sos_alerts');

  Future<List<EmergencyContact>> fetchContacts(String userId) async {
    final data = await _contactsTable.select().eq('user_id', userId);
    return (data as List).map((e) => EmergencyContact.fromMap(e)).toList();
  }

  Future<void> addContact(EmergencyContact contact) async {
    await _contactsTable.insert(contact.toInsertMap());
  }

  Future<void> deleteContact(String id) async {
    await _contactsTable.delete().eq('id', id);
  }

  /// Sends an SOS alert. In production this would trigger a Supabase Edge
  /// Function that fans out SMS / push notifications to caregivers.
  Future<void> triggerSOS({
    required String userId,
    double? latitude,
    double? longitude,
  }) async {
    await _alertsTable.insert({
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'status': 'active',
    });
  }

  Future<void> cancelSOS(String alertId) async {
    await _alertsTable.update({'status': 'cancelled'}).eq('id', alertId);
  }
}
