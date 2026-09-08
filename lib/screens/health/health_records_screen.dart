import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/health_service.dart';
import '../../models/health_record.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class HealthRecordsScreen extends StatefulWidget {
  final String? elderId;
  final String? elderName;
  const HealthRecordsScreen({super.key, this.elderId, this.elderName});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final _authService = AuthService();
  final _healthService = HealthService();
  List<HealthRecord> _records = [];
  bool _loading = true;
  String? _error;

  String? get _uid => widget.elderId ?? _authService.currentAuthUser?.id;

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
      final uid = _uid;
      if (uid == null) {
        _error = 'You are not logged in.';
      } else {
        _records = await _healthService.fetchAll(uid);
      }
    } catch (e) {
      _error = 'Could not load health records: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(widget.elderName != null
              ? "${widget.elderName}'s Health Records"
              : 'Health Records')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddSheet,
        child: Icon(Icons.add, color: AppColors.white),
      ),
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
                    child: _records.isEmpty
                        ? ListView(children: [
                            Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                      'No health records yet. Tap + to log blood pressure, '
                                      'sugar, weight or pulse.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.grey)),
                                ),
                              ),
                            )
                          ])
                        : ListView.separated(
                            padding: EdgeInsets.all(20),
                            itemCount: _records.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: AppColors.cardBorder),
                            itemBuilder: (context, i) {
                              final r = _records[i];
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(DateFormat('MMM d, yyyy').format(r.recordedAt),
                                        style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text('BP ${r.bpDisplay}', style: TextStyle(color: AppColors.grey)),
                                    Text('Sugar ${r.sugar ?? '--'}',
                                        style: TextStyle(color: AppColors.grey)),
                                    Text('${r.weight ?? '--'}kg', style: TextStyle(color: AppColors.grey)),
                                    Text('${r.pulse ?? '--'}', style: TextStyle(color: AppColors.grey)),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
      ),
    );
  }

  void _openAddSheet() {
    final systolic = TextEditingController();
    final diastolic = TextEditingController();
    final sugar = TextEditingController();
    final weight = TextEditingController();
    final pulse = TextEditingController();
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
                Text('Add Health Record',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'BP Systolic',
                        hint: 'e.g. 120',
                        controller: systolic,
                        icon: Icons.favorite_border,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'BP Diastolic',
                        hint: 'e.g. 80',
                        controller: diastolic,
                        icon: Icons.favorite_border,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                CustomTextField(
                  label: 'Sugar (mg/dL)',
                  hint: 'e.g. 110',
                  controller: sugar,
                  icon: Icons.water_drop_outlined,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: 'Weight (kg)',
                  hint: 'e.g. 68.5',
                  controller: weight,
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                CustomTextField(
                  label: 'Pulse (bpm)',
                  hint: 'e.g. 72',
                  controller: pulse,
                  icon: Icons.monitor_heart_outlined,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                PrimaryButton(
                  label: 'Save Record',
                  loading: saving,
                  onPressed: () async {
                    final hasAny = systolic.text.trim().isNotEmpty ||
                        diastolic.text.trim().isNotEmpty ||
                        sugar.text.trim().isNotEmpty ||
                        weight.text.trim().isNotEmpty ||
                        pulse.text.trim().isNotEmpty;
                    if (!hasAny) return;
                    setModalState(() => saving = true);
                    try {
                      final uid = _uid;
                      if (uid == null) throw Exception('You are not logged in.');
                      await _healthService.add(HealthRecord(
                        id: '',
                        userId: uid,
                        recordedAt: DateTime.now(),
                        bpSystolic: int.tryParse(systolic.text.trim()),
                        bpDiastolic: int.tryParse(diastolic.text.trim()),
                        sugar: int.tryParse(sugar.text.trim()),
                        weight: double.tryParse(weight.text.trim()),
                        pulse: int.tryParse(pulse.text.trim()),
                      ));
                      if (mounted) Navigator.pop(context);
                      _load();
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not save record: $e'),
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
