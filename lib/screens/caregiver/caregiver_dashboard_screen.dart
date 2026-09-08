import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../models/medicine.dart';
import '../../models/appointment.dart';
import '../../models/health_record.dart';
import '../../services/caregiver_service.dart';
import '../medicines/medicines_screen.dart';
import '../appointments/appointments_screen.dart';
import '../health/health_records_screen.dart';
import '../sos/emergency_contacts_screen.dart';
import '../sos/sos_screen.dart';

/// Caregiver-side screen for a single assigned elder. Gives the caregiver
/// full access to that elder's medicines, appointments, health records,
/// emergency contacts, and the ability to trigger SOS on their behalf —
/// everything the elder themself can do.
class CaregiverDashboardScreen extends StatefulWidget {
  final String elderId;
  const CaregiverDashboardScreen({super.key, required this.elderId});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final _service = CaregiverService();

  AppUser? _elder;
  List<Medicine> _medicines = [];
  Appointment? _nextAppointment;
  HealthRecord? _latestHealth;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _elder = await _service.fetchLinkedElder(widget.elderId);
      _medicines = await _service.fetchTodaysMedicines(widget.elderId);
      _nextAppointment = await _service.fetchNextAppointment(widget.elderId);
      _latestHealth = await _service.fetchLatestHealth(widget.elderId);
    } catch (e) {
      _error = 'Could not load caregiver dashboard: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _elderName => _elder?.fullName ?? 'Elder';

  void _openMedicines() => Navigator.of(context)
      .push(MaterialPageRoute(
          builder: (context) => MedicinesScreen(elderId: widget.elderId, elderName: _elderName)))
      .then((_) => _load());

  void _openAppointments() => Navigator.of(context)
      .push(MaterialPageRoute(
          builder: (context) =>
              AppointmentsScreen(elderId: widget.elderId, elderName: _elderName)))
      .then((_) => _load());

  void _openHealthRecords() => Navigator.of(context)
      .push(MaterialPageRoute(
          builder: (context) =>
              HealthRecordsScreen(elderId: widget.elderId, elderName: _elderName)))
      .then((_) => _load());

  void _openEmergencyContacts() => Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          EmergencyContactsScreen(elderId: widget.elderId, elderName: _elderName)));

  void _openSOS() => Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SOSScreen(elderId: widget.elderId, elderName: _elderName)));

  @override
  Widget build(BuildContext context) {
    final taken = _medicines.where((m) => m.status == MedicineStatus.taken).length;
    final missed = _medicines.where((m) => m.status == MedicineStatus.pending).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_elder != null ? _elderName : 'Elder')),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.danger)),
                          SizedBox(height: 12),
                          TextButton(onPressed: _load, child: Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.person, color: AppColors.white, size: 28),
                        ),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_elderName,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                            Text('Age ${_elder?.age ?? '--'} • Elder',
                                style: TextStyle(color: AppColors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openSOS,
                        icon: Icon(Icons.sos_rounded, color: AppColors.white),
                        label: Text('Send SOS for $_elderName'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            "Today's Medicines",
                            '$taken/${_medicines.length} Taken',
                            AppColors.accentGreen,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            'Missed Medicines',
                            '$missed',
                            AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            'Next Appointment',
                            _nextAppointment != null
                                ? '${_nextAppointment!.doctorName}'
                                : 'None scheduled',
                            AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            'Health Status',
                            _latestHealth != null ? 'BP ${_latestHealth!.bpDisplay}' : 'No data',
                            Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text('Manage',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    _actionTile(Icons.medication_rounded, 'Medicines',
                        'Add, view and mark medicines as taken', _openMedicines),
                    _actionTile(Icons.calendar_today_rounded, 'Appointments',
                        'Schedule appointments and add prescription links', _openAppointments),
                    _actionTile(Icons.favorite_outline, 'Health Records',
                        'Log blood pressure, sugar, weight and pulse', _openHealthRecords),
                    _actionTile(Icons.people_outline, 'Emergency Contacts',
                        "Manage who gets called and texted on SOS", _openEmergencyContacts),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.dark)),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.grey)),
        trailing: Icon(Icons.chevron_right, color: AppColors.grey),
        onTap: onTap,
      ),
    );
  }
}
