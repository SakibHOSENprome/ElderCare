import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AppointmentsScreen extends StatefulWidget {
  final String? elderId;
  final String? elderName;
  const AppointmentsScreen({super.key, this.elderId, this.elderName});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _authService = AuthService();
  final _appointmentService = AppointmentService();
  bool _upcoming = true;
  bool _loading = true;
  String? _error;
  List<Appointment> _items = [];
  final Map<String, TextEditingController> _prescriptionControllers = {};
  final Set<String> _savingPrescription = {};

  String? get _uid => widget.elderId ?? _authService.currentAuthUser?.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _prescriptionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(Appointment a) {
    return _prescriptionControllers.putIfAbsent(
        a.id, () => TextEditingController(text: a.prescriptionLink ?? ''));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = _uid;
      if (uid == null) {
        _error = 'You are not logged in.';
      } else {
        var items = await _appointmentService.fetchAll(uid, upcoming: _upcoming);

        // Any "upcoming" appointment whose date/time has already passed
        // automatically becomes a past appointment.
        if (_upcoming) {
          final now = DateTime.now();
          final overdue = items.where((a) => a.dateTime.isBefore(now)).toList();
          if (overdue.isNotEmpty) {
            for (final a in overdue) {
              try {
                await _appointmentService.markPast(a.id);
              } catch (_) {
                // Non-fatal — it'll be picked up on next load.
              }
            }
            items = items.where((a) => !a.dateTime.isBefore(now)).toList();
          }
        }
        _items = items;
      }
    } catch (e) {
      _error = 'Could not load appointments: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePrescriptionLink(Appointment a) async {
    final link = _controllerFor(a).text.trim();
    if (link.isEmpty) return;
    setState(() => _savingPrescription.add(a.id));
    try {
      await _appointmentService.updatePrescriptionLink(a.id, link);
      final index = _items.indexWhere((x) => x.id == a.id);
      if (index != -1) {
        setState(() {
          _items[index] = Appointment(
            id: a.id,
            userId: a.userId,
            doctorName: a.doctorName,
            specialty: a.specialty,
            dateTime: a.dateTime,
            location: a.location,
            isUpcoming: a.isUpcoming,
            prescriptionLink: link,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save link: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _savingPrescription.remove(a.id));
    }
  }

  Future<void> _openLink(String link) async {
    var url = link.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(widget.elderName != null ? "${widget.elderName}'s Appointments" : 'Appointments')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddSheet,
        child: Icon(Icons.add, color: AppColors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(child: _tabButton('Upcoming', true)),
                  SizedBox(width: 12),
                  Expanded(child: _tabButton('Past', false)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _error != null
                        ? ListView(children: [
                            Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Center(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24),
                                      child: Text(_error!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: AppColors.danger)),
                                    ),
                                    SizedBox(height: 12),
                                    TextButton(onPressed: _load, child: Text('Retry')),
                                  ],
                                ),
                              ),
                            )
                          ])
                        : _items.isEmpty
                        ? ListView(children: [
                            Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Center(
                                  child: Text('No appointments found.',
                                      style: TextStyle(color: AppColors.grey))),
                            )
                          ])
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _items.length,
                            itemBuilder: (context, i) => _appointmentCard(_items[i]),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool upcomingValue) {
    final selected = _upcoming == upcomingValue;
    return GestureDetector(
      onTap: () {
        setState(() => _upcoming = upcomingValue);
        _load();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.lightGrey),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.white : AppColors.dark,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _appointmentCard(Appointment a) {
    return Card(
      margin: EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.person, color: AppColors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.doctorName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(a.specialty, style: TextStyle(fontSize: 13, color: AppColors.grey)),
                      SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                        SizedBox(width: 6),
                        Text(DateFormat('MMM d, yyyy (E) • h:mm a').format(a.dateTime),
                            style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      ]),
                      SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey),
                        SizedBox(width: 6),
                        Expanded(
                            child: Text(a.location,
                                style: TextStyle(fontSize: 12, color: AppColors.grey))),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            if (!a.isUpcoming) ...[
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Prescription',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 8),
              if (a.prescriptionLink != null && a.prescriptionLink!.isNotEmpty)
                InkWell(
                  onTap: () => _openLink(a.prescriptionLink!),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.prescriptionLink!,
                          style: TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.grey),
                        onPressed: () => setState(() {
                          // Reveal the editable field prefilled with the current link.
                          _controllerFor(a).text = a.prescriptionLink ?? '';
                          _items = _items.map((x) {
                            if (x.id == a.id) {
                              return Appointment(
                                id: x.id,
                                userId: x.userId,
                                doctorName: x.doctorName,
                                specialty: x.specialty,
                                dateTime: x.dateTime,
                                location: x.location,
                                isUpcoming: x.isUpcoming,
                                prescriptionLink: '',
                              );
                            }
                            return x;
                          }).toList();
                        }),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: '',
                        hint: 'Paste prescription link',
                        controller: _controllerFor(a),
                        icon: Icons.link,
                      ),
                    ),
                    SizedBox(width: 8),
                    _savingPrescription.contains(a.id)
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : IconButton(
                            icon: Icon(Icons.check_circle, color: AppColors.primary),
                            onPressed: () => _savePrescriptionLink(a),
                          ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _openAddSheet() {
    final doctor = TextEditingController();
    final specialty = TextEditingController();
    final location = TextEditingController();
    DateTime date = DateTime.now().add(Duration(days: 1));
    TimeOfDay time = TimeOfDay(hour: 10, minute: 30);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Appointment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 16),
                CustomTextField(
                    label: 'Doctor Name', hint: 'Dr. Ahmed Rahman', controller: doctor, icon: Icons.person_outline),
                CustomTextField(
                    label: 'Specialty', hint: 'Cardiologist', controller: specialty, icon: Icons.medical_services_outlined),
                CustomTextField(
                    label: 'Location', hint: 'Green Life Hospital', controller: location, icon: Icons.location_on_outlined),
                Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                    );
                    if (picked != null) setModalState(() => date = picked);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.grey, size: 18),
                        SizedBox(width: 10),
                        Text(DateFormat('MMM d, yyyy (E)').format(date)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text('Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: time);
                    if (picked != null) setModalState(() => time = picked);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.grey, size: 18),
                        SizedBox(width: 10),
                        Text(time.format(context)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                PrimaryButton(
                  label: 'Save Appointment',
                  loading: saving,
                  onPressed: () async {
                    if (doctor.text.trim().isEmpty) return;
                    setModalState(() => saving = true);
                    try {
                      final uid = _uid;
                      if (uid == null) throw Exception('You are not logged in.');
                      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      await _appointmentService.add(Appointment(
                        id: '',
                        userId: uid,
                        doctorName: doctor.text.trim(),
                        specialty: specialty.text.trim(),
                        dateTime: dt,
                        location: location.text.trim(),
                        isUpcoming: true,
                      ));
                      if (mounted) Navigator.pop(context);
                      _load();
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not save appointment: $e'),
                              backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
